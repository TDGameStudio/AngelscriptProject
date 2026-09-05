## Context

The existing tokenizer is exported and `GetToken` is public, but construction and helper functions are protected, it stores `const asCScriptEngine*`, and Unicode identifier handling reads `engine->ep.allowUnicodeIdentifiers`. The current Parser retains `sourcePos`, a one-token rewind slot, filters trivia, and invokes `engine->tok.GetToken` directly. Making more helper methods public would not remove the real coupling.

Clang's Lexer scans immutable buffer pointers, returns a compact `Token`, keeps identifier/keyword metadata in `IdentifierInfo`, and optimizes ASCII common cases while routing uncommon Unicode and diagnostics to slower paths. Its preprocessor, C grammar, macro token-lexer stack, and raw SourceLocation representation are outside this AngelScript boundary.

## Goals / Non-Goals

**Goals:**

- Make tokenization independent of `asCScriptEngine`, Builder, Parser, and mutable globals.
- Use a streaming pull contract with compact source-referential tokens.
- Intern identifiers and generate consistent token metadata from one declarative list.
- Guarantee forward progress and precise structured diagnostics for arbitrary bytes.
- Measure allocations and throughput without prematurely setting machine-specific time thresholds.

**Non-Goals:**

- Implement directives, macro expansion, declaration parsing, or semantic analysis.
- Remove or redefine legacy syntax in this Change.
- Expose the new tokenizer through stable `angelscript.h` ABI.
- Switch current production parsing to the new implementation or maintain two production paths.

## Decisions

### `asCTokenizer` owns lexical stream state

The new nested `frontend::asCTokenizer` beneath `BEGIN_AS_NAMESPACE` owns the current byte pointer, buffer end, trivia mode, start-of-line state, and diagnostic reference. It is constructed from `asCSourceSnapshot`, a file/buffer selection, and frozen `asSLexOptions`. The tokenizer has no Engine pointer and no callback that can mutate lexical policy while scanning.

The public-internal surface is construction, reset to a validated source start when needed, `Lex(asCToken&)`, and bounded state inspection required by Parser/tests. Character classifiers and scanning routines stay private. This satisfies reuse without turning implementation helpers into an API.

### Tokens borrow source and carry only kind-specific payload

`asCToken` contains kind, source range/start-length, hot flags such as start-of-line and leading-space, and a compact discriminated payload. Identifier-like tokens refer to `asCIdentifierInfo`; literals initially retain source spelling plus validated lexical metadata rather than eagerly allocating semantic values.

One `.def` token-kind list drives the kind enum, display name, fixed spelling, and classification predicates. It is a local code-generation pattern, not an LLVM/TableGen dependency.

### Pull is the default; buffering belongs to consumers

`Lex(Token&)` is the only core advancement path. Parser later owns a small bounded token buffer suitable for grammar lookahead and recovery. The preprocessor may capture selected raw tokens and ranges for its directive record. Tests may request full capture. The tokenizer itself never requires complete-stream allocation.

### Hot and slow paths are explicit

The scanner compares direct pointers against an immutable end pointer. ASCII identifiers, whitespace, digits, fixed punctuation, and common strings use branch-efficient paths. Unicode decoding, escape validation, malformed input, and diagnostic construction are separate slow paths. Line/column lookup stays lazy in SourceManager.

No particular cache width or SIMD implementation is mandated before measurement. The stable invariants are no common-token heap allocation, no spelling copy, deterministic output, and forward progress.

### Isolation before unified cutover

Files live under `source/frontend/` in the fork-internal namespace and compile as part of the Runtime module, but only replacement tests call them. Existing root `as_tokenizer.*` and Parser integration remain reference/production code until one later unified cutover; no long-lived runtime selector or `V2` class names are introduced.

The new implementation unit uses the unique basename `as_frontend_tokenizer.cpp` because UBT's non-Unity intermediate outputs reject a second `as_tokenizer.cpp` within the same module. This build-artifact prefix does not alter the final internal class name `frontend::asCTokenizer` or its conceptual header name.

## Risks / Trade-offs

- A pull API can make arbitrary parser backtracking expensive. The later Parser design must keep lookahead bounded and retain only explicit recovery checkpoints.
- Identifier interning reduces repeated strings but makes session lifetime important. Tokens cannot outlive their source snapshot and identifier table; the owning compilation result enforces that lease.
- Unicode correctness can erode an optimized ASCII loop. Separate property tests and corpus measurements keep both paths observable.
- Microbenchmarks inside a UE process include noise. They record corpus size and allocation invariants; elapsed time remains comparative evidence until a dedicated performance contract is justified.
