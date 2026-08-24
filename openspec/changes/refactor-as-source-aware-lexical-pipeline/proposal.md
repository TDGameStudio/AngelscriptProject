## Why

The maintained AngelScript frontend currently tokenizes through `asCTokenizer` into a minimal `{type, position, length}` record while `asCParser` rewinds by byte position and asks the tokenizer to scan the same text again. In parallel, `FAngelscriptPreprocessor::ParseIntoChunks` maintains a second hand-written scanner for comments, strings, identifiers, brackets, directives, and UE declaration shapes, so lexical truth, source provenance, recovery, and future tooling are split across two implementations.

The active `refactor-as-canonical-typed-ast-compiler` change establishes `SourceManager -> Parser + Sema -> ASTContext`, but it intentionally did not specify the lexical layer between source storage and Parser. A source-aware, AngelScript-native lexical pipeline is therefore a prerequisite for that compiler architecture, reliable diagnostics/tooling, and later incremental or LLVM-facing work; it is not a replacement AST or a new language semantics project.

## What Changes

- Add an AngelScript-native, Clang-inspired lexical architecture: `SourceManager -> RawLexer -> source-preparation/host token source -> TokenBuffer + TokenCursor -> Parser`.
- Replace position-only parser tokens with compact source-aware token records carrying kind, source location/range, length, lexical flags, and optional identifier/literal references without embedding Parser, AST, Runtime, UE, Clang, or LLVM objects.
- Separate raw spelling recognition from keyword lookup, identifier interning, literal validation/decoding, trivia policy, and Parser grammar decisions.
- Give Parser indexed lookahead and explicit checkpoint/restore/commit through `TokenCursor`, removing production byte-position rewind and accidental retokenization while preserving current recovery and depth limits.
- Introduce a shared lexical-facts adapter for the UE preprocessor so it no longer independently guesses comment, string, identifier, and delimiter boundaries. UE-specific directives, descriptor extraction, generated source, module/provider policy, and source rewriting remain host-owned.
- Preserve `asIScriptEngine::ParseToken` and the accepted AngelScript tokenization behavior as a compatibility facade over the new lexer until a separately versioned public token API is justified.
- Integrate compact source locations with the `asCSourceManager` foundation planned by `refactor-as-canonical-typed-ast-compiler`; this change owns the lexical substrate and coordinates rather than duplicates that change's AST/Sema ownership.
- Use shadow/differential migration: freeze tokenizer, parser, diagnostics, preprocessor, and Script-corpus baselines; run old and new lexical paths over identical immutable inputs; migrate consumers; then remove duplicate production scanners only after parity gates pass.
- Keep live token buffers module/build-local. Cache V2 and public AST snapshots may persist stable source keys, mappings, ranges, and content identities, but MUST NOT persist token cursor state, lexer pointers, or a mandatory full token stream.
- **BREAKING**: internal Parser/tokenizer structures and UE preprocessor scanning helpers may be removed after all maintained consumers migrate. No public `ParseToken` behavior or accepted source syntax is intentionally broken by this change.
- Do not link or copy Clang, implement C/C++ macro expansion, adopt Clang token kinds, change Unicode/literal language semantics, implement canonical AST/Sema/LLVM lowering, or create a permanent dual lexer.

## Capabilities

### New Capabilities

- `as-source-aware-lexical-pipeline`: Defines SourceManager-backed tokens, raw lexing, identifier/keyword/literal classification, TokenBuffer/TokenCursor behavior, Parser integration, deterministic inspection, public `ParseToken` compatibility, lifecycle, parity, and final legacy-tokenizer cutover.
- `as-host-preprocessor-lexical-integration`: Defines the shared lexical-facts boundary used by the UE preprocessor while preserving host-owned directives, descriptors, rewrites, generated-source provenance, source-provider policy, and failure containment.

### Modified Capabilities

None. The related `as-canonical-typed-ast` and `as-canonical-compiler-pipeline` capabilities exist only inside the still-active `refactor-as-canonical-typed-ast-compiler` change rather than the shared `openspec/specs/` baseline. This change records an explicit coordination contract instead of creating competing delta specs for unarchived capabilities.

## Impact

- Maintained fork frontend: `as_tokenizer.*`, `as_tokendef.h`, `as_parser.*`, `as_scriptcode.*`, `as_scriptnode.*`, public `angelscript.h`, new source/token/lexer/cursor components, diagnostics, and Standard C++ source lists.
- UE Runtime host: `FAngelscriptPreprocessor`, a new lexical adapter, preprocessor descriptors/transforms, generated-source provenance, virtual script paths, Hot Reload inputs, and compile orchestration.
- Tests: native tokenizer/parser/source-position suites, UE preprocessor suites, Script corpus, Standalone CTests, deterministic dump tests, performance budgets, and final forbidden-symbol/source scans.
- Compatibility: public `ParseToken`, current accepted syntax, maintained diagnostics, compile success/failure, source coordinates, UE descriptors, generated output, and VM behavior remain parity gates. Internal structures are not compatibility contracts.
- Persistence: Cache V2 gains no token-stream authority. Source mappings and ranges remain stable DTO data owned by the source/canonical-AST records; stale lexical implementation versions cause normal source recompilation rather than token deserialization.
- Dependencies: no Clang/LLVM library or source dependency is added. Local `Reference/llvm-project` is architecture evidence only.
- Planning: implement this lexical change before or alongside the early SourceManager/Parser milestones of `refactor-as-canonical-typed-ast-compiler`; do not mark that change's tasks complete without direct evidence from its own acceptance gates.
