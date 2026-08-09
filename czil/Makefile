CC ?= cc
CFLAGS ?= -std=c11 -Wall -Wextra -O2 -Iinclude

SRC = src/arena.c src/value.c src/reader.c src/eval.c src/zmodel.c src/ztext.c src/zabbrev.c src/zcode.c
HDR = include/czil.h include/zmodel.h src/czil_internal.h

czil-read: $(SRC) tools/czil-read.c $(HDR)
	$(CC) $(CFLAGS) $(SRC) tools/czil-read.c -o $@

czil-eval: $(SRC) tools/czil-eval.c $(HDR)
	$(CC) $(CFLAGS) $(SRC) tools/czil-eval.c -o $@

czil-build: $(SRC) tools/czil-build.c $(HDR)
	$(CC) $(CFLAGS) $(SRC) tools/czil-build.c -o $@

czil-compile: $(SRC) tools/czil-compile.c $(HDR)
	$(CC) $(CFLAGS) $(SRC) tools/czil-compile.c -o $@

z3dict: src/ztext.c tools/z3dict.c $(HDR)
	$(CC) $(CFLAGS) src/ztext.c tools/z3dict.c -o $@

test: czil-read czil-eval czil-build czil-compile z3dict
	./tests/run.sh

clean:
	rm -f czil-read czil-eval czil-build czil-compile z3dict

.PHONY: test clean

# Bare WebAssembly build (no emscripten JS runtime): czil.wasm exposes a
# tiny ABI (host.read_file import + czil_compile/czil_output exports) and
# dist/czil-compile.mjs is a hand-rolled ~90 line Node loader.
wasm:
	emcc -O3 -msimd128 -std=c11 -sSTANDALONE_WASM -sSUPPORT_LONGJMP=wasm \
	  -sALLOW_MEMORY_GROWTH=1 --no-entry -sEXPORTED_FUNCTIONS=_malloc,_free \
	  -Iinclude $(SRC) tools/czil-wasm.c -o dist/czil.wasm

.PHONY: wasm
