/* Bundled from npm package 'zmachine' v0.3.0 (MIT, https://www.npmjs.com/package/zmachine)
   Bundled because the published dist uses extensionless ESM imports that Node cannot resolve. */
// node_modules/zmachine/dist/core/memory/Header.js
var HeaderAddress = {
  /** Version number (1 byte) - §11.1.1 */
  VERSION: 0,
  /** Flags 1 (1 byte) - §11.1.2 */
  FLAGS1: 1,
  /** Release number (2 bytes) - §11.1.3 */
  RELEASE: 2,
  /** Base of high memory (2 bytes) - §11.1.4 */
  HIGH_MEMORY_BASE: 4,
  /** Initial value of PC (2 bytes) - §11.1.5 */
  INITIAL_PC: 6,
  /** Location of dictionary (2 bytes) - §11.1.6 */
  DICTIONARY: 8,
  /** Location of object table (2 bytes) - §11.1.7 */
  OBJECT_TABLE: 10,
  /** Location of global variables table (2 bytes) - §11.1.8 */
  GLOBALS: 12,
  /** Base of static memory (2 bytes) - §11.1.9 */
  STATIC_MEMORY_BASE: 14,
  /** Flags 2 (2 bytes) - §11.1.10 */
  FLAGS2: 16,
  /** Serial number (6 bytes ASCII) - §11.1.11 */
  SERIAL: 18,
  /** Location of abbreviations table (2 bytes) - §11.1.12 */
  ABBREVIATIONS: 24,
  /** Length of file (2 bytes, divided by constant) - §11.1.13 */
  FILE_LENGTH: 26,
  /** Checksum of file (2 bytes) - §11.1.14 */
  CHECKSUM: 28,
  /** Interpreter number (1 byte, V4+) - §11.1.15 */
  INTERPRETER_NUMBER: 30,
  /** Interpreter version (1 byte, V4+) - §11.1.16 */
  INTERPRETER_VERSION: 31,
  /** Screen height in lines (1 byte, V4+) */
  SCREEN_HEIGHT: 32,
  /** Screen width in characters (1 byte, V4+) */
  SCREEN_WIDTH: 33,
  /** Screen width in units (2 bytes, V5+) */
  SCREEN_WIDTH_UNITS: 34,
  /** Screen height in units (2 bytes, V5+) */
  SCREEN_HEIGHT_UNITS: 36,
  /** Font width/height in units (V5: 1 byte each, V6: reversed) */
  FONT_WIDTH: 38,
  FONT_HEIGHT: 39,
  /** Routines offset (2 bytes, V6+) */
  ROUTINES_OFFSET: 40,
  /** Strings offset (2 bytes, V6+) */
  STRINGS_OFFSET: 42,
  /** Default background color (1 byte, V5+) */
  DEFAULT_BACKGROUND: 44,
  /** Default foreground color (1 byte, V5+) */
  DEFAULT_FOREGROUND: 45,
  /** Address of terminating characters table (2 bytes, V5+) */
  TERMINATING_CHARS: 46,
  /** Total width of text sent to stream 3 (2 bytes, V6) */
  STREAM3_WIDTH: 48,
  /** Standard revision number (2 bytes) */
  STANDARD_REVISION: 50,
  /** Alphabet table address (2 bytes, V5+) */
  ALPHABET_TABLE: 52,
  /** Header extension table address (2 bytes, V5+) */
  EXTENSION_TABLE: 54
};
var Header = class {
  memory;
  data;
  constructor(memory) {
    this.memory = memory;
    this.data = this.parseHeader();
  }
  /**
   * Parse all header fields from memory
   */
  parseHeader() {
    const version = this.memory.readByte(HeaderAddress.VERSION);
    if (version < 1 || version > 8) {
      throw new Error(`Invalid Z-machine version: ${version}`);
    }
    const fileLength = this.calculateFileLength(this.memory.readWord(HeaderAddress.FILE_LENGTH), version);
    return {
      version,
      flags1: this.memory.readByte(HeaderAddress.FLAGS1),
      release: this.memory.readWord(HeaderAddress.RELEASE),
      highMemoryBase: this.memory.readWord(HeaderAddress.HIGH_MEMORY_BASE),
      initialPC: this.memory.readWord(HeaderAddress.INITIAL_PC),
      dictionaryAddress: this.memory.readWord(HeaderAddress.DICTIONARY),
      objectTableAddress: this.memory.readWord(HeaderAddress.OBJECT_TABLE),
      globalsAddress: this.memory.readWord(HeaderAddress.GLOBALS),
      staticMemoryBase: this.memory.readWord(HeaderAddress.STATIC_MEMORY_BASE),
      flags2: this.memory.readWord(HeaderAddress.FLAGS2),
      serialNumber: this.parseSerialNumber(),
      abbreviationsAddress: this.memory.readWord(HeaderAddress.ABBREVIATIONS),
      fileLength,
      checksum: this.memory.readWord(HeaderAddress.CHECKSUM)
    };
  }
  /**
   * Parse the 6-byte serial number as ASCII string
   */
  parseSerialNumber() {
    const bytes = this.memory.readBytes(HeaderAddress.SERIAL, 6);
    let serial = "";
    for (let i = 0; i < 6; i++) {
      serial += String.fromCharCode(bytes[i]);
    }
    return serial;
  }
  /**
   * Calculate actual file length from header value
   *
   * The stored value is divided by a version-dependent constant:
   * - V1-3: divide by 2
   * - V4-5: divide by 4
   * - V6+: divide by 8
   */
  calculateFileLength(headerValue, version) {
    if (version <= 3) {
      return headerValue * 2;
    } else if (version <= 5) {
      return headerValue * 4;
    } else {
      return headerValue * 8;
    }
  }
  /** Get Z-machine version */
  get version() {
    return this.data.version;
  }
  /** Get flags 1 value */
  get flags1() {
    return this.data.flags1;
  }
  /** Get release number */
  get release() {
    return this.data.release;
  }
  /** Get high memory base address */
  get highMemoryBase() {
    return this.data.highMemoryBase;
  }
  /** Get initial program counter */
  get initialPC() {
    return this.data.initialPC;
  }
  /** Get dictionary table address */
  get dictionaryAddress() {
    return this.data.dictionaryAddress;
  }
  /** Get object table address */
  get objectTableAddress() {
    return this.data.objectTableAddress;
  }
  /** Get global variables table address */
  get globalsAddress() {
    return this.data.globalsAddress;
  }
  /** Get static memory base address */
  get staticMemoryBase() {
    return this.data.staticMemoryBase;
  }
  /** Get flags 2 value */
  get flags2() {
    return this.data.flags2;
  }
  /** Get serial number */
  get serialNumber() {
    return this.data.serialNumber;
  }
  /** Get abbreviations table address */
  get abbreviationsAddress() {
    return this.data.abbreviationsAddress;
  }
  /** Get file length in bytes */
  get fileLength() {
    return this.data.fileLength;
  }
  /** Get file checksum */
  get checksum() {
    return this.data.checksum;
  }
  /**
   * Check if a Flags1 bit is set (for V3)
   */
  hasFlag1(flag) {
    return (this.data.flags1 & flag) !== 0;
  }
  /**
   * Check if a Flags2 bit is set
   */
  hasFlag2(flag) {
    return (this.data.flags2 & flag) !== 0;
  }
  /**
   * Set a Flags2 bit (these are writable by the interpreter)
   */
  setFlag2(flag, value) {
    const currentFlags = this.memory.readWord(HeaderAddress.FLAGS2);
    const newFlags = value ? currentFlags | flag : currentFlags & ~flag;
    this.memory.writeWord(HeaderAddress.FLAGS2, newFlags);
    this.data.flags2 = newFlags;
  }
  /**
   * Get the packed address multiplier for this version
   * Used to convert packed addresses to byte addresses
   */
  get packedAddressMultiplier() {
    if (this.data.version <= 3) {
      return 2;
    } else if (this.data.version <= 5) {
      return 4;
    } else {
      return 8;
    }
  }
  /**
   * Convert a packed address to a byte address
   */
  unpackAddress(packed, isString = false) {
    const version = this.data.version;
    if (version <= 3) {
      return packed * 2;
    } else if (version <= 5) {
      return packed * 4;
    } else if (version <= 7) {
      const offset = isString ? this.memory.readWord(HeaderAddress.STRINGS_OFFSET) * 8 : this.memory.readWord(HeaderAddress.ROUTINES_OFFSET) * 8;
      return packed * 4 + offset;
    } else {
      return packed * 8;
    }
  }
  /**
   * Set interpreter information in header (for V4+)
   */
  setInterpreterInfo(interpreterNumber, interpreterVersion) {
    if (this.data.version >= 4) {
      this.memory.writeByte(HeaderAddress.INTERPRETER_NUMBER, interpreterNumber);
      this.memory.writeByte(HeaderAddress.INTERPRETER_VERSION, interpreterVersion);
    }
  }
  /**
   * Set screen dimensions in header (for V4+)
   */
  setScreenDimensions(width, height) {
    if (this.data.version >= 4) {
      this.memory.writeByte(HeaderAddress.SCREEN_WIDTH, width);
      this.memory.writeByte(HeaderAddress.SCREEN_HEIGHT, height);
    }
    if (this.data.version >= 5) {
      this.memory.writeWord(HeaderAddress.SCREEN_WIDTH_UNITS, width);
      this.memory.writeWord(HeaderAddress.SCREEN_HEIGHT_UNITS, height);
    }
  }
};

// node_modules/zmachine/dist/core/memory/Memory.js
var Memory = class {
  /** Raw memory buffer */
  buffer;
  /** DataView for big-endian access */
  view;
  /** Original story file for restart */
  originalBuffer;
  /** Static memory boundary - writes above this are forbidden */
  staticMemoryBase = 0;
  /**
   * Create a new Memory instance from a story file
   *
   * @param storyData - The raw story file data as an ArrayBuffer
   */
  constructor(storyData) {
    this.buffer = storyData.slice(0);
    this.view = new DataView(this.buffer);
    this.originalBuffer = storyData.slice(0);
    this.staticMemoryBase = this.view.getUint16(HeaderAddress.STATIC_MEMORY_BASE, false);
  }
  /**
   * Get the total size of memory in bytes
   */
  get size() {
    return this.buffer.byteLength;
  }
  /**
   * Get the static memory boundary address
   */
  get staticBase() {
    return this.staticMemoryBase;
  }
  /**
   * Read a single byte from memory
   *
   * @param address - Byte address to read from
   * @returns The byte value (0-255)
   * @throws Error if address is out of bounds
   */
  readByte(address) {
    this.validateAddress(address);
    return this.view.getUint8(address);
  }
  /**
   * Read a 16-bit word from memory (big-endian)
   *
   * @param address - Byte address to read from
   * @returns The word value (0-65535)
   * @throws Error if address is out of bounds
   */
  readWord(address) {
    this.validateAddress(address);
    this.validateAddress(address + 1);
    return this.view.getUint16(address, false);
  }
  /**
   * Write a single byte to memory
   *
   * @param address - Byte address to write to
   * @param value - Byte value to write (0-255)
   * @throws Error if address is out of bounds or in static/high memory
   */
  writeByte(address, value) {
    this.validateWriteAddress(address);
    this.view.setUint8(address, value & 255);
  }
  /**
   * Write a 16-bit word to memory (big-endian)
   *
   * @param address - Byte address to write to
   * @param value - Word value to write (0-65535)
   * @throws Error if address is out of bounds or in static/high memory
   */
  writeWord(address, value) {
    this.validateWriteAddress(address);
    this.validateWriteAddress(address + 1);
    this.view.setUint16(address, value & 65535, false);
  }
  /**
   * Read a sequence of bytes from memory
   *
   * @param address - Starting byte address
   * @param length - Number of bytes to read
   * @returns Uint8Array containing the bytes
   */
  readBytes(address, length) {
    this.validateAddress(address);
    this.validateAddress(address + length - 1);
    return new Uint8Array(this.buffer, address, length);
  }
  /**
   * Get direct access to the underlying buffer
   * Used for save/restore operations
   */
  getBuffer() {
    return this.buffer;
  }
  /**
   * Get direct access to the DataView
   * Used for header parsing and other low-level operations
   */
  getView() {
    return this.view;
  }
  /**
   * Reset dynamic memory to original state (for restart)
   */
  restart() {
    const original = new Uint8Array(this.originalBuffer);
    const current = new Uint8Array(this.buffer);
    for (let i = 0; i < this.staticMemoryBase; i++) {
      current[i] = original[i];
    }
  }
  /**
   * Update static memory base (called after header parsing)
   */
  setStaticMemoryBase(address) {
    this.staticMemoryBase = address;
  }
  /**
   * Validate that an address is within bounds for reading
   */
  validateAddress(address) {
    if (address < 0 || address >= this.buffer.byteLength) {
      throw new Error(`Memory read out of bounds: 0x${address.toString(16)}`);
    }
  }
  /**
   * Validate that an address is within bounds and writable
   */
  validateWriteAddress(address) {
    this.validateAddress(address);
    if (address >= this.staticMemoryBase) {
      throw new Error(`Cannot write to static/high memory at 0x${address.toString(16)} (static memory starts at 0x${this.staticMemoryBase.toString(16)})`);
    }
  }
};

// node_modules/zmachine/dist/core/cpu/StackFrame.js
var StackFrame = class {
  /** Address to return to when routine completes */
  returnPC;
  /** Variable to store return value (undefined for V3 call with no store) */
  storeVariable;
  /** Local variables for this routine (0-15) */
  locals;
  /** Evaluation stack for this routine */
  evalStack;
  /** Number of arguments passed to this routine (for argc checks) */
  argumentCount;
  /**
   * Create a new stack frame
   *
   * @param returnPC - Address to return to when routine completes
   * @param storeVariable - Variable to store return value (undefined if discarded)
   * @param localCount - Number of local variables (0-15)
   * @param argumentCount - Number of arguments passed
   */
  constructor(returnPC, storeVariable, localCount, argumentCount) {
    if (localCount < 0 || localCount > 15) {
      throw new Error(`Invalid local variable count: ${localCount} (must be 0-15)`);
    }
    this.returnPC = returnPC;
    this.storeVariable = storeVariable;
    this.locals = new Array(localCount).fill(0);
    this.evalStack = [];
    this.argumentCount = argumentCount;
  }
  /**
   * Get the number of local variables in this frame
   */
  get localCount() {
    return this.locals.length;
  }
  /**
   * Get the current evaluation stack depth
   */
  get stackDepth() {
    return this.evalStack.length;
  }
  /**
   * Get a local variable value
   *
   * @param index - Local variable number (0-14, as 1-15 in opcodes)
   * @returns The variable value
   */
  getLocal(index) {
    if (index < 0 || index >= this.locals.length) {
      throw new Error(`Local variable ${index + 1} out of range (routine has ${this.locals.length} locals)`);
    }
    return this.locals[index];
  }
  /**
   * Set a local variable value
   *
   * @param index - Local variable number (0-14, as 1-15 in opcodes)
   * @param value - The value to set
   */
  setLocal(index, value) {
    if (index < 0 || index >= this.locals.length) {
      throw new Error(`Local variable ${index + 1} out of range (routine has ${this.locals.length} locals)`);
    }
    this.locals[index] = value & 65535;
  }
  /**
   * Initialize local variables with values (for V3 routine headers or arguments)
   *
   * @param values - Array of initial values
   */
  initializeLocals(values) {
    for (let i = 0; i < values.length && i < this.locals.length; i++) {
      this.locals[i] = values[i] & 65535;
    }
  }
  /**
   * Push a value onto the evaluation stack
   *
   * @param value - The value to push
   */
  push(value) {
    this.evalStack.push(value & 65535);
  }
  /**
   * Pop a value from the evaluation stack
   *
   * @returns The popped value
   * @throws Error if stack is empty
   */
  pop() {
    if (this.evalStack.length === 0) {
      throw new Error("Stack underflow: cannot pop from empty evaluation stack");
    }
    return this.evalStack.pop();
  }
  /**
   * Peek at the top of the evaluation stack without removing it
   *
   * @returns The top value
   * @throws Error if stack is empty
   */
  peek() {
    if (this.evalStack.length === 0) {
      throw new Error("Stack underflow: cannot peek at empty evaluation stack");
    }
    return this.evalStack[this.evalStack.length - 1];
  }
  /**
   * Get a copy of all local variables (for save/restore)
   */
  getLocalsSnapshot() {
    return [...this.locals];
  }
  /**
   * Get a copy of the evaluation stack (for save/restore)
   */
  getStackSnapshot() {
    return [...this.evalStack];
  }
  /**
   * Restore evaluation stack from a snapshot
   */
  restoreStack(stack) {
    this.evalStack.length = 0;
    this.evalStack.push(...stack);
  }
};

// node_modules/zmachine/dist/core/cpu/Stack.js
var Stack = class {
  /** Stack of call frames */
  frames = [];
  /**
   * Get the current call depth (number of active routines)
   */
  get depth() {
    return this.frames.length;
  }
  /**
   * Get the current (topmost) stack frame
   *
   * @throws Error if no frames on stack (should never happen after initialization)
   */
  get currentFrame() {
    if (this.frames.length === 0) {
      throw new Error("No stack frames: call stack is empty");
    }
    return this.frames[this.frames.length - 1];
  }
  /**
   * Push a new frame for a routine call
   *
   * @param returnPC - Address to return to after routine completes
   * @param storeVariable - Variable to store return value (undefined if discarded)
   * @param localCount - Number of local variables in the routine
   * @param argumentCount - Number of arguments passed
   * @returns The new stack frame
   */
  pushFrame(returnPC, storeVariable, localCount, argumentCount) {
    const frame = new StackFrame(returnPC, storeVariable, localCount, argumentCount);
    this.frames.push(frame);
    return frame;
  }
  /**
   * Pop the current frame (routine return)
   *
   * @returns The popped frame
   * @throws Error if trying to pop the last frame
   */
  popFrame() {
    if (this.frames.length <= 1) {
      throw new Error("Cannot pop initial stack frame");
    }
    return this.frames.pop();
  }
  /**
   * Initialize the stack with the main routine's frame
   * Called at game start with PC pointing to main routine
   *
   * @param localCount - Number of locals in main routine
   */
  initialize(localCount) {
    this.frames.length = 0;
    this.pushFrame(0, void 0, localCount, 0);
  }
  /**
   * Push a value onto the current frame's evaluation stack
   * (Used by variable 0x00)
   */
  push(value) {
    this.currentFrame.push(value);
  }
  /**
   * Pop a value from the current frame's evaluation stack
   * (Used by variable 0x00)
   */
  pop() {
    return this.currentFrame.pop();
  }
  /**
   * Peek at top of current frame's evaluation stack
   */
  peek() {
    return this.currentFrame.peek();
  }
  /**
   * Get a local variable from the current frame
   *
   * @param index - Local variable index (0-14)
   */
  getLocal(index) {
    return this.currentFrame.getLocal(index);
  }
  /**
   * Set a local variable in the current frame
   *
   * @param index - Local variable index (0-14)
   * @param value - Value to set
   */
  setLocal(index, value) {
    this.currentFrame.setLocal(index, value);
  }
  /**
   * Check if a given argument was supplied to the current routine
   * (For check_arg_count opcode)
   *
   * @param argNumber - Argument number (1-based)
   */
  hasArgument(argNumber) {
    return argNumber <= this.currentFrame.argumentCount;
  }
  /**
   * Create a snapshot of the entire call stack (for save)
   */
  snapshot() {
    return {
      frames: this.frames.map((frame) => ({
        returnPC: frame.returnPC,
        storeVariable: frame.storeVariable,
        argumentCount: frame.argumentCount,
        locals: frame.getLocalsSnapshot(),
        evalStack: frame.getStackSnapshot()
      }))
    };
  }
  /**
   * Restore the call stack from a snapshot (for restore)
   */
  restore(snapshot) {
    this.frames.length = 0;
    for (const frameData of snapshot.frames) {
      const frame = new StackFrame(frameData.returnPC, frameData.storeVariable, frameData.locals.length, frameData.argumentCount);
      frame.initializeLocals(frameData.locals);
      frame.restoreStack(frameData.evalStack);
      this.frames.push(frame);
    }
  }
  /**
   * Clear the stack (for restart)
   */
  clear() {
    this.frames.length = 0;
  }
  /**
   * Get the current stack frame depth (for catch opcode)
   * Returns 0 for the initial/main routine frame
   */
  getFramePointer() {
    return this.frames.length;
  }
  /**
   * Unwind the stack to a specific depth (for throw opcode)
   * Pops frames until we reach the target depth
   *
   * @param targetDepth - The frame depth to unwind to (from catch)
   * @returns The frame we unwound to (for getting return PC)
   * @throws Error if target depth is invalid
   */
  unwindTo(targetDepth) {
    if (targetDepth < 1 || targetDepth > this.frames.length) {
      throw new Error(`Invalid stack frame pointer: ${targetDepth}`);
    }
    while (this.frames.length > targetDepth) {
      this.frames.pop();
    }
    return this.frames.pop();
  }
  /**
   * Serialize stack for undo (lightweight format)
   */
  serialize() {
    const snapshot = this.snapshot();
    const data = [];
    const framePointers = [];
    for (const frame of snapshot.frames) {
      framePointers.push(data.length);
      data.push(frame.returnPC);
      data.push(frame.storeVariable ?? -1);
      data.push(frame.argumentCount);
      data.push(frame.locals.length);
      data.push(...frame.locals);
      data.push(frame.evalStack.length);
      data.push(...frame.evalStack);
    }
    return { data, framePointers };
  }
  /**
   * Deserialize stack from undo format
   */
  deserialize(serialized) {
    const { data, framePointers } = serialized;
    this.frames.length = 0;
    for (const ptr of framePointers) {
      let i = ptr;
      const returnPC = data[i++];
      const storeVar = data[i++];
      const storeVariable = storeVar === -1 ? void 0 : storeVar;
      const argumentCount = data[i++];
      const localCount = data[i++];
      const locals = [];
      for (let j = 0; j < localCount; j++) {
        locals.push(data[i++]);
      }
      const stackLen = data[i++];
      const evalStack = [];
      for (let j = 0; j < stackLen; j++) {
        evalStack.push(data[i++]);
      }
      const frame = new StackFrame(returnPC, storeVariable, localCount, argumentCount);
      frame.initializeLocals(locals);
      frame.restoreStack(evalStack);
      this.frames.push(frame);
    }
  }
};

