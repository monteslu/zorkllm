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
async function detectServer(base, wanted) {
  const origin = base.replace(/\/v1\/?$/, '');
  const get = async (url) => {
    const res = await fetch(url, { signal: AbortSignal.timeout(3000) });
    return res.ok ? res.json() : null;
  };
  try { // LM Studio
    const d = await get(`${origin}/api/v0/models`);
    const usable = d?.data?.filter((m) => m.state === 'loaded' && m.type !== 'embeddings');
    // With several models loaded at once, the context length must come from
    // the one actually being used - reading the first entry's window silently
    // sizes the session to another model's context (observed live: a 21k
    // model budgeted against a 17k neighbour, evicting for no reason).
    const loaded = (wanted && usable?.find((m) => m.id === wanted)) || usable?.[0];
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
  const detected = await detectServer(config.apiUrl, config.model);
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
  /**
   * Servers spell "don't think" differently: llama.cpp/LM Studio take
   * "none", OpenAI's GPT-5 family rejects that and wants "minimal". Walk
   * the list on rejection rather than giving up on the parameter - leaving
   * reasoning on costs 15x latency for a translation task (measured on
   * gpt-5-nano: 19.2s with hidden reasoning, 1.27s with "minimal").
   */
  const REASONING_OFF_VALUES = ['none', 'minimal', 'low'];
  let reasoningOffIdx = 0;
  /** Renamed by newer OpenAI models; discovered from the first 4xx. */
  let maxTokensField = 'max_tokens';
  /** Reasoning models reject an explicit temperature. */
  let sendTemperature = true;

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
        ...(sendTemperature ? { temperature: 0 } : {}),
        // Replies are a handful of command lines or a couple of sentences.
        // Uncapped generation can run away until it exhausts the server's
        // loaded context ("Context size has been exceeded" mid-stream).
        max_tokens: 512,
        messages: [{ role: 'system', content: system }, ...messages],
      };
      if (sendReasoningOff) body.reasoning_effort = REASONING_OFF_VALUES[reasoningOffIdx];
      if (maxTokensField !== 'max_tokens') {
        delete body.max_tokens;
        // Reasoning models bill hidden thinking against this same cap, so a
        // budget sized for visible output alone returns finish_reason
        // "length" with empty content - every turn, silently (observed:
        // gpt-5-nano spending 512 of 512 tokens reasoning about "look
        // around"). Give them room for both.
        body[maxTokensField] = 4096;
      }
      let res = await post(body);
      // Servers disagree about request fields, and the disagreements are
      // per-model, not per-endpoint: OpenAI's GPT-5 family rejects
      // `max_tokens` in favour of `max_completion_tokens`, and reasoning
      // models reject `temperature` outright. A 4xx naming the offending
      // parameter is recoverable - adapt once and remember for the session
      // rather than failing every turn.
      for (let attempt = 0; attempt < 3 && !res.ok && res.status >= 400 && res.status < 500; attempt++) {
        const detail = await res.clone().text().catch(() => '');
        if (sendReasoningOff && /reasoning_effort/.test(detail)
          && reasoningOffIdx < REASONING_OFF_VALUES.length - 1) {
          reasoningOffIdx += 1;
          body.reasoning_effort = REASONING_OFF_VALUES[reasoningOffIdx];
        } else if (sendReasoningOff && /reasoning_effort/.test(detail)) {
          sendReasoningOff = false;
          delete body.reasoning_effort;
        } else if (/max_completion_tokens/.test(detail) && 'max_tokens' in body) {
          maxTokensField = 'max_completion_tokens';
          delete body.max_tokens;
          body.max_completion_tokens = 512;
        } else if (/temperature/.test(detail) && 'temperature' in body) {
          sendTemperature = false;
          delete body.temperature;
        } else if (sendReasoningOff) {
          sendReasoningOff = false;
          delete body.reasoning_effort;
        } else {
          break;
        }
        res = await post(body);
      }
      // Hosted APIs rate-limit; a game turn is worth waiting a few seconds
      // for rather than losing. Honour Retry-After when the server sends it.
      for (let attempt = 0; attempt < 4 && (res.status === 429 || res.status >= 500); attempt++) {
        const hinted = Number(res.headers.get('retry-after')) * 1000;
        const waitMs = Number.isFinite(hinted) && hinted > 0
          ? Math.min(hinted, 20000) : Math.min(1000 * 2 ** attempt, 8000);
        await new Promise((r) => setTimeout(r, waitMs));
        res = await post(body);
      }
      if (!res.ok) {
        const errBody = await res.text().catch(() => '');
        throw new Error(`LLM request failed: ${res.status} ${res.statusText} ${errBody.slice(0, 300)}`);
      }
      const data = await res.json();
      const msg = data.choices?.[0]?.message;
      if (!msg) throw new Error('LLM response had no choices');
      // A reasoning model that hit the cap before emitting anything visible:
      // retry once with a much larger budget rather than reporting a blank.
      if (!msg.content && data.choices[0].finish_reason === 'length'
        && maxTokensField !== 'max_tokens' && body[maxTokensField] < 16384) {
        body[maxTokensField] = 16384;
        const retry = await post(body);
        if (retry.ok) {
          const rd = await retry.json();
          const rm = rd.choices?.[0]?.message;
          if (rm?.content) return rm.content;
        }
      }
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
