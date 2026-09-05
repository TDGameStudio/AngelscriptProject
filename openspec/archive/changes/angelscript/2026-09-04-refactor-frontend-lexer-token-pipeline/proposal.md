## Why

The current `asCTokenizer` recognizes individual tokens but retains an `asCScriptEngine` pointer and reads mutable engine properties such as Unicode-identifier policy. Parser owns the character cursor, performs trivia filtering, and calls the engine tokenizer directly. That arrangement prevents a frozen compilation session, makes isolated lexical testing awkward, and blocks deterministic parallel frontend work.

The reconstructed lexer should follow the proven shape of Clang's hot path: scan an immutable buffer directly, return compact non-owning tokens through a pull API, intern identifiers once per session, and keep rare Unicode or diagnostic work off the common ASCII path. It should not copy Clang's C preprocessor or grammar.

## What Changes

- Add frozen frontend and lex options with no live Engine reads.
- Rebuild `asCTokenizer` as the cursor-owning, pull-based lexer in the fork-internal lowercase `frontend` namespace.
- Add a compact token contract, declarative token-kind list, direct UTF-8 character stream, and session-local identifier table.
- Support explicit trivia/raw modes and optional retained-token capture only for consumers that request it.
- Establish correctness, progress, concurrency, allocation, and throughput evidence under one focused NativeEngine Lexer prefix.
- Leave the current production tokenizer and Parser routing untouched until unified cutover.

## Capabilities

### New Capabilities

- `angelscript/language/frontend/lexing`: Engine-independent lexical options, pull tokenization, token representation, identifier interning, recovery, and performance invariants.

### Modified Capabilities

None.

## Impact

Future implementation adds isolated ThirdParty frontend source and replacement tests in the `Plugins/Angelscript` submodule, then synchronizes one parent-repository capability spec. It does not modify AngelScript syntax, introduce macro expansion, remove the legacy `import` token from old code, change the stable public `angelscript.h` ABI, or route production Parser/Builder/Engine calls through the new lexer.