// node_modules/zmachine/dist/core/variables/Variables.js
var Variables = class {
  memory;
  stack;
  globalsAddress;
  /**
   * Create a Variables manager
   *
   * @param memory - The Z-machine memory
   * @param stack - The call stack
   * @param globalsAddress - Address of the global variables table
   */
  constructor(memory, stack, globalsAddress) {
    this.memory = memory;
    this.stack = stack;
    this.globalsAddress = globalsAddress;
  }
  /**
   * Read a variable value
   *
   * @param variable - Variable number (0-255)
   * @returns The variable value (16-bit)
   */
  read(variable) {
    if (variable < 0 || variable > 255) {
      throw new Error(`Invalid variable number: ${variable}`);
    }
    if (variable === 0) {
      return this.stack.pop();
    } else if (variable <= 15) {
      return this.stack.currentFrame.getLocal(variable - 1);
    } else {
      const offset = (variable - 16) * 2;
      return this.memory.readWord(this.globalsAddress + offset);
    }
  }
  /**
   * Read a variable value without popping from stack
   * Used for indirect reads where we need the value but shouldn't modify stack
   *
   * @param variable - Variable number (0-255)
   * @returns The variable value (16-bit)
   */
  peek(variable) {
    if (variable < 0 || variable > 255) {
      throw new Error(`Invalid variable number: ${variable}`);
    }
    if (variable === 0) {
      return this.stack.peek();
    } else if (variable <= 15) {
      return this.stack.currentFrame.getLocal(variable - 1);
    } else {
      const offset = (variable - 16) * 2;
      return this.memory.readWord(this.globalsAddress + offset);
    }
  }
  /**
   * Write a variable value
   *
   * @param variable - Variable number (0-255)
   * @param value - Value to write (16-bit)
   */
  write(variable, value) {
    if (variable < 0 || variable > 255) {
      throw new Error(`Invalid variable number: ${variable}`);
    }
    const maskedValue = value & 65535;
    if (variable === 0) {
      this.stack.push(maskedValue);
    } else if (variable <= 15) {
      this.stack.currentFrame.setLocal(variable - 1, maskedValue);
    } else {
      const offset = (variable - 16) * 2;
      this.memory.writeWord(this.globalsAddress + offset, maskedValue);
    }
  }
  /**
   * Store a result value to a variable
   * This is used for instruction store operations
   * For variable 0, it pushes (not replacing top)
   *
   * @param variable - Variable number (0-255)
   * @param value - Value to store (16-bit)
   */
  store(variable, value) {
    this.write(variable, value);
  }
  /**
   * Load a value from a variable for operand evaluation
   * For variable 0, it pops the stack
   *
   * @param variable - Variable number (0-255)
   * @returns The variable value (16-bit)
   */
  load(variable) {
    return this.read(variable);
  }
  /**
   * Increment a variable
   *
   * @param variable - Variable number (0-255)
   */
  increment(variable) {
    const value = this.peek(variable);
    const newValue = value + 1 & 65535;
    if (variable === 0) {
      this.stack.pop();
      this.stack.push(newValue);
    } else {
      this.write(variable, newValue);
    }
  }
  /**
   * Decrement a variable
   *
   * @param variable - Variable number (0-255)
   */
  decrement(variable) {
    const value = this.peek(variable);
    const newValue = value - 1 & 65535;
    if (variable === 0) {
      this.stack.pop();
      this.stack.push(newValue);
    } else {
      this.write(variable, newValue);
    }
  }
  /**
   * Check if a variable number is the stack
   */
  isStack(variable) {
    return variable === 0;
  }
  /**
   * Check if a variable number is a local
   */
  isLocal(variable) {
    return variable >= 1 && variable <= 15;
  }
  /**
   * Check if a variable number is a global
   */
  isGlobal(variable) {
    return variable >= 16 && variable <= 255;
  }
  /**
   * Get the address of a global variable in memory
   */
  getGlobalAddress(variable) {
    if (!this.isGlobal(variable)) {
      throw new Error(`Not a global variable: ${variable}`);
    }
    return this.globalsAddress + (variable - 16) * 2;
  }
};

// node_modules/zmachine/dist/types/ZMachineTypes.js
var TrueColor = {
  /** Keep the current color (do not change) */
  KEEP_CURRENT: 65535,
  /** Use the default color */
  USE_DEFAULT: 65534
};
var OperandType;
(function(OperandType2) {
  OperandType2[OperandType2["LargeConstant"] = 0] = "LargeConstant";
  OperandType2[OperandType2["SmallConstant"] = 1] = "SmallConstant";
  OperandType2[OperandType2["Variable"] = 2] = "Variable";
  OperandType2[OperandType2["Omitted"] = 3] = "Omitted";
})(OperandType || (OperandType = {}));
var InstructionForm;
(function(InstructionForm2) {
  InstructionForm2["Long"] = "long";
  InstructionForm2["Short"] = "short";
  InstructionForm2["Extended"] = "extended";
  InstructionForm2["Variable"] = "variable";
})(InstructionForm || (InstructionForm = {}));
var OperandCount;
(function(OperandCount2) {
  OperandCount2["OP0"] = "0OP";
  OperandCount2["OP1"] = "1OP";
  OperandCount2["OP2"] = "2OP";
  OperandCount2["VAR"] = "VAR";
})(OperandCount || (OperandCount = {}));

// node_modules/zmachine/dist/core/instructions/Opcodes.js
function op(name, operandCount, options = {}) {
  return {
    name,
    operandCount,
    stores: options.stores ?? false,
    branches: options.branches ?? false,
    hasText: options.hasText ?? false,
    minVersion: options.minVersion ?? 1,
    maxVersion: options.maxVersion,
    storesFromVersion: options.storesFromVersion
  };
}
var OPCODES_2OP = {
  // 0x00 is not used
  1: op("je", OperandCount.OP2, { branches: true }),
  // §15: je a b ?(label)
  2: op("jl", OperandCount.OP2, { branches: true }),
  // §15: jl a b ?(label)
  3: op("jg", OperandCount.OP2, { branches: true }),
  // §15: jg a b ?(label)
  4: op("dec_chk", OperandCount.OP2, { branches: true }),
  // §15: dec_chk (variable) value ?(label)
  5: op("inc_chk", OperandCount.OP2, { branches: true }),
  // §15: inc_chk (variable) value ?(label)
  6: op("jin", OperandCount.OP2, { branches: true }),
  // §15: jin obj1 obj2 ?(label)
  7: op("test", OperandCount.OP2, { branches: true }),
  // §15: test bitmap flags ?(label)
  8: op("or", OperandCount.OP2, { stores: true }),
  // §15: or a b -> (result)
  9: op("and", OperandCount.OP2, { stores: true }),
  // §15: and a b -> (result)
  10: op("test_attr", OperandCount.OP2, { branches: true }),
  // §15: test_attr object attribute ?(label)
  11: op("set_attr", OperandCount.OP2),
  // §15: set_attr object attribute
  12: op("clear_attr", OperandCount.OP2),
  // §15: clear_attr object attribute
  13: op("store", OperandCount.OP2),
  // §15: store (variable) value
  14: op("insert_obj", OperandCount.OP2),
  // §15: insert_obj object destination
  15: op("loadw", OperandCount.OP2, { stores: true }),
  // §15: loadw array word-index -> (result)
  16: op("loadb", OperandCount.OP2, { stores: true }),
  // §15: loadb array byte-index -> (result)
  17: op("get_prop", OperandCount.OP2, { stores: true }),
  // §15: get_prop object property -> (result)
  18: op("get_prop_addr", OperandCount.OP2, { stores: true }),
  // §15: get_prop_addr object property -> (result)
  19: op("get_next_prop", OperandCount.OP2, { stores: true }),
  // §15: get_next_prop object property -> (result)
  20: op("add", OperandCount.OP2, { stores: true }),
  // §15: add a b -> (result)
  21: op("sub", OperandCount.OP2, { stores: true }),
  // §15: sub a b -> (result)
  22: op("mul", OperandCount.OP2, { stores: true }),
  // §15: mul a b -> (result)
  23: op("div", OperandCount.OP2, { stores: true }),
  // §15: div a b -> (result)
  24: op("mod", OperandCount.OP2, { stores: true }),
  // §15: mod a b -> (result)
  25: op("call_2s", OperandCount.OP2, { stores: true, minVersion: 4 }),
  // §15: call_2s routine arg1 -> (result)
  26: op("call_2n", OperandCount.OP2, { minVersion: 5 }),
  // §15: call_2n routine arg1
  27: op("set_colour", OperandCount.OP2, { minVersion: 5 }),
  // §15: set_colour foreground background
  28: op("throw", OperandCount.OP2, { minVersion: 5 })
  // §15: throw value stack-frame
};
var OPCODES_1OP = {
  0: op("jz", OperandCount.OP1, { branches: true }),
  // §15: jz a ?(label)
  1: op("get_sibling", OperandCount.OP1, { stores: true, branches: true }),
  // §15: get_sibling object -> (result) ?(label)
  2: op("get_child", OperandCount.OP1, { stores: true, branches: true }),
  // §15: get_child object -> (result) ?(label)
  3: op("get_parent", OperandCount.OP1, { stores: true }),
  // §15: get_parent object -> (result)
  4: op("get_prop_len", OperandCount.OP1, { stores: true }),
  // §15: get_prop_len property-address -> (result)
  5: op("inc", OperandCount.OP1),
  // §15: inc (variable)
  6: op("dec", OperandCount.OP1),
  // §15: dec (variable)
  7: op("print_addr", OperandCount.OP1),
  // §15: print_addr byte-address-of-string
  8: op("call_1s", OperandCount.OP1, { stores: true, minVersion: 4 }),
  // §15: call_1s routine -> (result)
  9: op("remove_obj", OperandCount.OP1),
  // §15: remove_obj object
  10: op("print_obj", OperandCount.OP1),
  // §15: print_obj object
  11: op("ret", OperandCount.OP1),
  // §15: ret value
  12: op("jump", OperandCount.OP1),
  // §15: jump ?(label) -- note: unconditional, signed offset
  13: op("print_paddr", OperandCount.OP1),
  // §15: print_paddr packed-address-of-string
  14: op("load", OperandCount.OP1, { stores: true }),
  // §15: load (variable) -> (result)
  15: op("not", OperandCount.OP1, { stores: true, maxVersion: 4 })
  // §15: not value -> (result) (V1-4 only)
  // Note: In V5+, 0x0F becomes call_1n - handled by version-aware lookup
};
var OPCODES_1OP_V5 = {
  15: op("call_1n", OperandCount.OP1, { minVersion: 5 })
  // §15: call_1n routine
};
var OPCODES_0OP = {
  0: op("rtrue", OperandCount.OP0),
  // §15: rtrue
  1: op("rfalse", OperandCount.OP0),
  // §15: rfalse
  2: op("print", OperandCount.OP0, { hasText: true }),
  // §15: print (literal-string)
  3: op("print_ret", OperandCount.OP0, { hasText: true }),
  // §15: print_ret (literal-string)
  4: op("nop", OperandCount.OP0),
  // §15: nop
  5: op("save", OperandCount.OP0, { branches: true, maxVersion: 3 }),
  // §15: save ?(label) (V1-3)
  6: op("restore", OperandCount.OP0, { branches: true, maxVersion: 3 }),
  // §15: restore ?(label) (V1-3)
  7: op("restart", OperandCount.OP0),
  // §15: restart
  8: op("ret_popped", OperandCount.OP0),
  // §15: ret_popped
  9: op("pop", OperandCount.OP0, { maxVersion: 4 }),
  // §15: pop (V1-4) or catch -> (result) (V5+)
  10: op("quit", OperandCount.OP0),
  // §15: quit
  11: op("new_line", OperandCount.OP0),
  // §15: new_line
  12: op("show_status", OperandCount.OP0, { minVersion: 3, maxVersion: 3 }),
  // §15: show_status (V3 only)
  13: op("verify", OperandCount.OP0, { branches: true, minVersion: 3 }),
  // §15: verify ?(label)
  // 0x0E is the extended opcode prefix (0xBE)
  15: op("piracy", OperandCount.OP0, { branches: true, minVersion: 5 })
  // §15: piracy ?(label)
};
var OPCODES_0OP_V5 = {
  9: op("catch", OperandCount.OP0, { stores: true, minVersion: 5 })
  // §15: catch -> (result)
};
var OPCODES_0OP_V4 = {
  5: op("save", OperandCount.OP0, { stores: true, minVersion: 4, maxVersion: 4 }),
  // §15: save -> (result) (V4)
  6: op("restore", OperandCount.OP0, { stores: true, minVersion: 4, maxVersion: 4 })
  // §15: restore -> (result) (V4)
};
var OPCODES_VAR = {
  0: op("call", OperandCount.VAR, { stores: true }),
  // §15: call routine ...args -> (result) (V1-3) or call_vs
  1: op("storew", OperandCount.VAR),
  // §15: storew array word-index value
  2: op("storeb", OperandCount.VAR),
  // §15: storeb array byte-index value
  3: op("put_prop", OperandCount.VAR),
  // §15: put_prop object property value
  4: op("sread", OperandCount.VAR, { storesFromVersion: 5 }),
  // §15: sread text parse (V1-4) or aread (V5+) stores result
  5: op("print_char", OperandCount.VAR),
  // §15: print_char output-character-code
  6: op("print_num", OperandCount.VAR),
  // §15: print_num value
  7: op("random", OperandCount.VAR, { stores: true }),
  // §15: random range -> (result)
  8: op("push", OperandCount.VAR),
  // §15: push value
  9: op("pull", OperandCount.VAR),
  // §15: pull (variable) (V1-5) or pull stack -> (result) (V6)
  10: op("split_window", OperandCount.VAR, { minVersion: 3 }),
  // §15: split_window lines
  11: op("set_window", OperandCount.VAR, { minVersion: 3 }),
  // §15: set_window window
  12: op("call_vs2", OperandCount.VAR, { stores: true, minVersion: 4 }),
  // §15: call_vs2 routine ...args -> (result)
  13: op("erase_window", OperandCount.VAR, { minVersion: 4 }),
  // §15: erase_window window
  14: op("erase_line", OperandCount.VAR, { minVersion: 4 }),
  // §15: erase_line value
  15: op("set_cursor", OperandCount.VAR, { minVersion: 4 }),
  // §15: set_cursor line column
  16: op("get_cursor", OperandCount.VAR, { minVersion: 4 }),
  // §15: get_cursor array
  17: op("set_text_style", OperandCount.VAR, { minVersion: 4 }),
  // §15: set_text_style style
  18: op("buffer_mode", OperandCount.VAR, { minVersion: 4 }),
  // §15: buffer_mode flag
  19: op("output_stream", OperandCount.VAR, { minVersion: 3 }),
  // §15: output_stream number
  20: op("input_stream", OperandCount.VAR, { minVersion: 3 }),
  // §15: input_stream number
  21: op("sound_effect", OperandCount.VAR, { minVersion: 3 }),
  // §15: sound_effect number
  22: op("read_char", OperandCount.VAR, { stores: true, minVersion: 4 }),
  // §15: read_char 1 time routine -> (result)
  23: op("scan_table", OperandCount.VAR, { stores: true, branches: true, minVersion: 4 }),
  // §15: scan_table x table len form -> (result)
  24: op("not", OperandCount.VAR, { stores: true, minVersion: 5 }),
  // §15: not value -> (result) (V5+)
  25: op("call_vn", OperandCount.VAR, { minVersion: 5 }),
  // §15: call_vn routine ...args
  26: op("call_vn2", OperandCount.VAR, { minVersion: 5 }),
  // §15: call_vn2 routine ...args
  27: op("tokenise", OperandCount.VAR, { minVersion: 5 }),
  // §15: tokenise text parse dictionary flag
  28: op("encode_text", OperandCount.VAR, { minVersion: 5 }),
  // §15: encode_text zscii-text length from coded-text
  29: op("copy_table", OperandCount.VAR, { minVersion: 5 }),
  // §15: copy_table first second size
  30: op("print_table", OperandCount.VAR, { minVersion: 5 }),
  // §15: print_table zscii-text width height skip
  31: op("check_arg_count", OperandCount.VAR, { branches: true, minVersion: 5 })
  // §15: check_arg_count argument-number
};
var OPCODES_EXT = {
  0: op("save", OperandCount.VAR, { stores: true, minVersion: 5 }),
  // §15: save table bytes name -> (result)
  1: op("restore", OperandCount.VAR, { stores: true, minVersion: 5 }),
  // §15: restore table bytes name -> (result)
  2: op("log_shift", OperandCount.VAR, { stores: true, minVersion: 5 }),
  // §15: log_shift number places -> (result)
  3: op("art_shift", OperandCount.VAR, { stores: true, minVersion: 5 }),
  // §15: art_shift number places -> (result)
  4: op("set_font", OperandCount.VAR, { stores: true, minVersion: 5 }),
  // §15: set_font font -> (result)
  // 0x05-0x08 are V6 graphics opcodes
  9: op("save_undo", OperandCount.VAR, { stores: true, minVersion: 5 }),
  // §15: save_undo -> (result)
  10: op("restore_undo", OperandCount.VAR, { stores: true, minVersion: 5 }),
  // §15: restore_undo -> (result)
  11: op("print_unicode", OperandCount.VAR, { minVersion: 5 }),
  // §15: print_unicode char-code
  12: op("check_unicode", OperandCount.VAR, { stores: true, minVersion: 5 }),
  // §15: check_unicode char-code -> (result)
  13: op("set_true_colour", OperandCount.VAR, { minVersion: 5 })
  // §15: set_true_colour foreground background
};
function get2OPInfo(opcode) {
  return OPCODES_2OP[opcode];
}
function get1OPInfo(opcode, version = 3) {
  if (version >= 5 && opcode in OPCODES_1OP_V5) {
    return OPCODES_1OP_V5[opcode];
  }
  return OPCODES_1OP[opcode];
}
function get0OPInfo(opcode, version = 3) {
  if (version >= 5 && opcode in OPCODES_0OP_V5) {
    return OPCODES_0OP_V5[opcode];
  }
  if (version === 4 && opcode in OPCODES_0OP_V4) {
    return OPCODES_0OP_V4[opcode];
  }
  if (version >= 5 && (opcode === 5 || opcode === 6)) {
    return void 0;
  }
  return OPCODES_0OP[opcode];
}
function getVARInfo(opcode) {
  return OPCODES_VAR[opcode];
}
function getEXTInfo(opcode) {
  return OPCODES_EXT[opcode];
}

