/**
 * LLM provider clients. Two shapes cover everything:
 *  - "openai": any OpenAI-compatible chat completions endpoint
 *    (Ollama, LM Studio, llama.cpp server, vLLM, OpenRouter, Groq, OpenAI, ...)
 *  - "anthropic": the Claude API via the official SDK
 *
 * Both expose: complete({ system, messages }) -> string
 * where messages is [{ role: 'user'|'assistant', content: string }, ...]
 */

/**
 * @typedef {Object} ProviderConfig
 * @property {'openai'|'anthropic'} provider
 * @property {string} model
 * @property {string} [apiUrl]  base URL for openai-compatible servers, e.g. http://localhost:11434/v1
 * @property {string} [apiKey]
 * @property {boolean} [think]  true = leave the model's thinking enabled (default: request it off)
 */

/**
 * Resolve provider config from CLI flags + environment.
 * Precedence: explicit flags > ZORKLLM_* env > provider-standard env > ollama default.
 * @param {{provider?: string, model?: string, apiUrl?: string, apiKey?: string}} flags
 * @returns {ProviderConfig}
 */
export function resolveConfig(flags = {}) {
  const env = process.env;
  let provider = flags.provider || env.ZORKLLM_PROVIDER;
  let apiUrl = flags.apiUrl || env.ZORKLLM_API_URL;
  let apiKey = flags.apiKey || env.ZORKLLM_API_KEY;
  let model = flags.model || env.ZORKLLM_MODEL;
  const think = flags.think ?? false;

  if (!provider) {
    if (apiUrl) provider = 'openai';
    else if (env.ANTHROPIC_API_KEY || env.ANTHROPIC_AUTH_TOKEN) provider = 'anthropic';
    else if (env.OPENAI_API_KEY || env.OPENAI_BASE_URL) provider = 'openai';
    else provider = 'openai'; // fall through to local ollama default below
  }

  if (provider === 'openai') {
    apiUrl = apiUrl || env.OPENAI_BASE_URL || 'http://localhost:11434/v1';
    apiKey = apiKey || env.OPENAI_API_KEY || 'none';
    // model may stay undefined: createClient() auto-detects from the server
  } else {
    model = model || 'claude-opus-5';
  }
  return { provider: /** @type {'openai'|'anthropic'} */ (provider), model, apiUrl, apiKey, think };
}

/**
 * Pick the best chat model from an OpenAI-compatible /v1/models listing:
 * first entry that doesn't look like an embedding/reranker model.
 * @param {Array<{id: string}>} models
 * @returns {string|undefined}
 */
export function pickChatModel(models) {
  return models.map((m) => m.id).find((id) => !/embed|rerank/i.test(id));
}

/**
 * Ask the server which model to use and how much context it actually has
 * loaded, preferring what is running right now:
 *  1. LM Studio native API reports load state AND loaded_context_length
 *     (which is often far below the model's maximum - a 131k model is
 *     commonly loaded with 8k)
 *  2. Ollama native API reports the currently running model
 *  3. any OpenAI-compatible server can at least list its models
 * @param {string} base  e.g. http://localhost:1234/v1
 * @returns {Promise<{model?: string, contextLength?: number}>}
 */
async function detectServer(base) {
  const origin = base.replace(/\/v1\/?$/, '');
  const get = async (url) => {
    const res = await fetch(url, { signal: AbortSignal.timeout(3000) });
    return res.ok ? res.json() : null;
  };
  try { // LM Studio
    const d = await get(`${origin}/api/v0/models`);
    const loaded = d?.data?.find((m) => m.state === 'loaded' && m.type !== 'embeddings');
    if (loaded) {
      return { model: loaded.id, contextLength: loaded.loaded_context_length || loaded.max_context_length };
    }
  } catch { /* not LM Studio */ }
  try { // Ollama: currently loaded model, else first installed
    const ps = await get(`${origin}/api/ps`);
    if (ps?.models?.length) {
      // Ollama's default num_ctx is small; only trust an explicit report.
      return { model: ps.models[0].name, contextLength: ps.models[0].context_length || 4096 };
    }
    const tags = await get(`${origin}/api/tags`);
    if (tags?.models?.length) {
      return { model: pickChatModel(tags.models.map((m) => ({ id: m.name }))), contextLength: 4096 };
    }
  } catch { /* not Ollama */ }
  try { // generic OpenAI-compatible
    const d = await get(`${base.replace(/\/$/, '')}/models`);
    if (d?.data?.length) return { model: pickChatModel(d.data) };
  } catch { /* server down; the first real request will say so clearly */ }
  return {};
}

