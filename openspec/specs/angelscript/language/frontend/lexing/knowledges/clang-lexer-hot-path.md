# Clang lexer hot-path lessons for AngelScript

## Reusable Insight

A Clang-shaped lexer gains most of its practical value from ownership and data-layout choices: immutable buffer pointer scanning, compact source-referential tokens, session identifier interning, explicit modes, and rare slow paths. These choices can be adopted independently of C/C++ preprocessing and grammar.

## Evidence

- Clang `Lexer` operates over buffer pointers and fills a caller-provided `Token` instead of allocating a token object for every result.
- `Token` stores location, length, kind, flags, and a compact payload; spelling remains in source storage.
- `IdentifierInfo` interns names and retains keyword metadata so repeated identifiers do not require repeated string ownership and classification.
- Common ASCII identifiers, punctuation, whitespace, and digits are separated from Unicode, escape, and diagnostic slow paths.
- The preserved AngelScript tokenizer obtains Unicode policy from `asCScriptEngine`, while Parser owns the cursor and trivia filtering, so that split is not independently deterministic.

## Boundaries

- Do not copy Clang's macro expansion stack, include behavior, C token semantics, raw `SourceLocation` encoding, or arbitrary cache sizes.
- Identifier-table addresses and insertion order are compilation-local conveniences, not stable semantic keys.
- SIMD, fixed lookahead depth, and numeric-literal eager decoding require local measurements before adoption.
- A one-machine elapsed time is not a portable regression threshold.

## Application

Pass frozen options into a cursor-owning `asCTokenizer`, return non-owning tokens by pull, keep line lookup and spelling extraction outside the hot loop, intern names per session, and retain full streams only for explicit preprocessing or tooling needs. Measure bytes, tokens, allocations, and peak memory against a versioned corpus.

## Sources

- Local LLVM/Clang 22.1.8 source at `D:/LLVM/llvm-project-22.1.8.src`
- `clang/include/clang/Lex/Lexer.h`
- `clang/include/clang/Lex/Token.h`
- `clang/include/clang/Basic/IdentifierTable.h`
- `clang/lib/Lex/Lexer.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_frontend_tokenizer.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_frontend_parser.cpp`