// node_modules/zmachine/dist/core/instructions/Decoder.js
var Decoder = class {
  memory;
  version;
  /** Text decoder function (injected to avoid circular dependency) */
  textDecoder;
  constructor(memory, version) {
    this.memory = memory;
    this.version = version;
  }
  /**
   * Set the text decoder function (called by ZMachine after text module is ready)
   */
  setTextDecoder(decoder) {
    this.textDecoder = decoder;
  }
  /**
   * Decode the instruction at the given address
   *
   * @param address - Starting address of the instruction
   * @returns Decoded instruction with all fields populated
   */
  decode(address) {
    let offset = 0;
    const opcodeByte = this.memory.readByte(address);
    offset++;
    const form = this.determineForm(opcodeByte);
    let instruction;
    switch (form) {
      case InstructionForm.Extended:
        instruction = this.decodeExtended(address, offset);
        break;
      case InstructionForm.Variable:
        instruction = this.decodeVariable(address, offset, opcodeByte);
        break;
      case InstructionForm.Short:
        instruction = this.decodeShort(address, offset, opcodeByte);
        break;
      case InstructionForm.Long:
        instruction = this.decodeLong(address, offset, opcodeByte);
        break;
    }
    return instruction;
  }
  /**
   * Determine instruction form from opcode byte
   */
  determineForm(opcodeByte) {
    if (opcodeByte === 190 && this.version >= 5) {
      return InstructionForm.Extended;
    }
    if ((opcodeByte & 192) === 192) {
      return InstructionForm.Variable;
    }
    if ((opcodeByte & 192) === 128) {
      return InstructionForm.Short;
    }
    return InstructionForm.Long;
  }
  /**
   * Decode a long-form instruction (always 2OP)
   *
   * Bits 6-5 encode operand types:
   * - Bit 6: first operand (0=small constant, 1=variable)
   * - Bit 5: second operand (0=small constant, 1=variable)
   * Bits 4-0: opcode number
   */
  decodeLong(address, offset, opcodeByte) {
    const opcode = opcodeByte & 31;
    const opcodeInfo = get2OPInfo(opcode);
    const type1 = opcodeByte & 64 ? OperandType.Variable : OperandType.SmallConstant;
    const type2 = opcodeByte & 32 ? OperandType.Variable : OperandType.SmallConstant;
    const operand1Value = this.memory.readByte(address + offset);
    offset++;
    const operand2Value = this.memory.readByte(address + offset);
    offset++;
    const operands = [
      { type: type1, value: operand1Value },
      { type: type2, value: operand2Value }
    ];
    return this.finishDecode(address, offset, opcode, InstructionForm.Long, OperandCount.OP2, operands, opcodeInfo);
  }
  /**
   * Decode a short-form instruction (0OP or 1OP)
   *
   * Bits 5-4 encode operand type:
   * - 00: Large constant (2 bytes)
   * - 01: Small constant (1 byte)
   * - 10: Variable (1 byte)
   * - 11: No operand (0OP)
   * Bits 3-0: opcode number
   */
  decodeShort(address, offset, opcodeByte) {
    const opcode = opcodeByte & 15;
    const operandTypeBits = opcodeByte >> 4 & 3;
    const operands = [];
    let operandCount;
    let opcodeInfo;
    if (operandTypeBits === 3) {
      operandCount = OperandCount.OP0;
      opcodeInfo = get0OPInfo(opcode, this.version);
    } else {
      operandCount = OperandCount.OP1;
      opcodeInfo = get1OPInfo(opcode, this.version);
      const operandType = this.bitsToOperandType(operandTypeBits);
      const { value, bytesRead } = this.readOperand(address + offset, operandType);
      offset += bytesRead;
      operands.push({ type: operandType, value });
    }
    return this.finishDecode(address, offset, opcode, InstructionForm.Short, operandCount, operands, opcodeInfo);
  }
  /**
   * Decode a variable-form instruction (2OP or VAR)
   *
   * Bit 5 determines operand count:
   * - 0: 2OP (but with variable operand types)
   * - 1: VAR
   * Bits 4-0: opcode number
   *
   * Following byte(s) encode operand types (2 bits each)
   */
  decodeVariable(address, offset, opcodeByte) {
    const opcode = opcodeByte & 31;
    const isVAR = (opcodeByte & 32) !== 0;
    const hasDoubleTypes = isVAR && (opcode === 12 || opcode === 26);
    const typeByte1 = this.memory.readByte(address + offset);
    offset++;
    let typeByte2 = 255;
    if (hasDoubleTypes) {
      typeByte2 = this.memory.readByte(address + offset);
      offset++;
    }
    const operands = this.readOperandsFromTypeBytes(address, offset, typeByte1, typeByte2);
    offset += operands.bytesRead;
    const operandCount = isVAR ? OperandCount.VAR : OperandCount.OP2;
    const opcodeInfo = isVAR ? getVARInfo(opcode) : get2OPInfo(opcode);
    return this.finishDecode(address, offset, opcode, InstructionForm.Variable, operandCount, operands.operands, opcodeInfo);
  }
  /**
   * Decode an extended-form instruction (V5+, always VAR)
   *
   * Opcode byte is 0xBE, followed by:
   * - Extended opcode number (1 byte)
   * - Operand types (1 byte)
   * - Operands
   */
  decodeExtended(address, offset) {
    const opcode = this.memory.readByte(address + offset);
    offset++;
    const typeByte = this.memory.readByte(address + offset);
    offset++;
    const operands = this.readOperandsFromTypeBytes(address, offset, typeByte, 255);
    offset += operands.bytesRead;
    const opcodeInfo = getEXTInfo(opcode);
    return this.finishDecode(address, offset, opcode, InstructionForm.Extended, OperandCount.VAR, operands.operands, opcodeInfo);
  }
  /**
   * Finish decoding by reading store, branch, and text if needed
   */
  finishDecode(address, offset, opcode, form, operandCount, operands, opcodeInfo) {
    const instruction = {
      address,
      length: 0,
      // Will be set at end
      opcode,
      opcodeName: opcodeInfo?.name ?? "unknown",
      form,
      operandCount,
      operands
    };
    const storesInThisVersion = opcodeInfo?.stores || opcodeInfo?.storesFromVersion !== void 0 && this.version >= opcodeInfo.storesFromVersion;
    if (storesInThisVersion) {
      instruction.storeVariable = this.memory.readByte(address + offset);
      offset++;
    }
    if (opcodeInfo?.branches) {
      const branchByte1 = this.memory.readByte(address + offset);
      offset++;
      const branchOnTrue = (branchByte1 & 128) !== 0;
      let branchOffset;
      if (branchByte1 & 64) {
        branchOffset = branchByte1 & 63;
      } else {
        const branchByte2 = this.memory.readByte(address + offset);
        offset++;
        branchOffset = (branchByte1 & 63) << 8 | branchByte2;
        if (branchOffset & 8192) {
          branchOffset = branchOffset - 16384;
        }
      }
      instruction.branch = { branchOnTrue, offset: branchOffset };
    }
    if (opcodeInfo?.hasText) {
      if (this.textDecoder) {
        const result = this.textDecoder(address + offset);
        instruction.text = result.text;
        offset += result.bytesConsumed;
      } else {
        const textStart = offset;
        while (true) {
          const word = this.memory.readWord(address + offset);
          offset += 2;
          if (word & 32768)
            break;
        }
        instruction.text = `[text at 0x${(address + textStart).toString(16)}]`;
      }
    }
    instruction.length = offset;
    return instruction;
  }
  /**
   * Convert 2-bit operand type field to OperandType enum
   */
  bitsToOperandType(bits) {
    switch (bits) {
      case 0:
        return OperandType.LargeConstant;
      case 1:
        return OperandType.SmallConstant;
      case 2:
        return OperandType.Variable;
      default:
        return OperandType.Omitted;
    }
  }
  /**
   * Read an operand value based on its type
   */
  readOperand(address, type) {
    switch (type) {
      case OperandType.LargeConstant:
        return { value: this.memory.readWord(address), bytesRead: 2 };
      case OperandType.SmallConstant:
      case OperandType.Variable:
        return { value: this.memory.readByte(address), bytesRead: 1 };
      case OperandType.Omitted:
        return { value: 0, bytesRead: 0 };
    }
  }
  /**
   * Read operands from type bytes (for variable and extended forms)
   */
  readOperandsFromTypeBytes(baseAddress, startOffset, typeByte1, typeByte2) {
    const operands = [];
    let offset = 0;
    for (let i = 0; i < 4; i++) {
      const typeBits = typeByte1 >> 6 - i * 2 & 3;
      const type = this.bitsToOperandType(typeBits);
      if (type === OperandType.Omitted)
        break;
      const { value, bytesRead } = this.readOperand(baseAddress + startOffset + offset, type);
      offset += bytesRead;
      operands.push({ type, value });
    }
    if (typeByte2 !== 255 && operands.length === 4) {
      for (let i = 0; i < 4; i++) {
        const typeBits = typeByte2 >> 6 - i * 2 & 3;
        const type = this.bitsToOperandType(typeBits);
        if (type === OperandType.Omitted)
          break;
        const { value, bytesRead } = this.readOperand(baseAddress + startOffset + offset, type);
        offset += bytesRead;
        operands.push({ type, value });
      }
    }
    return { operands, bytesRead: offset };
  }
};

// node_modules/zmachine/dist/core/memory/AddressUtils.js
function unpackRoutineAddress(packedAddress, version, routineOffset = 0) {
  if (version <= 3) {
    return packedAddress * 2;
  } else if (version <= 5) {
    return packedAddress * 4;
  } else if (version <= 7) {
    return packedAddress * 4 + routineOffset;
  } else {
    return packedAddress * 8;
  }
}
function unpackStringAddress(packedAddress, version, stringOffset = 0) {
  if (version <= 3) {
    return packedAddress * 2;
  } else if (version <= 5) {
    return packedAddress * 4;
  } else if (version <= 7) {
    return packedAddress * 4 + stringOffset;
  } else {
    return packedAddress * 8;
  }
}
function toUnsigned16(value) {
  return value & 65535;
}
function toSigned16(value) {
  const unsigned = value & 65535;
  return unsigned > 32767 ? unsigned - 65536 : unsigned;
}

// node_modules/zmachine/dist/core/objects/ObjectTable.js
var V3_ENTRY_SIZE = 9;
var V3_ATTR_BYTES = 4;
var V3_MAX_OBJECTS = 255;
var V4_ENTRY_SIZE = 14;
var V4_ATTR_BYTES = 6;
var V4_MAX_OBJECTS = 65535;
var ObjectTable = class {
  memory;
  version;
  tableAddress;
  /** Size of each object entry in bytes */
  entrySize;
  /** Number of attribute bytes per object */
  attrBytes;
  /** Maximum number of objects */
  maxObjects;
  /** Address where object entries begin (after property defaults) */
  entriesStart;
  constructor(memory, version, objectTableAddress) {
    this.memory = memory;
    this.version = version;
    this.tableAddress = objectTableAddress;
    if (version <= 3) {
      this.entrySize = V3_ENTRY_SIZE;
      this.attrBytes = V3_ATTR_BYTES;
      this.maxObjects = V3_MAX_OBJECTS;
      this.entriesStart = objectTableAddress + 31 * 2;
    } else {
      this.entrySize = V4_ENTRY_SIZE;
      this.attrBytes = V4_ATTR_BYTES;
      this.maxObjects = V4_MAX_OBJECTS;
      this.entriesStart = objectTableAddress + 63 * 2;
    }
  }
  /**
   * Get the address of an object entry
   * Object numbers are 1-based
   */
  getObjectAddress(objectNum) {
    if (objectNum < 1 || objectNum > this.maxObjects) {
      throw new Error(`Invalid object number: ${objectNum}`);
    }
    return this.entriesStart + (objectNum - 1) * this.entrySize;
  }
  /**
   * Get the parent of an object
   * Returns 0 if object has no parent
   */
  getParent(objectNum) {
    const addr = this.getObjectAddress(objectNum);
    const parentOffset = this.attrBytes;
    if (this.version <= 3) {
      return this.memory.readByte(addr + parentOffset);
    } else {
      return this.memory.readWord(addr + parentOffset);
    }
  }
  /**
   * Set the parent of an object
   */
  setParent(objectNum, parent) {
    const addr = this.getObjectAddress(objectNum);
    const parentOffset = this.attrBytes;
    if (this.version <= 3) {
      this.memory.writeByte(addr + parentOffset, parent);
    } else {
      this.memory.writeWord(addr + parentOffset, parent);
    }
  }
  /**
   * Get the sibling of an object
   * Returns 0 if object has no sibling
   */
  getSibling(objectNum) {
    const addr = this.getObjectAddress(objectNum);
    const siblingOffset = this.attrBytes + (this.version <= 3 ? 1 : 2);
    if (this.version <= 3) {
      return this.memory.readByte(addr + siblingOffset);
    } else {
      return this.memory.readWord(addr + siblingOffset);
    }
  }
  /**
   * Set the sibling of an object
   */
  setSibling(objectNum, sibling) {
    const addr = this.getObjectAddress(objectNum);
    const siblingOffset = this.attrBytes + (this.version <= 3 ? 1 : 2);
    if (this.version <= 3) {
      this.memory.writeByte(addr + siblingOffset, sibling);
    } else {
      this.memory.writeWord(addr + siblingOffset, sibling);
    }
  }
  /**
   * Get the first child of an object
   * Returns 0 if object has no children
   */
  getChild(objectNum) {
    const addr = this.getObjectAddress(objectNum);
    const childOffset = this.attrBytes + (this.version <= 3 ? 2 : 4);
    if (this.version <= 3) {
      return this.memory.readByte(addr + childOffset);
    } else {
      return this.memory.readWord(addr + childOffset);
    }
  }
  /**
   * Set the first child of an object
   */
  setChild(objectNum, child) {
    const addr = this.getObjectAddress(objectNum);
    const childOffset = this.attrBytes + (this.version <= 3 ? 2 : 4);
    if (this.version <= 3) {
      this.memory.writeByte(addr + childOffset, child);
    } else {
      this.memory.writeWord(addr + childOffset, child);
    }
  }
  /**
   * Get the property table address for an object
   */
  getPropertyTableAddress(objectNum) {
    const addr = this.getObjectAddress(objectNum);
    const propOffset = this.attrBytes + (this.version <= 3 ? 3 : 6);
    return this.memory.readWord(addr + propOffset);
  }
  /**
   * Test if an attribute is set on an object
   * Attributes are numbered 0 to 31 (V1-3) or 0 to 47 (V4+)
   */
  testAttribute(objectNum, attribute) {
    if (attribute < 0 || attribute >= this.attrBytes * 8) {
      throw new Error(`Invalid attribute number: ${attribute}`);
    }
    const addr = this.getObjectAddress(objectNum);
    const byteIndex = Math.floor(attribute / 8);
    const bitIndex = 7 - attribute % 8;
    const byte = this.memory.readByte(addr + byteIndex);
    return (byte & 1 << bitIndex) !== 0;
  }
  /**
   * Set an attribute on an object
   */
  setAttribute(objectNum, attribute) {
    if (attribute < 0 || attribute >= this.attrBytes * 8) {
      throw new Error(`Invalid attribute number: ${attribute}`);
    }
    const addr = this.getObjectAddress(objectNum);
    const byteIndex = Math.floor(attribute / 8);
    const bitIndex = 7 - attribute % 8;
    const byte = this.memory.readByte(addr + byteIndex);
    this.memory.writeByte(addr + byteIndex, byte | 1 << bitIndex);
  }
  /**
   * Clear an attribute on an object
   */
  clearAttribute(objectNum, attribute) {
    if (attribute < 0 || attribute >= this.attrBytes * 8) {
      throw new Error(`Invalid attribute number: ${attribute}`);
    }
    const addr = this.getObjectAddress(objectNum);
    const byteIndex = Math.floor(attribute / 8);
    const bitIndex = 7 - attribute % 8;
    const byte = this.memory.readByte(addr + byteIndex);
    this.memory.writeByte(addr + byteIndex, byte & ~(1 << bitIndex));
  }
  /**
   * Remove an object from its parent's child list
   * This unlinks the object from the tree but doesn't delete it
   */
  removeFromParent(objectNum) {
    const parent = this.getParent(objectNum);
    if (parent === 0) {
      return;
    }
    const child = this.getChild(parent);
    if (child === objectNum) {
      this.setChild(parent, this.getSibling(objectNum));
    } else {
      let prev = child;
      let curr = this.getSibling(prev);
      while (curr !== 0 && curr !== objectNum) {
        prev = curr;
        curr = this.getSibling(curr);
      }
      if (curr === objectNum) {
        this.setSibling(prev, this.getSibling(objectNum));
      }
    }
    this.setParent(objectNum, 0);
    this.setSibling(objectNum, 0);
  }
  /**
   * Insert an object as the first child of a destination object
   */
  insertObject(objectNum, destination) {
    this.removeFromParent(objectNum);
    const oldChild = this.getChild(destination);
    this.setChild(destination, objectNum);
    this.setParent(objectNum, destination);
    this.setSibling(objectNum, oldChild);
  }
  /**
   * Get the short name of an object (from property table header)
   * Returns the address of the short name text and its length in words
   */
  getShortNameAddress(objectNum) {
    const propTableAddr = this.getPropertyTableAddress(objectNum);
    const lengthWords = this.memory.readByte(propTableAddr);
    return {
      address: propTableAddr + 1,
      lengthBytes: lengthWords * 2
    };
  }
  /**
   * Get a property default value
   * Properties 1-31 (V1-3) or 1-63 (V4+) have defaults
   */
  getPropertyDefault(propNum) {
    const maxProps = this.version <= 3 ? 31 : 63;
    if (propNum < 1 || propNum > maxProps) {
      throw new Error(`Invalid property number: ${propNum}`);
    }
    return this.memory.readWord(this.tableAddress + (propNum - 1) * 2);
  }
};

// node_modules/zmachine/dist/core/objects/Properties.js
var Properties = class {
  memory;
  version;
  objectTable;
  constructor(memory, version, objectTable) {
    this.memory = memory;
    this.version = version;
    this.objectTable = objectTable;
  }
  /**
   * Get the address of the first property in an object's property table
   * (after the short name)
   */
  getFirstPropertyAddress(objectNum) {
    const propTableAddr = this.objectTable.getPropertyTableAddress(objectNum);
    const nameLength = this.memory.readByte(propTableAddr);
    return propTableAddr + 1 + nameLength * 2;
  }
  /**
   * Decode a property entry at the given address
   * Returns null if at end of property list (size byte is 0)
   */
  decodePropertyAt(address) {
    const sizeByte = this.memory.readByte(address);
    if (sizeByte === 0) {
      return null;
    }
    if (this.version <= 3) {
      const propNum = sizeByte & 31;
      const propLen = (sizeByte >> 5 & 7) + 1;
      const dataAddr = address + 1;
      return {
        number: propNum,
        address: dataAddr,
        length: propLen,
        nextAddress: dataAddr + propLen
      };
    } else {
      if (sizeByte & 128) {
        const propNum = sizeByte & 63;
        const sizeByte2 = this.memory.readByte(address + 1);
        let propLen = sizeByte2 & 63;
        if (propLen === 0)
          propLen = 64;
        const dataAddr = address + 2;
        return {
          number: propNum,
          address: dataAddr,
          length: propLen,
          nextAddress: dataAddr + propLen
        };
      } else {
        const propNum = sizeByte & 63;
        const propLen = sizeByte & 64 ? 2 : 1;
        const dataAddr = address + 1;
        return {
          number: propNum,
          address: dataAddr,
          length: propLen,
          nextAddress: dataAddr + propLen
        };
      }
    }
  }
  /**
   * Find a specific property in an object's property table
   * Returns null if property not found
   */
  findProperty(objectNum, propNum) {
    let addr = this.getFirstPropertyAddress(objectNum);
    while (true) {
      const prop = this.decodePropertyAt(addr);
      if (prop === null) {
        return null;
      }
      if (prop.number === propNum) {
        return prop;
      }
      if (prop.number < propNum) {
        return null;
      }
      addr = prop.nextAddress;
    }
  }
  /**
   * Get the value of a property
   * If property doesn't exist, returns the default value
   * Only works for 1-2 byte properties
   */
  getProperty(objectNum, propNum) {
    const prop = this.findProperty(objectNum, propNum);
    if (prop === null) {
      return this.objectTable.getPropertyDefault(propNum);
    }
    if (prop.length === 1) {
      return this.memory.readByte(prop.address);
    } else if (prop.length === 2) {
      return this.memory.readWord(prop.address);
    } else {
      return this.memory.readWord(prop.address);
    }
  }
  /**
   * Set the value of a property
   * Property must exist and be 1 or 2 bytes
   */
  putProperty(objectNum, propNum, value) {
    const prop = this.findProperty(objectNum, propNum);
    if (prop === null) {
      throw new Error(`Property ${propNum} not found on object ${objectNum}`);
    }
    if (prop.length === 1) {
      this.memory.writeByte(prop.address, value & 255);
    } else if (prop.length === 2) {
      this.memory.writeWord(prop.address, value & 65535);
    } else {
      throw new Error(`Cannot put_prop on property of length ${prop.length}`);
    }
  }
  /**
   * Get the address of a property's data
   * Returns 0 if property not found
   */
  getPropertyAddress(objectNum, propNum) {
    const prop = this.findProperty(objectNum, propNum);
    return prop ? prop.address : 0;
  }
  /**
   * Get the length of a property given its data address
   * This is used by get_prop_len opcode
   */
  getPropertyLength(propDataAddress) {
    if (propDataAddress === 0) {
      return 0;
    }
    const sizeByte = this.memory.readByte(propDataAddress - 1);
    if (this.version <= 3) {
      return (sizeByte >> 5 & 7) + 1;
    } else {
      if (sizeByte & 128) {
        let len = sizeByte & 63;
        if (len === 0)
          len = 64;
        return len;
      } else {
        return sizeByte & 64 ? 2 : 1;
      }
    }
  }
  /**
   * Get the next property number after the given one
   * If propNum is 0, returns the first property number
   * Returns 0 if no more properties
   */
  getNextProperty(objectNum, propNum) {
    if (propNum === 0) {
      const firstAddr = this.getFirstPropertyAddress(objectNum);
      const prop2 = this.decodePropertyAt(firstAddr);
      return prop2 ? prop2.number : 0;
    }
    const prop = this.findProperty(objectNum, propNum);
    if (prop === null) {
      throw new Error(`Property ${propNum} not found on object ${objectNum}`);
    }
    const nextProp = this.decodePropertyAt(prop.nextAddress);
    return nextProp ? nextProp.number : 0;
  }
};