/**
 * @param {ProviderConfig} config
 * @returns {Promise<{complete: (req: {system: string, messages: Array<{role: string, content: string}>}) => Promise<string>, describe: () => string}>}
 */
export async function createClient(config) {
  if (config.provider === 'anthropic') {
    return { ...(await createAnthropicClient(config)), contextLength: null };
  }
  const detected = await detectServer(config.apiUrl);
  config.model = config.model || detected.model;
  if (!config.model) {
    throw new Error(
      `No model specified and none could be detected at ${config.apiUrl}. ` +
      'Is the server running? (Pass --model to name one explicitly.)',
    );
  }
  const client = await createOpenAIClient(config);
  return { ...client, contextLength: detected.contextLength ?? null };
}

/** @param {ProviderConfig} config */
async function createAnthropicClient(config) {
  const { default: Anthropic } = await import('@anthropic-ai/sdk');
  const client = config.apiKey ? new Anthropic({ apiKey: config.apiKey }) : new Anthropic();
  return {
    describe: () => `anthropic ${config.model}`,
    async complete({ system, messages }) {
      const response = await client.messages.create({
        model: config.model,
        max_tokens: 2048,
        output_config: { effort: 'low' },
        system,
        messages,
      });
      if (response.stop_reason === 'refusal') {
        throw new Error('The model declined this request.');
      }
      const block = response.content.find((b) => b.type === 'text');
      return block ? block.text : '';
    },
  };
}

/** @param {ProviderConfig} config */
async function createOpenAIClient(config) {
  const base = config.apiUrl.replace(/\/$/, '');
  // Translation is a reflex task: reasoning tokens are ~9x latency for no
  // accuracy gain (measured on gemma-4-e4b: 300 -> 16 completion tokens).
  // reasoning_effort "none" disables thinking per-request on servers that
  // support it (LM Studio does); if a stricter server rejects the field we
  // retry without it once and stop sending it.
  let sendReasoningOff = config.think !== true;

  async function post(body) {
    return fetch(`${base}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(config.apiKey && config.apiKey !== 'none'
          ? { Authorization: `Bearer ${config.apiKey}` }
          : {}),
      },
      body: JSON.stringify(body),
    });
  }

  return {
    describe: () => `${base} ${config.model}`,
    async complete({ system, messages }) {
      const body = {
        model: config.model,
        temperature: 0,
        // Replies are a handful of command lines or a couple of sentences.
        // Uncapped generation can run away until it exhausts the server's
        // loaded context ("Context size has been exceeded" mid-stream).
        max_tokens: 512,
        messages: [{ role: 'system', content: system }, ...messages],
      };
      if (sendReasoningOff) body.reasoning_effort = 'none';
      let res = await post(body);
      if (!res.ok && sendReasoningOff && res.status >= 400 && res.status < 500) {
        sendReasoningOff = false;
        delete body.reasoning_effort;
        res = await post(body);
      }
      if (!res.ok) {
        const errBody = await res.text().catch(() => '');
        throw new Error(`LLM request failed: ${res.status} ${res.statusText} ${errBody.slice(0, 300)}`);
      }
      const data = await res.json();
      const msg = data.choices?.[0]?.message;
      if (!msg) throw new Error('LLM response had no choices');
      debugLog({
        lastUser: messages[messages.length - 1]?.content,
        content: msg.content,
        reasoning: msg.reasoning_content || msg.reasoning || undefined,
        finish: data.choices[0].finish_reason,
        usage: data.usage,
      });
      return msg.content || '';
    },
  };
}

/**
 * Set ZORKLLM_DEBUG=/path/to/log to append one JSON line per LLM exchange:
 * the last user message, the raw reply content, any reasoning text, the
 * finish reason, and token usage. This is the first thing to reach for when
 * a model "returns nothing" - the answer is always in the raw exchange.
 * @param {object} entry
 */
function debugLog(entry) {
  const path = process.env.ZORKLLM_DEBUG;
  if (!path) return;
  import('node:fs').then((fs) => {
    fs.appendFileSync(path, `${JSON.stringify({ at: new Date().toISOString(), ...entry })}\n`);
  }).catch(() => {});
}