// node_modules/zmachine/dist/core/dictionary/Dictionary.js
var Dictionary = class {
  memory;
  /** Word separator characters */
  separators;
  /** Number of bytes in each dictionary entry */
  entryLength;
  /** Number of entries in the dictionary */
  entryCount;
  /** Address where dictionary entries begin */
  entriesStart;
  /** Number of bytes used for the encoded word */
  wordBytes;
  constructor(memory, version, dictionaryAddress) {
    this.memory = memory;
    this.wordBytes = version <= 3 ? 4 : 6;
    let offset = dictionaryAddress;
    const separatorCount = memory.readByte(offset++);
    let seps = "";
    for (let i = 0; i < separatorCount; i++) {
      seps += String.fromCharCode(memory.readByte(offset++));
    }
    this.separators = seps;
    this.entryLength = memory.readByte(offset++);
    this.entryCount = memory.readWord(offset);
    offset += 2;
    this.entriesStart = offset;
  }
  /**
   * Check if a character is a word separator
   */
  isSeparator(char) {
    return this.separators.includes(char);
  }
  /**
   * Get the address of a dictionary entry by index
   */
  getEntryAddress(index) {
    if (index < 0 || index >= this.entryCount) {
      throw new Error(`Invalid dictionary index: ${index}`);
    }
    return this.entriesStart + index * this.entryLength;
  }
  /**
   * Read the encoded word bytes at an entry address
   */
  readEncodedWord(address) {
    const bytes = [];
    for (let i = 0; i < this.wordBytes; i++) {
      bytes.push(this.memory.readByte(address + i));
    }
    return bytes;
  }
  /**
   * Compare two encoded words
   * Returns <0 if a < b, 0 if equal, >0 if a > b
   */
  compareEncodedWords(a, b) {
    for (let i = 0; i < this.wordBytes; i++) {
      if (a[i] !== b[i]) {
        return a[i] - b[i];
      }
    }
    return 0;
  }
  /**
   * Look up a word in the dictionary using binary search
   * @param encodedWord The encoded word bytes to search for
   * @returns The dictionary entry address, or 0 if not found
   */
  lookup(encodedWord) {
    let low = 0;
    let high = this.entryCount - 1;
    while (low <= high) {
      const mid = Math.floor((low + high) / 2);
      const entryAddr = this.getEntryAddress(mid);
      const entryWord = this.readEncodedWord(entryAddr);
      const cmp = this.compareEncodedWords(encodedWord, entryWord);
      if (cmp === 0) {
        return entryAddr;
      } else if (cmp < 0) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }
    return 0;
  }
  /**
   * Look up a word and return detailed entry info
   */
  lookupEntry(encodedWord) {
    let low = 0;
    let high = this.entryCount - 1;
    while (low <= high) {
      const mid = Math.floor((low + high) / 2);
      const entryAddr = this.getEntryAddress(mid);
      const entryWord = this.readEncodedWord(entryAddr);
      const cmp = this.compareEncodedWords(encodedWord, entryWord);
      if (cmp === 0) {
        return { address: entryAddr, index: mid };
      } else if (cmp < 0) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }
    return { address: 0, index: -1 };
  }
  /**
   * Iterate over all dictionary entries
   */
  *entries() {
    for (let i = 0; i < this.entryCount; i++) {
      const address = this.getEntryAddress(i);
      yield {
        address,
        index: i,
        encodedWord: this.readEncodedWord(address)
      };
    }
  }
};

// node_modules/zmachine/dist/core/text/Alphabet.js
var ALPHABET_A0 = "abcdefghijklmnopqrstuvwxyz";
var ALPHABET_A1 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
var ALPHABET_A2_V1 = ` 0123456789.,!?_#'"/\\<-:()`;
var ALPHABET_A2 = ` 
0123456789.,!?_#'"/\\-:()`;
function getAlphabetChar(zchar, alphabet, version, customAlphabets) {
  if (zchar < 6) {
    return null;
  }
  const index = zchar - 6;
  if (customAlphabets) {
    return customAlphabets[alphabet].charAt(index) || null;
  }
  switch (alphabet) {
    case 0:
      return ALPHABET_A0.charAt(index) || null;
    case 1:
      return ALPHABET_A1.charAt(index) || null;
    case 2:
      if (version === 1) {
        return ALPHABET_A2_V1.charAt(index) || null;
      }
      if (zchar === 6) {
        return null;
      }
      return ALPHABET_A2.charAt(index) || null;
    default:
      return null;
  }
}
var ShiftType;
(function(ShiftType2) {
  ShiftType2[ShiftType2["None"] = 0] = "None";
  ShiftType2[ShiftType2["Single"] = 1] = "Single";
  ShiftType2[ShiftType2["Lock"] = 2] = "Lock";
})(ShiftType || (ShiftType = {}));
function getShiftedAlphabet(currentAlphabet, shiftChar, version) {
  if (version <= 2) {
    if (shiftChar === 4) {
      return (currentAlphabet + 1) % 3;
    } else {
      return (currentAlphabet + 2) % 3;
    }
  } else {
    return shiftChar === 4 ? 1 : 2;
  }
}
function getAbbreviationIndex(prefixChar, indexChar) {
  return 32 * (prefixChar - 1) + indexChar;
}

// node_modules/zmachine/dist/core/text/ZCharEncoder.js
function getAlphabets(version) {
  const a2 = version === 1 ? ALPHABET_A2_V1 : ALPHABET_A2;
  return [ALPHABET_A0, ALPHABET_A1, a2];
}
function findInAlphabets(char, alphabets) {
  for (let a = 0; a < 3; a++) {
    const idx = alphabets[a].indexOf(char);
    if (idx !== -1) {
      return [a, idx];
    }
  }
  return null;
}
function encodeChar(char, alphabets) {
  const found = findInAlphabets(char, alphabets);
  if (found !== null) {
    const [alphabet, index] = found;
    const zcode = 6 + index;
    if (alphabet === 0) {
      return [zcode];
    } else if (alphabet === 1) {
      return [4, zcode];
    } else {
      return [5, zcode];
    }
  }
  const zscii = char.charCodeAt(0);
  const high = zscii >> 5 & 31;
  const low = zscii & 31;
  return [5, 6, high, low];
}
function encodeText(text, version) {
  const alphabets = getAlphabets(version);
  const zchars = [];
  const lowerText = text.toLowerCase();
  const maxZChars = version <= 3 ? 6 : 9;
  for (const char of lowerText) {
    if (zchars.length >= maxZChars)
      break;
    const encoded = encodeChar(char, alphabets);
    for (const zc of encoded) {
      if (zchars.length >= maxZChars)
        break;
      zchars.push(zc);
    }
  }
  while (zchars.length < maxZChars) {
    zchars.push(5);
  }
  const bytes = [];
  const wordCount = version <= 3 ? 2 : 3;
  for (let w = 0; w < wordCount; w++) {
    const c0 = zchars[w * 3];
    const c1 = zchars[w * 3 + 1];
    const c2 = zchars[w * 3 + 2];
    let word = (c0 & 31) << 10 | (c1 & 31) << 5 | c2 & 31;
    if (w === wordCount - 1) {
      word |= 32768;
    }
    bytes.push(word >> 8 & 255);
    bytes.push(word & 255);
  }
  return bytes;
}
function encodeToZChars(text, version) {
  const alphabets = getAlphabets(version);
  const zchars = [];
  const lowerText = text.toLowerCase();
  const maxZChars = version <= 3 ? 6 : 9;
  for (const char of lowerText) {
    if (zchars.length >= maxZChars)
      break;
    const encoded = encodeChar(char, alphabets);
    for (const zc of encoded) {
      if (zchars.length >= maxZChars)
        break;
      zchars.push(zc);
    }
  }
  while (zchars.length < maxZChars) {
    zchars.push(5);
  }
  return zchars;
}

// node_modules/zmachine/dist/core/dictionary/Tokenizer.js
var Tokenizer = class {
  memory;
  version;
  dictionary;
  constructor(memory, version, dictionary) {
    this.memory = memory;
    this.version = version;
    this.dictionary = dictionary;
  }
  /**
   * Tokenize an input string
   * @param input The player's input string
   * @returns Array of tokens
   */
  tokenize(input) {
    const tokens = [];
    const lowerInput = input.toLowerCase();
    let pos = 0;
    while (pos < lowerInput.length) {
      while (pos < lowerInput.length && lowerInput[pos] === " ") {
        pos++;
      }
      if (pos >= lowerInput.length)
        break;
      if (this.dictionary.isSeparator(lowerInput[pos])) {
        const sepText = lowerInput[pos];
        const encoded2 = encodeText(sepText, this.version);
        const dictAddr2 = this.dictionary.lookup(encoded2);
        tokens.push({
          text: sepText,
          position: pos,
          length: 1,
          dictionaryAddress: dictAddr2
        });
        pos++;
        continue;
      }
      const wordStart = pos;
      while (pos < lowerInput.length && lowerInput[pos] !== " " && !this.dictionary.isSeparator(lowerInput[pos])) {
        pos++;
      }
      const wordText = lowerInput.slice(wordStart, pos);
      const encoded = encodeText(wordText, this.version);
      const dictAddr = this.dictionary.lookup(encoded);
      tokens.push({
        text: wordText,
        position: wordStart,
        length: pos - wordStart,
        dictionaryAddress: dictAddr
      });
    }
    return tokens;
  }
  /**
   * Tokenize input from a text buffer and write results to a parse buffer
   * This is used by the `read` opcode
   *
   * @param textBuffer Address of text buffer (V1-4: byte 0 = max chars, byte 1+ = text;
   *                   V5+: byte 0 = max chars, byte 1 = actual length, byte 2+ = text)
   * @param parseBuffer Address of parse buffer (byte 0 = max tokens, byte 1 = token count)
   * @param dictionaryAddr Optional custom dictionary address (0 = use default)
   * @param skipUnknown If true, don't store tokens not in dictionary
   */
  tokenizeBuffer(textBuffer, parseBuffer, dictionaryAddr = 0, skipUnknown = false) {
    let text;
    let textStart;
    if (this.version <= 4) {
      textStart = 1;
      let chars = "";
      let offset = 1;
      while (true) {
        const c = this.memory.readByte(textBuffer + offset);
        if (c === 0)
          break;
        chars += String.fromCharCode(c);
        offset++;
      }
      text = chars;
    } else {
      textStart = 2;
      const length = this.memory.readByte(textBuffer + 1);
      let chars = "";
      for (let i = 0; i < length; i++) {
        chars += String.fromCharCode(this.memory.readByte(textBuffer + 2 + i));
      }
      text = chars;
    }
    const dict = dictionaryAddr !== 0 ? new Dictionary(this.memory, this.version, dictionaryAddr) : this.dictionary;
    const tokens = this.tokenizeWithDictionary(text, dict);
    const maxTokens = this.memory.readByte(parseBuffer);
    let tokenCount = 0;
    for (const token of tokens) {
      if (tokenCount >= maxTokens)
        break;
      if (skipUnknown && token.dictionaryAddress === 0) {
        continue;
      }
      const tokenAddr = parseBuffer + 2 + tokenCount * 4;
      this.memory.writeWord(tokenAddr, token.dictionaryAddress);
      this.memory.writeByte(tokenAddr + 2, token.length);
      this.memory.writeByte(tokenAddr + 3, token.position + textStart);
      tokenCount++;
    }
    this.memory.writeByte(parseBuffer + 1, tokenCount);
  }
  /**
   * Tokenize with a specific dictionary
   */
  tokenizeWithDictionary(input, dict) {
    const tokens = [];
    const lowerInput = input.toLowerCase();
    let pos = 0;
    while (pos < lowerInput.length) {
      while (pos < lowerInput.length && lowerInput[pos] === " ") {
        pos++;
      }
      if (pos >= lowerInput.length)
        break;
      if (dict.isSeparator(lowerInput[pos])) {
        const sepText = lowerInput[pos];
        const encoded2 = encodeText(sepText, this.version);
        const dictAddr2 = dict.lookup(encoded2);
        tokens.push({
          text: sepText,
          position: pos,
          length: 1,
          dictionaryAddress: dictAddr2
        });
        pos++;
        continue;
      }
      const wordStart = pos;
      while (pos < lowerInput.length && lowerInput[pos] !== " " && !dict.isSeparator(lowerInput[pos])) {
        pos++;
      }
      const wordText = lowerInput.slice(wordStart, pos);
      const encoded = encodeText(wordText, this.version);
      const dictAddr = dict.lookup(encoded);
      tokens.push({
        text: wordText,
        position: wordStart,
        length: pos - wordStart,
        dictionaryAddress: dictAddr
      });
    }
    return tokens;
  }
};

// node_modules/zmachine/dist/core/state/Quetzal.js
function writeUint32BE(arr, offset, value) {
  arr[offset] = value >> 24 & 255;
  arr[offset + 1] = value >> 16 & 255;
  arr[offset + 2] = value >> 8 & 255;
  arr[offset + 3] = value & 255;
}
function writeUint16BE(arr, offset, value) {
  arr[offset] = value >> 8 & 255;
  arr[offset + 1] = value & 255;
}
function readUint32BE(arr, offset) {
  return arr[offset] << 24 | arr[offset + 1] << 16 | arr[offset + 2] << 8 | arr[offset + 3];
}
function readUint16BE(arr, offset) {
  return arr[offset] << 8 | arr[offset + 1];
}
function stringToBytes(str) {
  const bytes = new Uint8Array(str.length);
  for (let i = 0; i < str.length; i++) {
    bytes[i] = str.charCodeAt(i);
  }
  return bytes;
}
function bytesToString(arr, offset, length) {
  let str = "";
  for (let i = 0; i < length; i++) {
    str += String.fromCharCode(arr[offset + i]);
  }
  return str;
}
function compressMemory(current, original) {
  const result = [];
  let i = 0;
  while (i < current.length) {
    const xored = current[i] ^ original[i];
    if (xored === 0) {
      let zeroCount = 1;
      while (i + zeroCount < current.length && zeroCount < 256 && (current[i + zeroCount] ^ original[i + zeroCount]) === 0) {
        zeroCount++;
      }
      result.push(0);
      result.push(zeroCount - 1);
      i += zeroCount;
    } else {
      result.push(xored);
      i++;
    }
  }
  return new Uint8Array(result);
}
function createIFhdChunk(gameId) {
  const data = new Uint8Array(13);
  writeUint16BE(data, 0, gameId.release);
  for (let i = 0; i < 6; i++) {
    data[2 + i] = gameId.serial.charCodeAt(i);
  }
  writeUint16BE(data, 8, gameId.checksum);
  data[10] = gameId.pc >> 16 & 255;
  data[11] = gameId.pc >> 8 & 255;
  data[12] = gameId.pc & 255;
  return data;
}
function parseIFhdChunk(data) {
  if (data.length < 13) {
    throw new Error("IFhd chunk too short");
  }
  const release = readUint16BE(data, 0);
  const serial = bytesToString(data, 2, 6);
  const checksum = readUint16BE(data, 8);
  const pc = data[10] << 16 | data[11] << 8 | data[12];
  return { release, serial, checksum, pc };
}
function createStksChunk(stack) {
  const parts = [];
  for (const frame of stack.frames) {
    const localsSize = frame.locals.length * 2;
    const stackSize = frame.evalStack.length * 2;
    const frameSize = 8 + localsSize + stackSize;
    const frameData = new Uint8Array(frameSize);
    let offset2 = 0;
    frameData[offset2++] = frame.returnPC >> 16 & 255;
    frameData[offset2++] = frame.returnPC >> 8 & 255;
    frameData[offset2++] = frame.returnPC & 255;
    let flags = frame.locals.length & 15;
    if (frame.storeVariable === void 0) {
      flags |= 16;
    }
    frameData[offset2++] = flags;
    frameData[offset2++] = frame.storeVariable ?? 0;
    let argMask = 0;
    for (let i = 0; i < frame.argumentCount && i < 7; i++) {
      argMask |= 1 << i;
    }
    frameData[offset2++] = argMask;
    writeUint16BE(frameData, offset2, frame.evalStack.length);
    offset2 += 2;
    for (const local of frame.locals) {
      writeUint16BE(frameData, offset2, local);
      offset2 += 2;
    }
    for (const value of frame.evalStack) {
      writeUint16BE(frameData, offset2, value);
      offset2 += 2;
    }
    parts.push(frameData);
  }
  const totalSize = parts.reduce((sum, p) => sum + p.length, 0);
  const result = new Uint8Array(totalSize);
  let offset = 0;
  for (const part of parts) {
    result.set(part, offset);
    offset += part.length;
  }
  return result;
}
function parseStksChunk(data) {
  const frames = [];
  let offset = 0;
  while (offset < data.length) {
    const returnPC = data[offset] << 16 | data[offset + 1] << 8 | data[offset + 2];
    offset += 3;
    const flags = data[offset++];
    const localCount = flags & 15;
    const discardResult = (flags & 16) !== 0;
    const storeVarByte = data[offset++];
    const storeVariable = discardResult ? void 0 : storeVarByte;
    const argMask = data[offset++];
    let argumentCount = 0;
    for (let i = 0; i < 7; i++) {
      if (argMask & 1 << i) {
        argumentCount = i + 1;
      }
    }
    const evalStackSize = readUint16BE(data, offset);
    offset += 2;
    const locals = [];
    for (let i = 0; i < localCount; i++) {
      locals.push(readUint16BE(data, offset));
      offset += 2;
    }
    const evalStack = [];
    for (let i = 0; i < evalStackSize; i++) {
      evalStack.push(readUint16BE(data, offset));
      offset += 2;
    }
    frames.push({
      returnPC,
      storeVariable,
      argumentCount,
      locals,
      evalStack
    });
  }
  return { frames };
}
function createQuetzalSave(memory, stack, pc, originalMemory) {
  const view = memory.getView();
  const release = view.getUint16(2, false);
  const serial = bytesToString(new Uint8Array(memory.getBuffer(), 18, 6), 0, 6);
  const checksum = view.getUint16(28, false);
  const gameId = { release, serial, checksum, pc };
  const ifhdData = createIFhdChunk(gameId);
  const staticBase = memory.staticBase;
  let memChunk;
  if (originalMemory && originalMemory.length >= staticBase) {
    const currentMem = new Uint8Array(memory.getBuffer(), 0, staticBase);
    const cmemData = compressMemory(currentMem, originalMemory);
    memChunk = { type: "CMem", data: cmemData };
  } else {
    const umemData = new Uint8Array(staticBase);
    for (let i = 0; i < staticBase; i++) {
      umemData[i] = memory.readByte(i);
    }
    memChunk = { type: "UMem", data: umemData };
  }
  const stksData = createStksChunk(stack);
  const chunks = [
    { type: "IFhd", data: ifhdData },
    memChunk,
    { type: "Stks", data: stksData }
  ];
  let chunksSize = 4;
  for (const chunk of chunks) {
    chunksSize += 8 + chunk.data.length;
    if (chunk.data.length % 2 === 1) {
      chunksSize++;
    }
  }
  const totalSize = 8 + chunksSize;
  const result = new Uint8Array(totalSize);
  let offset = 0;
  result.set(stringToBytes("FORM"), offset);
  offset += 4;
  writeUint32BE(result, offset, chunksSize);
  offset += 4;
  result.set(stringToBytes("IFZS"), offset);
  offset += 4;
  for (const chunk of chunks) {
    result.set(stringToBytes(chunk.type), offset);
    offset += 4;
    writeUint32BE(result, offset, chunk.data.length);
    offset += 4;
    result.set(chunk.data, offset);
    offset += chunk.data.length;
    if (chunk.data.length % 2 === 1) {
      result[offset++] = 0;
    }
  }
  return result;
}
function parseQuetzalSave(data) {
  if (data.length < 12) {
    throw new Error("Save file too short");
  }
  const formType = bytesToString(data, 0, 4);
  if (formType !== "FORM") {
    throw new Error("Not an IFF file");
  }
  const formSize = readUint32BE(data, 4);
  if (formSize + 8 > data.length) {
    throw new Error("IFF file truncated");
  }
  const ifzsType = bytesToString(data, 8, 4);
  if (ifzsType !== "IFZS") {
    throw new Error("Not a Quetzal save file");
  }
  let gameId = null;
  let dynamicMemory = null;
  let callStack = null;
  let isCompressed = false;
  let offset = 12;
  while (offset < data.length) {
    const chunkType = bytesToString(data, offset, 4);
    offset += 4;
    const chunkSize = readUint32BE(data, offset);
    offset += 4;
    const chunkData = data.slice(offset, offset + chunkSize);
    offset += chunkSize;
    if (chunkSize % 2 === 1) {
      offset++;
    }
    switch (chunkType) {
      case "IFhd":
        gameId = parseIFhdChunk(chunkData);
        break;
      case "CMem":
        dynamicMemory = chunkData;
        isCompressed = true;
        break;
      case "UMem":
        dynamicMemory = chunkData;
        isCompressed = false;
        break;
      case "Stks":
        callStack = parseStksChunk(chunkData);
        break;
    }
  }
  if (!gameId) {
    throw new Error("Missing IFhd chunk");
  }
  if (!dynamicMemory) {
    throw new Error("Missing memory chunk (CMem or UMem)");
  }
  if (!callStack) {
    throw new Error("Missing Stks chunk");
  }
  return {
    gameId,
    dynamicMemory,
    isCompressed,
    callStack
  };
}
function verifySaveCompatibility(save, memory) {
  const view = memory.getView();
  const release = view.getUint16(2, false);
  const serial = bytesToString(new Uint8Array(memory.getBuffer(), 18, 6), 0, 6);
  const checksum = view.getUint16(28, false);
  return save.gameId.release === release && save.gameId.serial === serial && save.gameId.checksum === checksum;
}

// node_modules/zmachine/dist/core/execution/Executor.js
var Executor = class {
  memory;
  header;
  stack;
  variables;
  version;
  io;
  textDecoder;
  objectTable;
  properties;
  dictionary;
  tokenizer;
  /** Whether debug tracking is enabled */
  debugEnabled;
  handlers = /* @__PURE__ */ new Map();
  // Output stream state
  streamEnabled = [false, true, false, false, false];
  // Streams 1-4 (index 0 unused)
  stream3Stack = [];
  // Memory stream is stackable
  constructor(memory, header, stack, variables, version, io, textDecoder, objectTable, properties, dictionary, tokenizer, options) {
    this.memory = memory;
    this.header = header;
    this.stack = stack;
    this.variables = variables;
    this.version = version;
    this.io = io;
    this.textDecoder = textDecoder;
    this.debugEnabled = options?.debug ?? false;
    this.objectTable = objectTable ?? new ObjectTable(memory, version, header.objectTableAddress);
    this.properties = properties ?? new Properties(memory, version, this.objectTable);
    this.dictionary = dictionary ?? new Dictionary(memory, version, header.dictionaryAddress);
    this.tokenizer = tokenizer ?? new Tokenizer(memory, version, this.dictionary);
    this.registerHandlers();
  }
  /** Undo state for save_undo/restore_undo */
  undoState = null;
  // Debug tracking state (only used when debugEnabled is true)
  /** DEBUG: Opcode frequency counter */
  opcodeCount = /* @__PURE__ */ new Map();
  totalOps = 0;
  /** DEBUG: Unknown opcode details */
  unknownOpcodes = /* @__PURE__ */ new Map();
  /** DEBUG: Last 20 executed PCs */
  recentPCs = [];
  lastExecutedPC = 0;
  /**
   * Get opcode statistics and execution trace.
   * Only meaningful when debug mode is enabled.
   */
  getOpcodeStats() {
    return {
      total: this.totalOps,
      counts: this.opcodeCount,
      unknowns: this.unknownOpcodes,
      recentPCs: this.recentPCs,
      lastPC: this.lastExecutedPC
    };
  }
  /**
   * Execute a decoded instruction
   */
  async execute(instruction) {
    if (this.debugEnabled) {
      this.recentPCs.push(instruction.address);
      if (this.recentPCs.length > 20) {
        this.recentPCs.shift();
      }
      this.lastExecutedPC = instruction.address;
      this.totalOps++;
      const count = this.opcodeCount.get(instruction.opcodeName) || 0;
      this.opcodeCount.set(instruction.opcodeName, count + 1);
      if (instruction.opcodeName === "unknown") {
        const existing = this.unknownOpcodes.get(instruction.opcode);
        if (!existing) {
          this.unknownOpcodes.set(instruction.opcode, { address: instruction.address, count: 1 });
        } else {
          existing.count++;
        }
      }
    }
    const handler = this.handlers.get(instruction.opcodeName);
    const nextPC = instruction.address + instruction.length;
    if (!handler) {
      return {
        nextPC,
        error: `Unimplemented opcode: ${instruction.opcodeName}`
      };
    }
    try {
      return await handler(instruction);
    } catch (error) {
      return {
        nextPC,
        error: `Error executing ${instruction.opcodeName}: ${error}`
      };
    }
  }
  /**
   * Print text respecting output streams
   * Stream 1: Screen (default)
   * Stream 2: Transcript (passed to IO)
   * Stream 3: Memory table (stackable, highest priority)
   * Stream 4: Player input script (passed to IO)
   */
  printText(text) {
    if (this.stream3Stack.length > 0) {
      const stream = this.stream3Stack[this.stream3Stack.length - 1];
      for (const char of text) {
        const zscii = char.charCodeAt(0);
        this.memory.writeByte(stream.table + 2 + stream.pos, zscii);
        stream.pos++;
      }
      this.memory.writeWord(stream.table, stream.pos);
      return;
    }
    if (this.streamEnabled[1]) {
      this.io.print(text);
    }
  }
  /**
   * Get the value of an operand
   */
  getOperandValue(operand) {
    switch (operand.type) {
      case OperandType.LargeConstant:
      case OperandType.SmallConstant:
        return operand.value;
      case OperandType.Variable:
        return this.variables.load(operand.value);
      default:
        throw new Error(`Invalid operand type: ${operand.type}`);
    }
  }
  /**
   * Store a result value
   */
  storeResult(instruction, value) {
    if (instruction.storeVariable !== void 0) {
      this.variables.store(instruction.storeVariable, value & 65535);
    }
  }
  /**
   * Perform a branch based on condition
   */
  branch(instruction, condition) {
    const nextPC = instruction.address + instruction.length;
    if (!instruction.branch) {
      return { nextPC };
    }
    const shouldBranch = condition === instruction.branch.branchOnTrue;
    if (!shouldBranch) {
      return { nextPC };
    }
    const offset = instruction.branch.offset;
    if (offset === 0) {
      return this.doReturn(0);
    }
    if (offset === 1) {
      return this.doReturn(1);
    }
    return { nextPC: nextPC + offset - 2 };
  }
  /**
   * Perform a return from routine
   */
  doReturn(value) {
    const frame = this.stack.popFrame();
    if (frame.storeVariable !== void 0) {
      this.variables.store(frame.storeVariable, value & 65535);
    }
    return { nextPC: frame.returnPC };
  }
  /**
   * Call a routine
   */
  callRoutine(packedAddress, args, storeVariable, nextPC) {
    if (packedAddress === 0) {
      if (storeVariable !== void 0) {
        this.variables.store(storeVariable, 0);
      }
      return { nextPC };
    }
    const routineAddr = unpackRoutineAddress(packedAddress, this.version);
    const localCount = this.memory.readByte(routineAddr);
    const initialLocals = [];
    let codeStart = routineAddr + 1;
    if (this.version <= 4) {
      for (let i = 0; i < localCount; i++) {
        initialLocals.push(this.memory.readWord(codeStart));
        codeStart += 2;
      }
    } else {
      for (let i = 0; i < localCount; i++) {
        initialLocals.push(0);
      }
    }
    for (let i = 0; i < Math.min(args.length, localCount); i++) {
      initialLocals[i] = args[i];
    }
    this.stack.pushFrame(nextPC, storeVariable, localCount, args.length);
    for (let i = 0; i < localCount; i++) {
      this.stack.currentFrame.setLocal(i, initialLocals[i]);
    }
    return { nextPC: codeStart };
  }
  /**
   * Register all opcode handlers
   */
  registerHandlers() {
    this.handlers.set("je", this.op_je.bind(this));
    this.handlers.set("jl", this.op_jl.bind(this));
    this.handlers.set("jg", this.op_jg.bind(this));
    this.handlers.set("dec_chk", this.op_dec_chk.bind(this));
    this.handlers.set("inc_chk", this.op_inc_chk.bind(this));
    this.handlers.set("jin", this.op_jin.bind(this));
    this.handlers.set("test", this.op_test.bind(this));
    this.handlers.set("or", this.op_or.bind(this));
    this.handlers.set("and", this.op_and.bind(this));
    this.handlers.set("test_attr", this.op_test_attr.bind(this));
    this.handlers.set("set_attr", this.op_set_attr.bind(this));
    this.handlers.set("clear_attr", this.op_clear_attr.bind(this));
    this.handlers.set("store", this.op_store.bind(this));
    this.handlers.set("insert_obj", this.op_insert_obj.bind(this));
    this.handlers.set("loadw", this.op_loadw.bind(this));
    this.handlers.set("loadb", this.op_loadb.bind(this));
    this.handlers.set("get_prop", this.op_get_prop.bind(this));
    this.handlers.set("get_prop_addr", this.op_get_prop_addr.bind(this));
    this.handlers.set("get_next_prop", this.op_get_next_prop.bind(this));
    this.handlers.set("add", this.op_add.bind(this));
    this.handlers.set("sub", this.op_sub.bind(this));
    this.handlers.set("mul", this.op_mul.bind(this));
    this.handlers.set("div", this.op_div.bind(this));
    this.handlers.set("mod", this.op_mod.bind(this));
    this.handlers.set("call_2s", this.op_call_2s.bind(this));
    this.handlers.set("call_2n", this.op_call_2n.bind(this));
    this.handlers.set("set_colour", this.op_set_colour.bind(this));
    this.handlers.set("jz", this.op_jz.bind(this));
    this.handlers.set("get_sibling", this.op_get_sibling.bind(this));
    this.handlers.set("get_child", this.op_get_child.bind(this));
    this.handlers.set("get_parent", this.op_get_parent.bind(this));
    this.handlers.set("get_prop_len", this.op_get_prop_len.bind(this));
    this.handlers.set("inc", this.op_inc.bind(this));
    this.handlers.set("dec", this.op_dec.bind(this));
    this.handlers.set("print_addr", this.op_print_addr.bind(this));
    this.handlers.set("call_1s", this.op_call_1s.bind(this));
    this.handlers.set("remove_obj", this.op_remove_obj.bind(this));
    this.handlers.set("print_obj", this.op_print_obj.bind(this));
    this.handlers.set("ret", this.op_ret.bind(this));
    this.handlers.set("jump", this.op_jump.bind(this));
    this.handlers.set("print_paddr", this.op_print_paddr.bind(this));
    this.handlers.set("load", this.op_load.bind(this));
    this.handlers.set("not", this.op_not.bind(this));
    this.handlers.set("call_1n", this.op_call_1n.bind(this));
    this.handlers.set("rtrue", this.op_rtrue.bind(this));
    this.handlers.set("rfalse", this.op_rfalse.bind(this));
    this.handlers.set("print", this.op_print.bind(this));
    this.handlers.set("print_ret", this.op_print_ret.bind(this));
    this.handlers.set("nop", this.op_nop.bind(this));
    this.handlers.set("save", this.op_save.bind(this));
    this.handlers.set("restore", this.op_restore.bind(this));
    this.handlers.set("restart", this.op_restart.bind(this));
    this.handlers.set("ret_popped", this.op_ret_popped.bind(this));
    this.handlers.set("pop", this.op_pop.bind(this));
    this.handlers.set("quit", this.op_quit.bind(this));
    this.handlers.set("new_line", this.op_new_line.bind(this));
    this.handlers.set("show_status", this.op_show_status.bind(this));
    this.handlers.set("verify", this.op_verify.bind(this));
    this.handlers.set("call", this.op_call.bind(this));
    this.handlers.set("call_vs", this.op_call.bind(this));
    this.handlers.set("storew", this.op_storew.bind(this));
    this.handlers.set("storeb", this.op_storeb.bind(this));
    this.handlers.set("put_prop", this.op_put_prop.bind(this));
    this.handlers.set("sread", this.op_sread.bind(this));
    this.handlers.set("aread", this.op_aread.bind(this));
    this.handlers.set("print_char", this.op_print_char.bind(this));
    this.handlers.set("print_num", this.op_print_num.bind(this));
    this.handlers.set("random", this.op_random.bind(this));
    this.handlers.set("push", this.op_push.bind(this));
    this.handlers.set("pull", this.op_pull.bind(this));
    this.handlers.set("split_window", this.op_split_window.bind(this));
    this.handlers.set("set_window", this.op_set_window.bind(this));
    this.handlers.set("call_vs2", this.op_call.bind(this));
    this.handlers.set("erase_window", this.op_erase_window.bind(this));
    this.handlers.set("set_cursor", this.op_set_cursor.bind(this));
    this.handlers.set("get_cursor", this.op_get_cursor.bind(this));
    this.handlers.set("set_text_style", this.op_set_text_style.bind(this));
    this.handlers.set("buffer_mode", this.op_buffer_mode.bind(this));
    this.handlers.set("output_stream", this.op_output_stream.bind(this));
    this.handlers.set("input_stream", this.op_input_stream.bind(this));
    this.handlers.set("sound_effect", this.op_sound_effect.bind(this));
    this.handlers.set("read_char", this.op_read_char.bind(this));
    this.handlers.set("scan_table", this.op_scan_table.bind(this));
    this.handlers.set("call_vn", this.op_call_vn.bind(this));
    this.handlers.set("call_vn2", this.op_call_vn.bind(this));
    this.handlers.set("tokenise", this.op_tokenise.bind(this));
    this.handlers.set("encode_text", this.op_encode_text.bind(this));
    this.handlers.set("copy_table", this.op_copy_table.bind(this));
    this.handlers.set("print_table", this.op_print_table.bind(this));
    this.handlers.set("check_arg_count", this.op_check_arg_count.bind(this));
    this.handlers.set("log_shift", this.op_log_shift.bind(this));
    this.handlers.set("art_shift", this.op_art_shift.bind(this));
    this.handlers.set("set_font", this.op_set_font.bind(this));
    this.handlers.set("save_undo", this.op_save_undo.bind(this));
    this.handlers.set("restore_undo", this.op_restore_undo.bind(this));
    this.handlers.set("print_unicode", this.op_print_unicode.bind(this));
    this.handlers.set("check_unicode", this.op_check_unicode.bind(this));
    this.handlers.set("set_true_colour", this.op_set_true_colour.bind(this));
    this.handlers.set("catch", this.op_catch.bind(this));
    this.handlers.set("throw", this.op_throw.bind(this));
    this.handlers.set("piracy", this.op_piracy.bind(this));
    this.handlers.set("erase_line", this.op_erase_line.bind(this));
  }
  // ============================================
  // 2OP Opcode Implementations
  // ============================================
  op_je(ins) {
    const a = this.getOperandValue(ins.operands[0]);
    for (let i = 1; i < ins.operands.length; i++) {
      if (a === this.getOperandValue(ins.operands[i])) {
        return this.branch(ins, true);
      }
    }
    return this.branch(ins, false);
  }
  op_jl(ins) {
    const a = toSigned16(this.getOperandValue(ins.operands[0]));
    const b = toSigned16(this.getOperandValue(ins.operands[1]));
    return this.branch(ins, a < b);
  }
  op_jg(ins) {
    const a = toSigned16(this.getOperandValue(ins.operands[0]));
    const b = toSigned16(this.getOperandValue(ins.operands[1]));
    return this.branch(ins, a > b);
  }
  op_dec_chk(ins) {
    const varNum = this.getOperandValue(ins.operands[0]);
    const check = toSigned16(this.getOperandValue(ins.operands[1]));
    this.variables.decrement(varNum);
    const value = toSigned16(this.variables.peek(varNum));
    return this.branch(ins, value < check);
  }
  op_inc_chk(ins) {
    const varNum = this.getOperandValue(ins.operands[0]);
    const check = toSigned16(this.getOperandValue(ins.operands[1]));
    this.variables.increment(varNum);
    const value = toSigned16(this.variables.peek(varNum));
    return this.branch(ins, value > check);
  }
  op_jin(ins) {
    const obj1 = this.getOperandValue(ins.operands[0]);
    const obj2 = this.getOperandValue(ins.operands[1]);
    const parent = this.objectTable.getParent(obj1);
    return this.branch(ins, parent === obj2);
  }
  op_test(ins) {
    const bitmap = this.getOperandValue(ins.operands[0]);
    const flags = this.getOperandValue(ins.operands[1]);
    return this.branch(ins, (bitmap & flags) === flags);
  }
  op_or(ins) {
    const a = this.getOperandValue(ins.operands[0]);
    const b = this.getOperandValue(ins.operands[1]);
    this.storeResult(ins, a | b);
    return { nextPC: ins.address + ins.length };
  }
  op_and(ins) {
    const a = this.getOperandValue(ins.operands[0]);
    const b = this.getOperandValue(ins.operands[1]);
    this.storeResult(ins, a & b);
    return { nextPC: ins.address + ins.length };
  }
  op_test_attr(ins) {
    const obj = this.getOperandValue(ins.operands[0]);
    const attr = this.getOperandValue(ins.operands[1]);
    const hasAttr = this.objectTable.testAttribute(obj, attr);
    return this.branch(ins, hasAttr);
  }
  op_set_attr(ins) {
    const obj = this.getOperandValue(ins.operands[0]);
    const attr = this.getOperandValue(ins.operands[1]);
    this.objectTable.setAttribute(obj, attr);
    return { nextPC: ins.address + ins.length };
  }
  op_clear_attr(ins) {
    const obj = this.getOperandValue(ins.operands[0]);
    const attr = this.getOperandValue(ins.operands[1]);
    this.objectTable.clearAttribute(obj, attr);
    return { nextPC: ins.address + ins.length };
  }
  op_store(ins) {
    const varNum = this.getOperandValue(ins.operands[0]);
    const value = this.getOperandValue(ins.operands[1]);
    this.variables.write(varNum, value);
    return { nextPC: ins.address + ins.length };
  }
  op_insert_obj(ins) {
    const obj = this.getOperandValue(ins.operands[0]);
    const dest = this.getOperandValue(ins.operands[1]);
    this.objectTable.insertObject(obj, dest);
    return { nextPC: ins.address + ins.length };
  }
  op_loadw(ins) {
    const array = this.getOperandValue(ins.operands[0]);
    const wordIndex = this.getOperandValue(ins.operands[1]);
    const value = this.memory.readWord(array + wordIndex * 2);
    this.storeResult(ins, value);
    return { nextPC: ins.address + ins.length };
  }
  op_loadb(ins) {
    const array = this.getOperandValue(ins.operands[0]);
    const byteIndex = this.getOperandValue(ins.operands[1]);
    const value = this.memory.readByte(array + byteIndex);
    this.storeResult(ins, value);
    return { nextPC: ins.address + ins.length };
  }
  op_get_prop(ins) {
    const obj = this.getOperandValue(ins.operands[0]);
    const prop = this.getOperandValue(ins.operands[1]);
    const value = this.properties.getProperty(obj, prop);
    this.storeResult(ins, value);
    return { nextPC: ins.address + ins.length };
  }
  op_get_prop_addr(ins) {
    const obj = this.getOperandValue(ins.operands[0]);
    const prop = this.getOperandValue(ins.operands[1]);
    const addr = this.properties.getPropertyAddress(obj, prop);
    this.storeResult(ins, addr);
    return { nextPC: ins.address + ins.length };
  }
  op_get_next_prop(ins) {
    const obj = this.getOperandValue(ins.operands[0]);
    const prop = this.getOperandValue(ins.operands[1]);
    const nextProp = this.properties.getNextProperty(obj, prop);
    this.storeResult(ins, nextProp);
    return { nextPC: ins.address + ins.length };
  }
  op_add(ins) {
    const a = toSigned16(this.getOperandValue(ins.operands[0]));
    const b = toSigned16(this.getOperandValue(ins.operands[1]));
    this.storeResult(ins, a + b);
    return { nextPC: ins.address + ins.length };
  }
  op_sub(ins) {
    const a = toSigned16(this.getOperandValue(ins.operands[0]));
    const b = toSigned16(this.getOperandValue(ins.operands[1]));
    this.storeResult(ins, a - b);
    return { nextPC: ins.address + ins.length };
  }
  op_mul(ins) {
    const a = toSigned16(this.getOperandValue(ins.operands[0]));
    const b = toSigned16(this.getOperandValue(ins.operands[1]));
    this.storeResult(ins, a * b);
    return { nextPC: ins.address + ins.length };
  }
  op_div(ins) {
    const a = toSigned16(this.getOperandValue(ins.operands[0]));
    const b = toSigned16(this.getOperandValue(ins.operands[1]));
    if (b === 0) {
      return { nextPC: ins.address + ins.length, error: "Division by zero" };
    }
    const result = Math.trunc(a / b);
    this.storeResult(ins, result);
    return { nextPC: ins.address + ins.length };
  }
  op_mod(ins) {
    const a = toSigned16(this.getOperandValue(ins.operands[0]));
    const b = toSigned16(this.getOperandValue(ins.operands[1]));
    if (b === 0) {
      return { nextPC: ins.address + ins.length, error: "Division by zero" };
    }
    const result = a % b;
    this.storeResult(ins, result);
    return { nextPC: ins.address + ins.length };
  }
  op_call_2s(ins) {
    const routine = this.getOperandValue(ins.operands[0]);
    const arg = this.getOperandValue(ins.operands[1]);
    return this.callRoutine(routine, [arg], ins.storeVariable, ins.address + ins.length);
  }
  op_call_2n(ins) {
    const routine = this.getOperandValue(ins.operands[0]);
    const arg = this.getOperandValue(ins.operands[1]);
    return this.callRoutine(routine, [arg], void 0, ins.address + ins.length);
  }
  op_set_colour(ins) {
    const foreground = this.getOperandValue(ins.operands[0]);
    const background = this.getOperandValue(ins.operands[1]);
    if (this.io.setForegroundColor && foreground !== 0) {
      this.io.setForegroundColor(foreground);
    }
    if (this.io.setBackgroundColor && background !== 0) {
      this.io.setBackgroundColor(background);
    }
    return { nextPC: ins.address + ins.length };
  }
  // ============================================
  // 1OP Opcode Implementations
  // ============================================
  op_jz(ins) {
    const value = this.getOperandValue(ins.operands[0]);
    return this.branch(ins, value === 0);
  }
  op_get_sibling(ins) {
    const obj = this.getOperandValue(ins.operands[0]);
    const sibling = this.objectTable.getSibling(obj);
    this.storeResult(ins, sibling);
    return this.branch(ins, sibling !== 0);
  }
  op_get_child(ins) {
    const obj = this.getOperandValue(ins.operands[0]);
    const child = this.objectTable.getChild(obj);
    this.storeResult(ins, child);
    return this.branch(ins, child !== 0);
  }
  op_get_parent(ins) {
    const obj = this.getOperandValue(ins.operands[0]);
    const parent = this.objectTable.getParent(obj);
    this.storeResult(ins, parent);
    return { nextPC: ins.address + ins.length };
  }
  op_get_prop_len(ins) {
    const propAddr = this.getOperandValue(ins.operands[0]);
    const length = propAddr === 0 ? 0 : this.properties.getPropertyLength(propAddr);
    this.storeResult(ins, length);
    return { nextPC: ins.address + ins.length };
  }
  op_inc(ins) {
    const varNum = this.getOperandValue(ins.operands[0]);
    this.variables.increment(varNum);
    return { nextPC: ins.address + ins.length };
  }
  op_dec(ins) {
    const varNum = this.getOperandValue(ins.operands[0]);
    this.variables.decrement(varNum);
    return { nextPC: ins.address + ins.length };
  }
  op_print_addr(ins) {
    const addr = this.getOperandValue(ins.operands[0]);
    const result = this.textDecoder.decode(addr);
    this.printText(result.text);
    return { nextPC: ins.address + ins.length };
  }
  op_call_1s(ins) {
    const routine = this.getOperandValue(ins.operands[0]);
    return this.callRoutine(routine, [], ins.storeVariable, ins.address + ins.length);
  }
  op_remove_obj(ins) {
    const obj = this.getOperandValue(ins.operands[0]);
    this.objectTable.removeFromParent(obj);
    return { nextPC: ins.address + ins.length };
  }
  op_print_obj(ins) {
    const obj = this.getOperandValue(ins.operands[0]);
    const nameInfo = this.objectTable.getShortNameAddress(obj);
    if (nameInfo.lengthBytes > 0) {
      const result = this.textDecoder.decode(nameInfo.address);
      this.printText(result.text);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_ret(ins) {
    const value = this.getOperandValue(ins.operands[0]);
    return this.doReturn(value);
  }
  op_jump(ins) {
    const offset = toSigned16(this.getOperandValue(ins.operands[0]));
    return { nextPC: ins.address + ins.length + offset - 2 };
  }
  op_print_paddr(ins) {
    const packedAddr = this.getOperandValue(ins.operands[0]);
    let byteAddr;
    if (this.version <= 3) {
      byteAddr = packedAddr * 2;
    } else if (this.version <= 5) {
      byteAddr = packedAddr * 4;
    } else {
      byteAddr = packedAddr * 8;
    }
    const result = this.textDecoder.decode(byteAddr);
    this.printText(result.text);
    return { nextPC: ins.address + ins.length };
  }
  op_load(ins) {
    const varNum = this.getOperandValue(ins.operands[0]);
    const value = this.variables.peek(varNum);
    this.storeResult(ins, value);
    return { nextPC: ins.address + ins.length };
  }
  op_not(ins) {
    const value = this.getOperandValue(ins.operands[0]);
    this.storeResult(ins, ~value & 65535);
    return { nextPC: ins.address + ins.length };
  }
  op_call_1n(ins) {
    const routine = this.getOperandValue(ins.operands[0]);
    return this.callRoutine(routine, [], void 0, ins.address + ins.length);
  }
  // ============================================
  // 0OP Opcode Implementations
  // ============================================
  op_rtrue(_ins) {
    return this.doReturn(1);
  }
  op_rfalse(_ins) {
    return this.doReturn(0);
  }
  op_print(ins) {
    if (ins.text) {
      this.printText(ins.text);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_print_ret(ins) {
    if (ins.text) {
      this.printText(ins.text);
    }
    this.printText("\n");
    return this.doReturn(1);
  }
  op_nop(ins) {
    return { nextPC: ins.address + ins.length };
  }
  async op_save(ins) {
    if (this.io.save) {
      const returnPC = ins.address + ins.length;
      const saveData = createQuetzalSave(this.memory, this.stack.snapshot(), returnPC);
      const saved = await this.io.save(saveData);
      if (this.version <= 3) {
        return this.branch(ins, saved);
      } else {
        this.storeResult(ins, saved ? 1 : 0);
      }
    } else {
      if (this.version <= 3) {
        return this.branch(ins, false);
      } else {
        this.storeResult(ins, 0);
      }
    }
    return { nextPC: ins.address + ins.length };
  }
  async op_restore(ins) {
    if (this.io.restore) {
      const data = await this.io.restore();
      if (data) {
        try {
          const saveState = parseQuetzalSave(data);
          if (!verifySaveCompatibility(saveState, this.memory)) {
            if (this.version <= 3) {
              return this.branch(ins, false);
            } else {
              this.storeResult(ins, 0);
              return { nextPC: ins.address + ins.length };
            }
          }
          const staticBase = this.header.staticMemoryBase;
          const restoreSize = Math.min(saveState.dynamicMemory.length, staticBase);
          for (let i = 0; i < restoreSize; i++) {
            this.memory.writeByte(i, saveState.dynamicMemory[i]);
          }
          this.stack.restore(saveState.callStack);
          if (this.version >= 4) {
            this.storeResult(ins, 2);
          }
          return { nextPC: saveState.gameId.pc };
        } catch {
          if (this.version <= 3) {
            return this.branch(ins, false);
          } else {
            this.storeResult(ins, 0);
          }
        }
      } else {
        if (this.version <= 3) {
          return this.branch(ins, false);
        } else {
          this.storeResult(ins, 0);
        }
      }
    } else {
      if (this.version <= 3) {
        return this.branch(ins, false);
      } else {
        this.storeResult(ins, 0);
      }
    }
    return { nextPC: ins.address + ins.length };
  }
  op_restart(_ins) {
    this.memory.restart();
    this.stack.initialize(0);
    this.io.restart();
    return { nextPC: this.header.initialPC };
  }
  op_ret_popped(_ins) {
    const value = this.stack.pop();
    return this.doReturn(value);
  }
  op_pop(ins) {
    this.stack.pop();
    return { nextPC: ins.address + ins.length };
  }
  op_quit(_ins) {
    this.io.quit();
    return { nextPC: 0, halted: true };
  }
  op_new_line(ins) {
    this.printText("\n");
    return { nextPC: ins.address + ins.length };
  }
  op_show_status(ins) {
    if (this.io.showStatusLine) {
      const locationObj = this.variables.load(16);
      let locationName = "Unknown";
      if (locationObj !== 0) {
        const nameInfo = this.objectTable.getShortNameAddress(locationObj);
        if (nameInfo.lengthBytes > 0) {
          const result = this.textDecoder.decode(nameInfo.address);
          locationName = result.text;
        }
      }
      const scoreOrHours = toSigned16(this.variables.load(17));
      const turnsOrMinutes = this.variables.load(18);
      const isTimeGame = (this.header.flags1 & 2) !== 0;
      this.io.showStatusLine(locationName, scoreOrHours, turnsOrMinutes, isTimeGame);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_verify(ins) {
    return this.branch(ins, true);
  }
  // ============================================
  // VAR Opcode Implementations
  // ============================================
  op_call(ins) {
    const routine = this.getOperandValue(ins.operands[0]);
    const args = [];
    for (let i = 1; i < ins.operands.length; i++) {
      args.push(this.getOperandValue(ins.operands[i]));
    }
    return this.callRoutine(routine, args, ins.storeVariable, ins.address + ins.length);
  }
  op_storew(ins) {
    const array = this.getOperandValue(ins.operands[0]);
    const wordIndex = this.getOperandValue(ins.operands[1]);
    const value = this.getOperandValue(ins.operands[2]);
    this.memory.writeWord(array + wordIndex * 2, value);
    return { nextPC: ins.address + ins.length };
  }
  op_storeb(ins) {
    const array = this.getOperandValue(ins.operands[0]);
    const byteIndex = this.getOperandValue(ins.operands[1]);
    const value = this.getOperandValue(ins.operands[2]);
    this.memory.writeByte(array + byteIndex, value & 255);
    return { nextPC: ins.address + ins.length };
  }
  op_put_prop(ins) {
    const obj = this.getOperandValue(ins.operands[0]);
    const prop = this.getOperandValue(ins.operands[1]);
    const value = this.getOperandValue(ins.operands[2]);
    this.properties.putProperty(obj, prop, value);
    return { nextPC: ins.address + ins.length };
  }
  async op_sread(ins) {
    const textBuffer = this.getOperandValue(ins.operands[0]);
    const parseBuffer = this.getOperandValue(ins.operands[1]);
    const maxLen = this.memory.readByte(textBuffer);
    const result = await this.io.readLine(maxLen);
    const text = result.text.toLowerCase();
    if (this.version >= 5) {
      this.memory.writeByte(textBuffer + 1, text.length);
      for (let i = 0; i < text.length; i++) {
        this.memory.writeByte(textBuffer + 2 + i, text.charCodeAt(i));
      }
    } else {
      for (let i = 0; i < text.length; i++) {
        this.memory.writeByte(textBuffer + 1 + i, text.charCodeAt(i));
      }
      this.memory.writeByte(textBuffer + 1 + text.length, 0);
    }
    if (parseBuffer !== 0) {
      this.tokenizer.tokenizeBuffer(textBuffer, parseBuffer);
    }
    if (this.version >= 5 && ins.storeVariable !== void 0) {
      this.storeResult(ins, result.terminator || 13);
    }
    return { nextPC: ins.address + ins.length };
  }
  async op_aread(ins) {
    const textBuffer = this.getOperandValue(ins.operands[0]);
    const parseBuffer = this.getOperandValue(ins.operands[1]);
    const maxLen = this.memory.readByte(textBuffer);
    const result = await this.io.readLine(maxLen);
    const text = result.text.toLowerCase();
    if (this.version >= 5) {
      this.memory.writeByte(textBuffer + 1, text.length);
      for (let i = 0; i < text.length; i++) {
        this.memory.writeByte(textBuffer + 2 + i, text.charCodeAt(i));
      }
    } else {
      for (let i = 0; i < text.length; i++) {
        this.memory.writeByte(textBuffer + 1 + i, text.charCodeAt(i));
      }
      this.memory.writeByte(textBuffer + 1 + text.length, 0);
    }
    if (parseBuffer !== 0) {
      this.tokenizer.tokenizeBuffer(textBuffer, parseBuffer);
    }
    if (this.version >= 5) {
      this.storeResult(ins, 13);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_print_char(ins) {
    const zscii = this.getOperandValue(ins.operands[0]);
    const char = String.fromCharCode(zscii);
    this.printText(char);
    return { nextPC: ins.address + ins.length };
  }
  op_print_num(ins) {
    const num = toSigned16(this.getOperandValue(ins.operands[0]));
    this.printText(num.toString());
    return { nextPC: ins.address + ins.length };
  }
  randomSeed = Date.now();
  randomMode = "random";
  /**
   * Simple Linear Congruential Generator for predictable random mode
   * Uses the same constants as glibc
   */
  nextPredictableRandom() {
    this.randomSeed = this.randomSeed * 1103515245 + 12345 >>> 0 & 2147483647;
    return this.randomSeed;
  }
  op_random(ins) {
    const range = toSigned16(this.getOperandValue(ins.operands[0]));
    if (range <= 0) {
      if (range === 0) {
        this.randomMode = "random";
        this.randomSeed = Date.now();
      } else {
        this.randomMode = "predictable";
        this.randomSeed = -range;
      }
      this.storeResult(ins, 0);
    } else {
      let result;
      if (typeof this.externalRandom === "function") {
        result = this.externalRandom(range);
      } else if (this.randomMode === "random") {
        result = Math.floor(Math.random() * range) + 1;
      } else {
        result = this.nextPredictableRandom() % range + 1;
      }
      this.storeResult(ins, result);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_push(ins) {
    const value = this.getOperandValue(ins.operands[0]);
    this.stack.push(value);
    return { nextPC: ins.address + ins.length };
  }
  op_pull(ins) {
    const varNum = this.getOperandValue(ins.operands[0]);
    const value = this.stack.pop();
    this.variables.write(varNum, value);
    return { nextPC: ins.address + ins.length };
  }
  op_split_window(ins) {
    const lines = this.getOperandValue(ins.operands[0]);
    if (this.io.splitWindow) {
      this.io.splitWindow(lines);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_set_window(ins) {
    const window = this.getOperandValue(ins.operands[0]);
    if (this.io.setWindow) {
      this.io.setWindow(window);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_erase_window(ins) {
    const window = toSigned16(this.getOperandValue(ins.operands[0]));
    if (this.io.eraseWindow) {
      this.io.eraseWindow(window);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_set_cursor(ins) {
    const line = this.getOperandValue(ins.operands[0]);
    const column = this.getOperandValue(ins.operands[1]);
    if (this.io.setCursor) {
      this.io.setCursor(line, column);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_get_cursor(ins) {
    const array = this.getOperandValue(ins.operands[0]);
    let row = 1, column = 1;
    if (this.io.getCursor) {
      const cursor = this.io.getCursor();
      row = cursor.line;
      column = cursor.column;
    }
    this.memory.writeWord(array, row);
    this.memory.writeWord(array + 2, column);
    return { nextPC: ins.address + ins.length };
  }
  op_set_text_style(ins) {
    const style = this.getOperandValue(ins.operands[0]);
    if (this.io.setTextStyle) {
      this.io.setTextStyle(style);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_buffer_mode(ins) {
    const mode = this.getOperandValue(ins.operands[0]);
    if (this.io.setBufferMode) {
      this.io.setBufferMode(mode !== 0);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_output_stream(ins) {
    const stream = toSigned16(this.getOperandValue(ins.operands[0]));
    const table = ins.operands.length > 1 ? this.getOperandValue(ins.operands[1]) : void 0;
    if (stream > 0) {
      if (stream === 3 && table !== void 0) {
        this.stream3Stack.push({ table, pos: 0 });
        this.memory.writeWord(table, 0);
      } else {
        this.streamEnabled[stream] = true;
      }
    } else if (stream < 0) {
      const absStream = Math.abs(stream);
      if (absStream === 3) {
        this.stream3Stack.pop();
      } else {
        this.streamEnabled[absStream] = false;
      }
    }
    if (this.io.setOutputStream) {
      this.io.setOutputStream(Math.abs(stream), stream > 0, table);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_input_stream(ins) {
    const stream = this.getOperandValue(ins.operands[0]);
    if (this.io.setInputStream) {
      this.io.setInputStream(stream);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_sound_effect(ins) {
    const number = this.getOperandValue(ins.operands[0]);
    const effect = ins.operands.length > 1 ? this.getOperandValue(ins.operands[1]) : 0;
    const volume = ins.operands.length > 2 ? this.getOperandValue(ins.operands[2]) : 0;
    if (this.io.soundEffect) {
      this.io.soundEffect(number, effect, volume);
    }
    return { nextPC: ins.address + ins.length };
  }
  async op_read_char(ins) {
    const timeout = ins.operands.length > 1 ? this.getOperandValue(ins.operands[1]) : 0;
    const char = await this.io.readChar(timeout);
    this.storeResult(ins, char);
    return { nextPC: ins.address + ins.length };
  }
  op_scan_table(ins) {
    const x = this.getOperandValue(ins.operands[0]);
    const table = this.getOperandValue(ins.operands[1]);
    const len = this.getOperandValue(ins.operands[2]);
    const form = ins.operands.length > 3 ? this.getOperandValue(ins.operands[3]) : 130;
    const entryLen = form & 127;
    const isWord = (form & 128) !== 0;
    for (let i = 0; i < len; i++) {
      const addr = table + i * entryLen;
      const value = isWord ? this.memory.readWord(addr) : this.memory.readByte(addr);
      if (value === x) {
        this.storeResult(ins, addr);
        return this.branch(ins, true);
      }
    }
    this.storeResult(ins, 0);
    return this.branch(ins, false);
  }
  op_call_vn(ins) {
    const routine = this.getOperandValue(ins.operands[0]);
    const args = [];
    for (let i = 1; i < ins.operands.length; i++) {
      args.push(this.getOperandValue(ins.operands[i]));
    }
    return this.callRoutine(routine, args, void 0, ins.address + ins.length);
  }
  op_tokenise(ins) {
    const textBuffer = this.getOperandValue(ins.operands[0]);
    const parseBuffer = this.getOperandValue(ins.operands[1]);
    const dictionaryAddr = ins.operands.length > 2 ? this.getOperandValue(ins.operands[2]) : 0;
    const skipUnknown = ins.operands.length > 3 ? this.getOperandValue(ins.operands[3]) !== 0 : false;
    this.tokenizer.tokenizeBuffer(textBuffer, parseBuffer, dictionaryAddr, skipUnknown);
    return { nextPC: ins.address + ins.length };
  }
  op_encode_text(ins) {
    const zsciiText = this.getOperandValue(ins.operands[0]);
    const length = this.getOperandValue(ins.operands[1]);
    const from = this.getOperandValue(ins.operands[2]);
    const codedText = this.getOperandValue(ins.operands[3]);
    let text = "";
    for (let i = 0; i < length; i++) {
      const c = this.memory.readByte(zsciiText + from + i);
      text += String.fromCharCode(c);
    }
    const encoded = encodeText(text, this.version);
    for (let i = 0; i < encoded.length; i++) {
      this.memory.writeByte(codedText + i, encoded[i]);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_copy_table(ins) {
    const first = this.getOperandValue(ins.operands[0]);
    const second = this.getOperandValue(ins.operands[1]);
    const size = toSigned16(this.getOperandValue(ins.operands[2]));
    if (second === 0) {
      for (let i = 0; i < Math.abs(size); i++) {
        this.memory.writeByte(first + i, 0);
      }
    } else if (size > 0 && second > first) {
      for (let i = size - 1; i >= 0; i--) {
        this.memory.writeByte(second + i, this.memory.readByte(first + i));
      }
    } else {
      const len = Math.abs(size);
      for (let i = 0; i < len; i++) {
        this.memory.writeByte(second + i, this.memory.readByte(first + i));
      }
    }
    return { nextPC: ins.address + ins.length };
  }
  op_print_table(ins) {
    const zsciiText = this.getOperandValue(ins.operands[0]);
    const width = this.getOperandValue(ins.operands[1]);
    const height = ins.operands.length > 2 ? this.getOperandValue(ins.operands[2]) : 1;
    const skip = ins.operands.length > 3 ? this.getOperandValue(ins.operands[3]) : 0;
    for (let row = 0; row < height; row++) {
      for (let col = 0; col < width; col++) {
        const byte = this.memory.readByte(zsciiText + row * (width + skip) + col);
        this.printText(String.fromCharCode(byte));
      }
      if (row < height - 1) {
        this.printText("\n");
      }
    }
    return { nextPC: ins.address + ins.length };
  }
  op_check_arg_count(ins) {
    const argNum = this.getOperandValue(ins.operands[0]);
    const argCount = this.stack.currentFrame.argumentCount;
    return this.branch(ins, argNum <= argCount);
  }
  // ============================================
  // Extended Opcode Implementations (V5+)
  // ============================================
  op_log_shift(ins) {
    const number = this.getOperandValue(ins.operands[0]);
    const places = toSigned16(this.getOperandValue(ins.operands[1]));
    let result;
    if (places >= 0) {
      result = number << places & 65535;
    } else {
      result = number >>> -places & 65535;
    }
    this.storeResult(ins, result);
    return { nextPC: ins.address + ins.length };
  }
  op_art_shift(ins) {
    const number = toSigned16(this.getOperandValue(ins.operands[0]));
    const places = toSigned16(this.getOperandValue(ins.operands[1]));
    let result;
    if (places >= 0) {
      result = number << places & 65535;
    } else {
      result = number >> -places & 65535;
    }
    this.storeResult(ins, result);
    return { nextPC: ins.address + ins.length };
  }
  op_set_font(ins) {
    const font = this.getOperandValue(ins.operands[0]);
    if (font === 0) {
      this.storeResult(ins, 1);
    } else if (font === 1 || font === 4) {
      this.storeResult(ins, 1);
    } else {
      this.storeResult(ins, 0);
    }
    return { nextPC: ins.address + ins.length };
  }
  op_save_undo(ins) {
    const dynamicEnd = this.header.staticMemoryBase;
    const memorySnapshot = new Uint8Array(dynamicEnd);
    for (let i = 0; i < dynamicEnd; i++) {
      memorySnapshot[i] = this.memory.readByte(i);
    }
    const stackSnapshot = this.stack.serialize();
    this.undoState = {
      memory: memorySnapshot,
      stack: stackSnapshot,
      pc: ins.address + ins.length
    };
    this.storeResult(ins, 1);
    return { nextPC: ins.address + ins.length };
  }
  op_restore_undo(ins) {
    if (!this.undoState) {
      this.storeResult(ins, 0);
      return { nextPC: ins.address + ins.length };
    }
    for (let i = 0; i < this.undoState.memory.length; i++) {
      this.memory.writeByte(i, this.undoState.memory[i]);
    }
    this.stack.deserialize(this.undoState.stack);
    this.storeResult(ins, 2);
    return { nextPC: this.undoState.pc };
  }
  op_print_unicode(ins) {
    const charCode = this.getOperandValue(ins.operands[0]);
    this.printText(String.fromCodePoint(charCode));
    return { nextPC: ins.address + ins.length };
  }
  op_check_unicode(ins) {
    const charCode = this.getOperandValue(ins.operands[0]);
    let result = 0;
    if (charCode >= 0 && charCode <= 1114111) {
      result |= 1;
    }
    if (charCode >= 32 && charCode <= 126) {
      result |= 2;
    }
    this.storeResult(ins, result);
    return { nextPC: ins.address + ins.length };
  }
  // ============================================
  // V5+ Control Flow Opcodes
  // ============================================
  /**
   * catch -> (result)
   * Store the current stack frame pointer for use with throw
   */
  op_catch(ins) {
    const framePointer = this.stack.getFramePointer();
    this.storeResult(ins, framePointer);
    return { nextPC: ins.address + ins.length };
  }
  /**
   * throw value stack-frame
   * Unwind the stack to the given frame and return the value
   */
  op_throw(ins) {
    const value = this.getOperandValue(ins.operands[0]);
    const framePointer = this.getOperandValue(ins.operands[1]);
    const frame = this.stack.unwindTo(framePointer);
    if (frame.storeVariable !== void 0) {
      this.variables.store(frame.storeVariable, value & 65535);
    }
    return { nextPC: frame.returnPC };
  }
  /**
   * piracy ?(label)
   * Copy protection check - always branch (we're not pirates!)
   */
  op_piracy(ins) {
    return this.branch(ins, true);
  }
  /**
   * erase_line value
   * Erase from cursor to end of line in upper window
   */
  op_erase_line(ins) {
    const value = this.getOperandValue(ins.operands[0]);
    if (value === 1) {
      this.io.eraseLine?.();
    }
    return { nextPC: ins.address + ins.length };
  }
  /**
   * set_true_colour foreground background
   * Set 15-bit RGB colors (V5+)
   */
  op_set_true_colour(ins) {
    const foreground = this.getOperandValue(ins.operands[0]);
    const background = this.getOperandValue(ins.operands[1]);
    const toRGB = (color15) => {
      if (color15 === TrueColor.KEEP_CURRENT) {
        return void 0;
      }
      if (color15 === TrueColor.USE_DEFAULT) {
        return void 0;
      }
      const r = (color15 & 31) << 3;
      const g = (color15 >> 5 & 31) << 3;
      const b = (color15 >> 10 & 31) << 3;
      return `rgb(${r}, ${g}, ${b})`;
    };
    const fg = toRGB(foreground);
    const bg = toRGB(background);
    if (fg !== void 0) {
      this.io.setForegroundColor?.(foreground);
    }
    if (bg !== void 0) {
      this.io.setBackgroundColor?.(background);
    }
    return { nextPC: ins.address + ins.length };
  }
};

// node_modules/zmachine/dist/core/text/ZSCII.js
var ZSCII = {
  /** Null (padding) */
  NULL: 0,
  /** Delete previous character (rare) */
  DELETE: 8,
  /** Newline (carriage return) */
  NEWLINE: 13,
  /** Escape key */
  ESCAPE: 27,
  /** Cursor up */
  CURSOR_UP: 129,
  /** Cursor down */
  CURSOR_DOWN: 130,
  /** Cursor left */
  CURSOR_LEFT: 131,
  /** Cursor right */
  CURSOR_RIGHT: 132,
  /** Function key 1 */
  F1: 133,
  /** Function key 12 */
  F12: 144,
  /** Keypad 0 */
  KEYPAD_0: 145,
  /** Keypad 9 */
  KEYPAD_9: 154,
  /** Single click */
  CLICK_SINGLE: 252,
  /** Double click */
  CLICK_DOUBLE: 253,
  /** Menu click (V6) */
  CLICK_MENU: 254
};
var DEFAULT_UNICODE_TABLE = [
  // 155-163: German characters
  "\xE4",
  "\xF6",
  "\xFC",
  "\xC4",
  "\xD6",
  "\xDC",
  "\xDF",
  "\xBB",
  "\xAB",
  // 164-168: Spanish/Portuguese
  "\xEB",
  "\xEF",
  "\xFF",
  "\xCB",
  "\xCF",
  // 169-175: More accented
  "\xE1",
  "\xE9",
  "\xED",
  "\xF3",
  "\xFA",
  "\xFD",
  "\xC1",
  // 176-182
  "\xC9",
  "\xCD",
  "\xD3",
  "\xDA",
  "\xDD",
  "\xE0",
  "\xE8",
  // 183-189
  "\xEC",
  "\xF2",
  "\xF9",
  "\xC0",
  "\xC8",
  "\xCC",
  "\xD2",
  // 190-196
  "\xD9",
  "\xE2",
  "\xEA",
  "\xEE",
  "\xF4",
  "\xFB",
  "\xC2",
  // 197-203
  "\xCA",
  "\xCE",
  "\xD4",
  "\xDB",
  "\xE5",
  "\xC5",
  "\xF8",
  // 204-210
  "\xD8",
  "\xE3",
  "\xF1",
  "\xF5",
  "\xC3",
  "\xD1",
  "\xD5",
  // 211-217
  "\xE6",
  "\xC6",
  "\xE7",
  "\xC7",
  "\xFE",
  "\xF0",
  "\xDE",
  // 218-223
  "\xD0",
  "\u0153",
  "\u0152",
  "\xA1",
  "\xBF",
  "\xA3"
  // 224 onward: unused in default table
];
function zsciiToUnicode(code, unicodeTable = DEFAULT_UNICODE_TABLE) {
  if (code === ZSCII.NULL) {
    return "";
  }
  if (code === ZSCII.NEWLINE) {
    return "\n";
  }
  if (code >= 32 && code <= 126) {
    return String.fromCharCode(code);
  }
  if (code >= 155 && code <= 251) {
    const index = code - 155;
    if (index < unicodeTable.length) {
      return unicodeTable[index];
    }
    return "?";
  }
  return "";
}
function unicodeToZscii(char, unicodeTable = DEFAULT_UNICODE_TABLE) {
  if (char.length === 0) {
    return ZSCII.NULL;
  }
  const c = char.charAt(0);
  if (c === "\n" || c === "\r") {
    return ZSCII.NEWLINE;
  }
  const code = c.charCodeAt(0);
  if (code >= 32 && code <= 126) {
    return code;
  }
  const index = unicodeTable.indexOf(c);
  if (index !== -1) {
    return 155 + index;
  }
  return ZSCII.NULL;
}

// node_modules/zmachine/dist/core/text/ZCharDecoder.js
var ZCharDecoder = class {
  memory;
  version;
  abbreviationsAddress;
  customAlphabets;
  constructor(memory, version, abbreviationsAddress) {
    this.memory = memory;
    this.version = version;
    this.abbreviationsAddress = abbreviationsAddress;
  }
  /**
   * Set custom alphabet tables (from header extension, V5+)
   */
  setCustomAlphabets(alphabets) {
    this.customAlphabets = alphabets;
  }
  /**
   * Decode a Z-string at the given address
   *
   * @param address - Start address of the Z-string
   * @returns Decoded text and number of bytes consumed
   */
  decode(address) {
    const zchars = this.extractZChars(address);
    const text = this.zcharsToText(zchars.chars);
    return {
      text,
      bytesConsumed: zchars.bytesConsumed
    };
  }
  /**
   * Extract raw Z-characters from a packed string
   */
  extractZChars(address) {
    const chars = [];
    let offset = 0;
    let done = false;
    while (!done) {
      const word = this.memory.readWord(address + offset);
      offset += 2;
      chars.push(word >> 10 & 31);
      chars.push(word >> 5 & 31);
      chars.push(word & 31);
      if (word & 32768) {
        done = true;
      }
    }
    return { chars, bytesConsumed: offset };
  }
  /**
   * Convert Z-characters to text
   */
  zcharsToText(zchars, preventAbbreviation = false) {
    let result = "";
    let currentAlphabet = 0;
    let shiftAlphabet = null;
    let i = 0;
    while (i < zchars.length) {
      const zchar = zchars[i];
      i++;
      const alphabet = shiftAlphabet ?? currentAlphabet;
      shiftAlphabet = null;
      if (zchar === 0) {
        result += " ";
        continue;
      }
      if (zchar === 1) {
        if (this.version === 1) {
          result += "\n";
        } else if (!preventAbbreviation && i < zchars.length) {
          const nextZchar = zchars[i];
          i++;
          result += this.expandAbbreviation(zchar, nextZchar);
        }
        continue;
      }
      if (zchar === 2 || zchar === 3) {
        if (this.version >= 3 && !preventAbbreviation && i < zchars.length) {
          const nextZchar = zchars[i];
          i++;
          result += this.expandAbbreviation(zchar, nextZchar);
        } else if (this.version <= 2) {
          if (zchar === 2) {
            currentAlphabet = getShiftedAlphabet(currentAlphabet, 4, this.version);
          } else {
            currentAlphabet = getShiftedAlphabet(currentAlphabet, 5, this.version);
          }
        }
        continue;
      }
      if (zchar === 4 || zchar === 5) {
        shiftAlphabet = getShiftedAlphabet(currentAlphabet, zchar, this.version);
        continue;
      }
      if (alphabet === 2 && zchar === 6) {
        if (i + 1 < zchars.length) {
          const high = zchars[i];
          const low = zchars[i + 1];
          i += 2;
          const zsciiCode = high << 5 | low;
          result += zsciiToUnicode(zsciiCode);
        }
        continue;
      }
      const char = getAlphabetChar(zchar, alphabet, this.version, this.customAlphabets);
      if (char !== null) {
        result += char;
      }
    }
    return result;
  }
  /**
   * Expand an abbreviation
   */
  expandAbbreviation(prefixChar, indexChar) {
    const abbrevIndex = getAbbreviationIndex(prefixChar, indexChar);
    const tableOffset = abbrevIndex * 2;
    const wordAddress = this.memory.readWord(this.abbreviationsAddress + tableOffset);
    const byteAddress = wordAddress * 2;
    const zchars = this.extractZChars(byteAddress);
    return this.zcharsToText(zchars.chars, true);
  }
  /**
   * Decode a Z-string and return just the text
   * (Convenience method for use with Decoder)
   */
  decodeString(address) {
    return this.decode(address);
  }
};

// node_modules/zmachine/dist/core/ZMachine.js
var RunState;
(function(RunState2) {
  RunState2["Stopped"] = "stopped";
  RunState2["Running"] = "running";
  RunState2["WaitingForInput"] = "waiting";
  RunState2["Halted"] = "halted";
})(RunState || (RunState = {}));
var ZMachine = class _ZMachine {
  memory;
  header;
  stack;
  variables;
  decoder;
  executor;
  objectTable;
  properties;
  dictionary;
  tokenizer;
  textDecoder;
  io;
  version;
  _pc;
  _state = RunState.Stopped;
  /** Original story data for restart */
  originalStory;
  /**
   * Create a new Z-Machine instance
   *
   * @param storyData The story file data
   * @param io The I/O adapter for input/output
   */
  constructor(storyData, io, options = {}) {
    this.options = options;
    this.originalStory = storyData.slice(0);
    this.memory = new Memory(storyData);
    this.header = new Header(this.memory);
    this.version = this.header.version;
    this.io = io;
    this.stack = new Stack();
    this.stack.initialize(0);
    this.variables = new Variables(this.memory, this.stack, this.header.globalsAddress);
    this.textDecoder = new ZCharDecoder(this.memory, this.version, this.header.abbreviationsAddress);
    this.decoder = new Decoder(this.memory, this.version);
    this.decoder.setTextDecoder((addr) => this.textDecoder.decode(addr));
    this.executor = new Executor(this.memory, this.header, this.stack, this.variables, this.version, io, this.textDecoder);
    // A caller-supplied RNG makes two interpreters comparable: rather than
    // reimplementing the same algorithm twice and hoping the arithmetic
    // agrees, both call one function. Differential testing against a second
    // implementation then covers RANDOM-driven behaviour - the thief,
    // combat, idle barks - instead of having to exclude it.
    if (typeof options.random === 'function') this.executor.externalRandom = options.random;
    this.objectTable = new ObjectTable(this.memory, this.version, this.header.objectTableAddress);
    this.properties = new Properties(this.memory, this.version, this.objectTable);
    this.dictionary = new Dictionary(this.memory, this.version, this.header.dictionaryAddress);
    this.tokenizer = new Tokenizer(this.memory, this.version, this.dictionary);
    this._pc = this.header.initialPC;
    if (this.version >= 4) {
      this.header.setInterpreterInfo(6, "Z".charCodeAt(0));
      this.header.setScreenDimensions(80, 25);
      this.memory.writeByte(HeaderAddress.FLAGS1, 156);
      if (this.version >= 5) {
        this.memory.writeByte(HeaderAddress.FONT_WIDTH, 1);
        this.memory.writeByte(HeaderAddress.FONT_HEIGHT, 1);
        this.memory.writeByte(HeaderAddress.DEFAULT_BACKGROUND, 2);
        this.memory.writeByte(HeaderAddress.DEFAULT_FOREGROUND, 9);
        this.memory.writeByte(HeaderAddress.STANDARD_REVISION, 1);
        this.memory.writeByte(HeaderAddress.STANDARD_REVISION + 1, 1);
      }
    }
  }
  /**
   * Load a Z-machine story file
   *
   * @param storyData The story file data (ArrayBuffer or Uint8Array)
   * @param io The I/O adapter
   * @returns A new ZMachine instance
   */
  static load(storyData, io, options) {
    let buffer;
    if (storyData instanceof Uint8Array) {
      buffer = new ArrayBuffer(storyData.byteLength);
      new Uint8Array(buffer).set(storyData);
    } else {
      buffer = storyData;
    }
    return new _ZMachine(buffer, io, options);
  }
  /**
   * Current program counter
   */
  get pc() {
    return this._pc;
  }
  /**
   * Current run state
   */
  get state() {
    return this._state;
  }
  /**
   * Run the Z-machine until it halts or needs input
   *
   * @returns The run state when execution pauses
   */
  async run() {
    this._state = RunState.Running;
    while (this._state === RunState.Running) {
      await this.step();
    }
    return this._state;
  }
  /**
   * Execute a single instruction
   */
  async step() {
    if (this._state === RunState.Halted) {
      return;
    }
    const instruction = this.decoder.decode(this._pc);
    const result = await this.executor.execute(instruction);
    if (result.halted) {
      this._state = RunState.Halted;
      return;
    }
    if (result.waitingForInput) {
      this._state = RunState.WaitingForInput;
      return;
    }
    if (result.jumpTo !== void 0) {
      this._pc = result.jumpTo;
    } else if (result.nextPC !== void 0) {
      this._pc = result.nextPC;
    } else {
      this._pc = instruction.address + instruction.length;
    }
  }
  /**
   * Provide input when waiting for it
   *
   * Note: This is an alternative push-based API for input.
   * The primary path is through IOAdapter.readLine() which is
   * called by the read opcodes and awaited asynchronously.
   *
   * @param _input The input text (currently unused - reserved for future use)
   */
  async provideInput(_input) {
    if (this._state !== RunState.WaitingForInput) {
      throw new Error("Not waiting for input");
    }
    this._state = RunState.Running;
  }
  /**
   * Restart the game
   */
  restart() {
    const dynamicEnd = this.header.staticMemoryBase;
    for (let i = 0; i < dynamicEnd; i++) {
      const original = new DataView(this.originalStory);
      this.memory.writeByte(i, original.getUint8(i));
    }
    this.stack.clear();
    this.stack.initialize(0);
    this._pc = this.header.initialPC;
    this._state = RunState.Stopped;
  }
  /**
   * Get an object's short name
   */
  getObjectName(objectNum) {
    const nameInfo = this.objectTable.getShortNameAddress(objectNum);
    if (nameInfo.lengthBytes === 0) {
      return "";
    }
    const result = this.textDecoder.decode(nameInfo.address);
    return result.text;
  }
  /**
   * Print text at an address
   */
  printText(address) {
    const result = this.textDecoder.decode(address);
    return result.text;
  }
  /**
   * Look up a word in the dictionary
   */
  lookupWord(word) {
    const tokens = this.tokenizer.tokenize(word);
    if (tokens.length === 0) {
      return 0;
    }
    return tokens[0].dictionaryAddress;
  }
};

// node_modules/zmachine/dist/core/errors/ZMachineError.js
var ZMachineError = class _ZMachineError extends Error {
  constructor(message) {
    super(message);
    this.name = "ZMachineError";
    Object.setPrototypeOf(this, _ZMachineError.prototype);
  }
};
var MemoryError = class _MemoryError extends ZMachineError {
  address;
  operation;
  constructor(message, address, operation) {
    super(`${message} at address 0x${address.toString(16).toUpperCase().padStart(4, "0")}`);
    this.name = "MemoryError";
    this.address = address;
    this.operation = operation;
    Object.setPrototypeOf(this, _MemoryError.prototype);
  }
};
var OpcodeError = class _OpcodeError extends ZMachineError {
  opcode;
  address;
  constructor(message, opcode, address) {
    super(`${message} (opcode: ${opcode} at 0x${address.toString(16).toUpperCase().padStart(4, "0")})`);
    this.name = "OpcodeError";
    this.opcode = opcode;
    this.address = address;
    Object.setPrototypeOf(this, _OpcodeError.prototype);
  }
};
var DecodeError = class _DecodeError extends ZMachineError {
  address;
  opcodeByte;
  constructor(message, address, opcodeByte) {
    super(`${message} at 0x${address.toString(16).toUpperCase().padStart(4, "0")} (byte: 0x${opcodeByte.toString(16).toUpperCase().padStart(2, "0")})`);
    this.name = "DecodeError";
    this.address = address;
    this.opcodeByte = opcodeByte;
    Object.setPrototypeOf(this, _DecodeError.prototype);
  }
};
var StackError = class _StackError extends ZMachineError {
  constructor(message) {
    super(message);
    this.name = "StackError";
    Object.setPrototypeOf(this, _StackError.prototype);
  }
};
var ObjectError = class _ObjectError extends ZMachineError {
  objectNumber;
  constructor(message, objectNumber) {
    super(`${message} (object: ${objectNumber})`);
    this.name = "ObjectError";
    this.objectNumber = objectNumber;
    Object.setPrototypeOf(this, _ObjectError.prototype);
  }
};
var SaveError = class _SaveError extends ZMachineError {
  constructor(message) {
    super(message);
    this.name = "SaveError";
    Object.setPrototypeOf(this, _SaveError.prototype);
  }
};
var IOError = class _IOError extends ZMachineError {
  constructor(message) {
    super(message);
    this.name = "IOError";
    Object.setPrototypeOf(this, _IOError.prototype);
  }
};
function formatAddress(address) {
  return `0x${address.toString(16).toUpperCase().padStart(4, "0")}`;
}
function formatByte(byte) {
  return `0x${(byte & 255).toString(16).toUpperCase().padStart(2, "0")}`;
}
function formatWord(word) {
  return `0x${(word & 65535).toString(16).toUpperCase().padStart(4, "0")}`;
}

// node_modules/zmachine/dist/io/TestIOAdapter.js
var TestIOAdapter = class {
  /** All captured output from lower window (window 0) */
  output = [];
  /** Captured output from upper window (window 1) */
  upperOutput = [];
  /** Current window (0 = lower/main, 1 = upper/status) */
  currentWindow = 0;
  /** Number of lines in upper window */
  upperWindowLines = 0;
  /** Cursor position for upper window */
  upperCursor = { line: 1, column: 1 };
  /** Pending line inputs */
  lineInputs = [];
  /** Pending character inputs */
  charInputs = [];
  /** Whether the game has quit */
  hasQuit = false;
  /** Whether the game has restarted */
  hasRestarted = false;
  /** Last status line shown */
  lastStatusLine;
  /** Current text style */
  textStyle = 0;
  /** Buffer mode (true = buffered) */
  bufferMode = true;
  /** Z-machine version for version-specific behavior */
  currentVersion = 3;
  /** Get current text style */
  getTextStyle() {
    return this.textStyle;
  }
  /** Get current version */
  getVersion() {
    return this.currentVersion;
  }
  // Optional I/O adapter methods that can be set for testing
  save;
  restore;
  eraseLine;
  setForegroundColor;
  setBackgroundColor;
  soundEffect;
  setOutputStream;
  setInputStream;
  getCursor = () => ({
    ...this.upperCursor
  });
  initialize(version) {
    this.currentVersion = version;
    this.currentWindow = 0;
    this.upperWindowLines = 0;
  }
  print(text) {
    const targetOutput = this.currentWindow === 0 ? this.output : this.upperOutput;
    if (targetOutput.length > 0 && !targetOutput[targetOutput.length - 1].endsWith("\n")) {
      targetOutput[targetOutput.length - 1] += text;
    } else {
      targetOutput.push(text);
    }
  }
  printLine(text) {
    this.print(text + "\n");
  }
  newLine() {
    this.print("\n");
  }
  async readLine(maxLength, timeout) {
    if (this.lineInputs.length === 0) {
      if (timeout !== void 0 && timeout > 0) {
        return { text: "", terminator: 0 };
      }
      throw new Error("No line input available");
    }
    const text = this.lineInputs.shift().substring(0, maxLength);
    return { text, terminator: 13 };
  }
  async readChar(timeout) {
    if (this.charInputs.length === 0) {
      if (timeout !== void 0 && timeout > 0) {
        return 0;
      }
      throw new Error("No character input available");
    }
    return this.charInputs.shift();
  }
  // V5 Screen Model Methods
  setWindow(window) {
    this.currentWindow = window;
  }
  splitWindow(lines) {
    this.upperWindowLines = lines;
    if (lines > 0) {
      this.upperOutput.length = 0;
    }
  }
  eraseWindow(window) {
    if (window === -1) {
      this.output.length = 0;
      this.upperOutput.length = 0;
      this.upperWindowLines = 0;
      this.currentWindow = 0;
    } else if (window === -2) {
      this.output.length = 0;
      this.upperOutput.length = 0;
    } else if (window === 0) {
      this.output.length = 0;
    } else if (window === 1) {
      this.upperOutput.length = 0;
    }
  }
  setCursor(line, column) {
    this.upperCursor = { line, column };
  }
  setTextStyle(style) {
    this.textStyle = style;
  }
  setBufferMode(mode) {
    this.bufferMode = mode;
  }
  getBufferMode() {
    return this.bufferMode;
  }
  showStatusLine(location, score, turns, isTime) {
    this.lastStatusLine = { location, score, turns, isTime };
  }
  quit() {
    this.hasQuit = true;
  }
  restart() {
    this.hasRestarted = true;
    this.output.length = 0;
    this.upperOutput.length = 0;
    this.currentWindow = 0;
    this.upperWindowLines = 0;
  }
  // Test helper methods
  /**
   * Add a line input to the queue
   */
  queueLineInput(text) {
    this.lineInputs.push(text);
  }
  /**
   * Add a character input to the queue
   */
  queueCharInput(char) {
    this.charInputs.push(char);
  }
  /**
   * Get all output as a single string (both windows)
   */
  getFullOutput() {
    const upper = this.upperOutput.join("");
    const lower = this.output.join("");
    return upper + lower;
  }
  /**
   * Get lower window output only
   */
  getLowerOutput() {
    return this.output.join("");
  }
  /**
   * Get upper window output only
   */
  getUpperOutput() {
    return this.upperOutput.join("");
  }
  /**
   * Clear all output
   */
  clearOutput() {
    this.output.length = 0;
    this.upperOutput.length = 0;
  }
  /**
   * Reset the adapter to initial state
   */
  reset() {
    this.output.length = 0;
    this.upperOutput.length = 0;
    this.lineInputs.length = 0;
    this.charInputs.length = 0;
    this.hasQuit = false;
    this.hasRestarted = false;
    this.lastStatusLine = void 0;
    this.currentWindow = 0;
    this.upperWindowLines = 0;
    this.textStyle = 0;
    this.bufferMode = true;
  }
  /**
   * Get current window number
   */
  getCurrentWindow() {
    return this.currentWindow;
  }
  /**
   * Get number of upper window lines
   */
  getUpperWindowLines() {
    return this.upperWindowLines;
  }
};

// node_modules/zmachine/dist/web/WebIOAdapter.js
var WebIOAdapter = class _WebIOAdapter {
  output;
  input;
  status;
  onQuit;
  onRestart;
  lineResolve;
  charResolve;
  currentVersion = 3;
  /** Current active window (0 = lower/main, 1 = upper/status) */
  currentWindow = 0;
  /** Number of lines in upper window */
  upperWindowLineCount = 0;
  /** Get current version */
  getVersion() {
    return this.currentVersion;
  }
  /** Get upper window line count */
  getUpperWindowLines() {
    return this.upperWindowLineCount;
  }
  /** Buffer for upper window text (V4+ games write directly) */
  upperWindowText = "";
  /** Current text style (bitmask: 1=reverse, 2=bold, 4=italic, 8=fixed) */
  textStyle = 0;
  /** Cursor position in upper window (1-based) */
  upperCursor = { line: 1, column: 1 };
  /** Transcript buffer for recording game session */
  transcript = [];
  /** Whether transcript is currently enabled */
  transcriptEnabled = false;
  /** Recorded inputs for playback */
  recordedInputs = [];
  /** Whether recording is enabled */
  isRecording = false;
  /** Playback queue for replaying recorded inputs */
  playbackQueue = [];
  /** Whether playback mode is active */
  isPlayingBack = false;
  constructor(config) {
    this.output = config.outputElement;
    this.input = config.inputElement;
    this.status = config.statusElement;
    this.onQuit = config.onQuit;
    this.onRestart = config.onRestart;
    this.setupInputHandler();
  }
  setupInputHandler() {
    this.input.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && this.lineResolve) {
        const text = this.input.value;
        this.input.value = "";
        if (this.isRecording) {
          this.recordedInputs.push(text);
        }
        this.print(text + "\n");
        this.lineResolve({ text, terminator: 13 });
        this.lineResolve = void 0;
      } else if (this.charResolve) {
        const charCode = e.key.length === 1 ? e.key.charCodeAt(0) : 0;
        if (charCode > 0) {
          e.preventDefault();
          this.charResolve(charCode);
          this.charResolve = void 0;
        }
      }
    });
  }
  initialize(version) {
    this.currentVersion = version;
    this.output.innerHTML = "";
    this.transcript = [];
    this.recordedInputs = [];
  }
  print(text) {
    if (this.transcriptEnabled) {
      this.transcript.push(text);
    }
    if (this.currentWindow === 1 && this.status) {
      this.upperWindowText += text;
      this.status.textContent = this.upperWindowText.replace(/\n/g, " ").trim();
    } else {
      const span = document.createElement("span");
      span.textContent = text;
      this.applyTextStyle(span);
      this.output.appendChild(span);
      this.output.scrollTop = this.output.scrollHeight;
    }
  }
  /**
   * Apply current text style and colors to an element
   * Style bits: 1=reverse, 2=bold, 4=italic, 8=fixed-width
   */
  applyTextStyle(element) {
    if (!(this.textStyle & 1)) {
      if (this.foregroundColor) {
        element.style.color = this.foregroundColor;
      }
      if (this.backgroundColor) {
        element.style.backgroundColor = this.backgroundColor;
      }
    }
    if (this.textStyle & 1) {
      const fg = this.foregroundColor || "var(--text-color, #00ff00)";
      const bg = this.backgroundColor || "var(--bg-color, #0a0a0a)";
      element.style.backgroundColor = fg;
      element.style.color = bg;
    }
    if (this.textStyle & 2) {
      element.style.fontWeight = "bold";
    }
    if (this.textStyle & 4) {
      element.style.fontStyle = "italic";
    }
    if (this.textStyle & 8) {
      element.style.fontFamily = "monospace";
    }
  }
  printLine(text) {
    this.print(text + "\n");
  }
  newLine() {
    this.output.appendChild(document.createElement("br"));
    this.output.scrollTop = this.output.scrollHeight;
  }
  async readLine(maxLength, timeout) {
    if (this.isPlayingBack && this.playbackQueue.length > 0) {
      const text = this.playbackQueue.shift();
      this.print(">" + text + "\n");
      await new Promise((r) => setTimeout(r, 100));
      return { text, terminator: 13 };
    }
    this.print(">");
    this.input.focus();
    this.input.maxLength = maxLength;
    return new Promise((resolve) => {
      this.lineResolve = resolve;
      if (timeout && timeout > 0) {
        const timeoutMs = timeout * 100;
        setTimeout(() => {
          if (this.lineResolve === resolve) {
            const text = this.input.value;
            this.input.value = "";
            this.lineResolve = void 0;
            resolve({ text, terminator: 0 });
          }
        }, timeoutMs);
      }
    });
  }
  async readChar(timeout) {
    this.input.focus();
    return new Promise((resolve) => {
      this.charResolve = resolve;
      if (timeout && timeout > 0) {
        const timeoutMs = timeout * 100;
        setTimeout(() => {
          if (this.charResolve === resolve) {
            this.charResolve = void 0;
            resolve(0);
          }
        }, timeoutMs);
      }
    });
  }
  showStatusLine(location, scoreOrHours, turnsOrMinutes, isTime) {
    if (!this.status)
      return;
    const rightSide = isTime ? `Time: ${scoreOrHours}:${turnsOrMinutes.toString().padStart(2, "0")}` : `Score: ${scoreOrHours}  Moves: ${turnsOrMinutes}`;
    this.status.innerHTML = `
      <span class="location">${this.escapeHtml(location)}</span>
      <span class="score">${rightSide}</span>
    `;
  }
  escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }
  setWindow(window) {
    if (window === 1 && this.currentWindow !== 1) {
      this.upperWindowText = "";
    }
    this.currentWindow = window;
  }
  splitWindow(lines) {
    this.upperWindowLineCount = lines;
    if (lines > 0) {
      this.upperWindowText = "";
      this.upperCursor = { line: 1, column: 1 };
      if (this.status) {
        this.status.textContent = "";
      }
    }
  }
  setCursor(line, column) {
    if (this.currentWindow === 1) {
      this.upperCursor = { line, column };
      if (column === 1) {
        this.upperWindowText = "";
      }
    }
  }
  getCursor() {
    return { ...this.upperCursor };
  }
  eraseLine() {
    if (this.currentWindow === 1 && this.status) {
      this.upperWindowText = "";
    }
  }
  setTextStyle(style) {
    if (style === 0) {
      this.textStyle = 0;
    } else {
      this.textStyle = style;
    }
  }
  /** Z-machine color palette */
  static COLORS = {
    2: "#000000",
    // black
    3: "#ff0000",
    // red
    4: "#00ff00",
    // green
    5: "#ffff00",
    // yellow
    6: "#0000ff",
    // blue
    7: "#ff00ff",
    // magenta
    8: "#00ffff",
    // cyan
    9: "#ffffff"
    // white
  };
  /** Current foreground color (CSS) */
  foregroundColor = "";
  /** Current background color (CSS) */
  backgroundColor = "";
  setForegroundColor(color) {
    if (color === 1) {
      this.foregroundColor = "";
    } else if (color in _WebIOAdapter.COLORS) {
      this.foregroundColor = _WebIOAdapter.COLORS[color];
    }
  }
  setBackgroundColor(color) {
    if (color === 1) {
      this.backgroundColor = "";
    } else if (color in _WebIOAdapter.COLORS) {
      this.backgroundColor = _WebIOAdapter.COLORS[color];
    }
  }
  /** Audio context for sound effects (lazy initialized) */
  audioContext;
  /**
   * Play a sound effect
   * @param number - Sound number (1 = high beep, 2 = low beep, 3+ = sampled sounds)
   * @param effect - Effect type (1 = prepare, 2 = start, 3 = stop, 4 = finish)
   * @param volume - Volume (1-8, or 255 for default)
   */
  soundEffect(number, effect, volume) {
    if (effect !== 2)
      return;
    if (number !== 1 && number !== 2)
      return;
    try {
      if (!this.audioContext) {
        this.audioContext = new AudioContext();
      }
      const ctx = this.audioContext;
      const oscillator = ctx.createOscillator();
      const gainNode = ctx.createGain();
      oscillator.frequency.value = number === 1 ? 800 : 400;
      oscillator.type = "square";
      const vol = volume === 255 ? 0.3 : Math.min(volume / 8, 1) * 0.5;
      gainNode.gain.value = vol;
      oscillator.connect(gainNode);
      gainNode.connect(ctx.destination);
      oscillator.start();
      oscillator.stop(ctx.currentTime + 0.1);
    } catch {
    }
  }
  eraseWindow(window) {
    if (window === -1) {
      this.output.innerHTML = "";
      this.upperWindowText = "";
      if (this.status)
        this.status.textContent = "";
      this.upperWindowLineCount = 0;
      this.currentWindow = 0;
    } else if (window === -2) {
      this.output.innerHTML = "";
      this.upperWindowText = "";
      if (this.status)
        this.status.textContent = "";
    } else if (window === 0) {
      this.output.innerHTML = "";
    } else if (window === 1) {
      this.upperWindowText = "";
      if (this.status)
        this.status.textContent = "";
    }
  }
  quit() {
    this.print("\n[Game ended]\n");
    this.input.disabled = true;
    this.onQuit?.();
  }
  restart() {
    this.output.innerHTML = "";
    this.onRestart?.();
  }
  // Save/restore through browser file download/upload
  async save(data) {
    try {
      const buffer = data.buffer.slice(data.byteOffset, data.byteOffset + data.byteLength);
      const blob = new Blob([buffer], { type: "application/octet-stream" });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `zmachine-save-${Date.now()}.qzl`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
      const base64 = btoa(String.fromCharCode(...data));
      localStorage.setItem("zmachine-save", base64);
      this.print("[Game saved]\n");
      return true;
    } catch {
      this.print("[Save failed]\n");
      return false;
    }
  }
  async restore() {
    return new Promise((resolve) => {
      const fileInput = document.createElement("input");
      fileInput.type = "file";
      fileInput.accept = ".qzl,.sav";
      fileInput.onchange = async () => {
        const file = fileInput.files?.[0];
        if (file) {
          try {
            const arrayBuffer = await file.arrayBuffer();
            const data = new Uint8Array(arrayBuffer);
            this.print("[Game restored]\n");
            resolve(data);
          } catch {
            this.print("[Restore failed]\n");
            resolve(null);
          }
        } else {
          const base64 = localStorage.getItem("zmachine-save");
          if (base64) {
            try {
              const binary = atob(base64);
              const data = new Uint8Array(binary.length);
              for (let i = 0; i < binary.length; i++) {
                data[i] = binary.charCodeAt(i);
              }
              this.print("[Game restored from backup]\n");
              resolve(data);
            } catch {
              this.print("[No saved game found]\n");
              resolve(null);
            }
          } else {
            this.print("[No saved game found]\n");
            resolve(null);
          }
        }
      };
      fileInput.click();
    });
  }
  /**
   * Set output stream state
   * @param stream - Stream number (1=screen, 2=transcript, 3=memory, 4=script)
   * @param enabled - Whether to enable or disable the stream
   */
  setOutputStream(stream, enabled) {
    if (stream === 2) {
      this.transcriptEnabled = enabled;
      if (enabled && this.transcript.length === 0) {
        this.transcript.push(`--- Transcript started: ${(/* @__PURE__ */ new Date()).toLocaleString()} ---

`);
      }
    }
  }
  /**
   * Check if transcript is enabled
   */
  isTranscriptEnabled() {
    return this.transcriptEnabled;
  }
  /**
   * Download the transcript as a text file
   */
  downloadTranscript() {
    const text = this.transcript.join("");
    const blob = new Blob([text], { type: "text/plain" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `zmachine-transcript-${Date.now()}.txt`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    this.print("[Transcript downloaded]\n");
  }
  /**
   * Get transcript content as string
   */
  getTranscript() {
    return this.transcript.join("");
  }
  // ============================================
  // Input Recording & Playback
  // ============================================
  /**
   * Start recording user inputs
   */
  startRecording() {
    this.isRecording = true;
    this.recordedInputs = [];
    this.print("[Recording started]\n");
  }
  /**
   * Stop recording user inputs
   */
  stopRecording() {
    this.isRecording = false;
    this.print(`[Recording stopped - ${this.recordedInputs.length} commands captured]
`);
  }
  /**
   * Check if recording is active
   */
  isRecordingActive() {
    return this.isRecording;
  }
  /**
   * Get the recorded inputs
   */
  getRecordedInputs() {
    return [...this.recordedInputs];
  }
  /**
   * Download recorded inputs as a JSON file
   */
  downloadRecording() {
    const data = {
      version: 1,
      timestamp: (/* @__PURE__ */ new Date()).toISOString(),
      commands: this.recordedInputs
    };
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `zmachine-recording-${Date.now()}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    this.print("[Recording downloaded]\n");
  }
  /**
   * Load a recording for playback
   * @param commands - Array of command strings to play back
   */
  loadPlayback(commands) {
    this.playbackQueue = [...commands];
    this.isPlayingBack = true;
    this.print(`[Playback loaded - ${commands.length} commands queued]
`);
  }
  /**
   * Load playback from a file
   * @returns Promise that resolves when file is loaded
   */
  async loadPlaybackFromFile() {
    return new Promise((resolve) => {
      const fileInput = document.createElement("input");
      fileInput.type = "file";
      fileInput.accept = ".json";
      fileInput.onchange = async () => {
        const file = fileInput.files?.[0];
        if (file) {
          try {
            const text = await file.text();
            const data = JSON.parse(text);
            if (data.commands && Array.isArray(data.commands)) {
              this.loadPlayback(data.commands);
              resolve(true);
            } else {
              this.print("[Invalid recording file]\n");
              resolve(false);
            }
          } catch {
            this.print("[Failed to load recording]\n");
            resolve(false);
          }
        } else {
          resolve(false);
        }
      };
      fileInput.click();
    });
  }
  /**
   * Stop playback mode
   */
  stopPlayback() {
    this.isPlayingBack = false;
    this.playbackQueue = [];
    this.print("[Playback stopped]\n");
  }
  /**
   * Check if playback is active
   */
  isPlaybackActive() {
    return this.isPlayingBack && this.playbackQueue.length > 0;
  }
  /**
   * Get remaining commands in playback queue
   */
  getPlaybackRemaining() {
    return this.playbackQueue.length;
  }
};
export {
  DecodeError,
  Dictionary,
  Header,
  IOError,
  Memory,
  MemoryError,
  ObjectError,
  ObjectTable,
  OpcodeError,
  Properties,
  RunState,
  SaveError,
  StackError,
  TestIOAdapter,
  Tokenizer,
  WebIOAdapter,
  ZCharDecoder,
  ZMachine,
  ZMachineError,
  encodeText,
  encodeToZChars,
  formatAddress,
  formatByte,
  formatWord,
  toSigned16,
  toUnsigned16,
  unicodeToZscii,
  unpackRoutineAddress,
  unpackStringAddress,
  zsciiToUnicode
};
