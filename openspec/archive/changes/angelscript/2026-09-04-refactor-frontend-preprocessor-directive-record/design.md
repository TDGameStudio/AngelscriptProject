## Context

The existing `FAngelscriptPreprocessor::ParseIntoChunks` recognizes conditional directives while simultaneously chunking declarations, collecting UE annotation records, finding imports, rewriting text, and preparing runtime descriptors. It blanks directive and inactive text, leaving insufficient structure for AST comparison or tooling backquery. The reconstruction instead needs one narrow conditional stage between the raw lexer and Parser.

Clang supplies three distinct lessons:

- `PPCallbacks` exposes conditional events but does not itself retain a model.
- `PreprocessingRecord` is an optional sidecar and deliberately is not a complete conditional tree.
- clangd's `DirectiveTree` explicitly preserves raw code, directives, conditional branches, and the selected branch separately from the typed AST.

The AngelScript model follows that separation while retaining the project's explicit `(FileID, UTF-8 byte offset)` coordinates rather than Clang's manager-global raw `SourceLocation` encoding.

## Goals / Non-Goals

**Goals:**

- Route one configuration's active tokens deterministically.
- Preserve a complete nested directive tree, including inactive branches.
- Retain skipped ranges and efficient range-to-record backquery.
- Preserve `#restrict usage allow/disallow` as a typed, validated directive record.
- Tie every local identifier and view to one immutable source snapshot.
- Produce exact diagnostics and fail closed without runtime publication.
- Use UE core types freely inside the same ThirdParty module where they improve ownership and implementation clarity.

**Non-Goals:**

- C-compatible `#define`, replacement lists, token pasting, stringification, variadics, or recursive macro expansion.
- Keyword-driven module loading or dependency inference in preprocessing.
- UE annotation semantics, UHT replacement, reflection descriptors, wrapper generation, or arbitrary preprocess hooks.
- A multi-configuration typed AST or typed nodes for inactive source.
- Serialization of raw snapshot-local IDs.

## Decisions

### Place the new implementation behind the isolated frontend boundary

The new files live under `ThirdParty/angelscript/source/frontend/`, enter the engine namespace with `BEGIN_AS_NAMESPACE`, and then use the lowercase nested `namespace frontend`. Public leaf types use their final names with no `V2` suffix. Root-level `as_source_*`, AST, parser, tokenizer, and current UE `FAngelscriptPreprocessor` sources remain dormant/reference inputs during reconstruction; this Change does not modify them into a second shared authority.

External readiness is coordinator-managed:

```text
NativeEngine CQTest foundation ───────────────┐
immutable source/diagnostic snapshot ────────┼─> this Change
raw lexer/token pipeline ─────────────────────┘
```

These are not representable as local `task_graph` edges because OpenSpec task IDs are Change-local. Task 1.1 starts only after the three sibling contracts are available in the integration workspace.

### Use a complete tree plus a separate record index

The proposed logical shape is:

```text
asCPreprocessor
└─ ProcessDirectives() -> asSDirectiveProcessResult
   ├─ SourceSnapshot lease
   ├─ FrozenConfiguration + digest
   ├─ RawTokenBuffer
   ├─ ActiveTokenBuffer
   ├─ Active-to-raw token mappings
   ├─ asCDirectiveTree
   │  └─ chunks: Code | Directive | Conditional
   │     └─ branches[] + EndDirective + Taken
   └─ asCPreprocessingRecord
      ├─ source-ordered directive/branch records
      ├─ skipped ranges
      └─ per-file interval/range index
```

`asSDirectiveProcessResult` is an internal phase product rather than the final owner-visible preprocessing result. The later reflection/dependency Change makes `asCPreprocessor` return the concrete `FAngelscriptPreprocessResult` and retains this directive product within that result's source/preprocessing lease. `as_directive_kinds.def` is the single taxonomy source for directive enumeration, spelling, dump names, and exhaustive switches. Tree node and record identifiers are dense snapshot-local values; public query entry points validate their owner.

### Keep the condition language deliberately small

The first contract preserves the behavior the user explicitly requested: named boolean flags, optional single `!` for `#if`/`#elif`, and the `#ifdef`/`#ifndef` forms. `#elif` evaluates only when its parent context is active and no previous sibling branch was taken. Nested directives in an inactive parent are parsed for balance but their conditions are not evaluated.

Adding arithmetic expressions, `defined(...)`, or compound boolean operators would be a separately specified language feature. It must not arrive accidentally through a C preprocessor implementation.

`#restrict usage allow <pattern>` and `#restrict usage disallow <pattern>` are parsed through their own typed directive grammar and stored in the same tree/range index. The policy and non-empty pattern are separate typed fields; the directive does not participate in conditional expression evaluation. `#include` is rejected at its authored range, and its diagnostic never points users toward `import`; the new frontend derives cross-file dependencies from declarations later.

### Keep inactive source outside the typed AST

One source/configuration pair produces one active semantic snapshot. Inactive branches remain available through raw tokens, branch ranges, and skipped ranges. A future IDE may build a syntax-only or alternate-configuration product, but mutually exclusive declarations are never inserted into one canonical typed AST with ambiguous validity.

### Query by range instead of attaching a record to every AST node

AST nodes keep their normal source ranges. Backquery uses a per-file index to answer:

- records overlapping or containing a range;
- branch ancestry for a location;
- whether two locations are in different conditional regions;
- whether a range crosses a directive boundary;
- skipped ranges associated with a conditional branch.

This follows libclang's practical range-query relationship between AST and `PreprocessingRecord`. Direct record IDs remain reserved for producer-owned relations that cannot be recovered from range; this Change introduces no blanket AST field.

### Make snapshot ownership explicit

One root result may use `TSharedPtr<const ...>` to retain the immutable snapshot and its token/record storage. Child records do not each own a shared pointer. Every ID is meaningful only with that snapshot. Clearing or rebuilding creates a new identity/epoch rather than reusing old handles as if they were current.

`FString`, `FName`, `TArray`, `TMap`, and `TSharedPtr` are allowed implementation types. Canonical source offsets nevertheless remain UTF-8 byte offsets into frozen bytes, and durable identity never uses an `FName` internal index or pointer value.

### Publish atomically after structural validation

The preprocessor builds a candidate tree, active stream, record table, index, and diagnostics. It validates balanced delimiters, branch ordering, range bounds, source order, and index ownership before returning a successful result. Failure may retain an inspectable recovery tree for diagnostics, but Parser never receives it as a valid active stream.

## Compatibility and Migration

The first migration consumer is the reconstructed Parser, not the current production `FAngelscriptPreprocessor`. No shadow comparison or dual write is required in this Change. Later reflection/dependency work consumes active annotation tokens and typed declarations; it does not ask this layer to recreate legacy descriptor side effects or a keyword-driven module graph.

Any persisted form introduced later must encode logical source identity, content/configuration digests, and ranges, then relocate into a new snapshot. It must not dump local IDs or container memory.

## Risks / Trade-offs

- A full directive tree uses more memory than blanking text. Compact token ranges and snapshot-local IDs bound the cost and preserve tooling value that cannot be reconstructed later.
- A range index can become stale if source storage mutates. Immutability and atomic result publication remove that state.
- Restricting condition syntax may reject expressions accepted by an accidental legacy path. The restriction is intentional and testable; expansion requires an explicit language decision.
- UE containers simplify same-module integration but can tempt persistence of implementation details. Canonical bytes and stable anchors remain representation-independent.
- Cross-Change readiness cannot be encoded in this local DAG. The coordinator must gate Task 1.1 on the named sibling contracts.

## Rejected Alternatives

- Copy Clang's complete C macro engine, `MacroInfo`, or `TokenLexer` stack.
- Treat `PreprocessingRecord` as a lossless conditional tree.
- Store only a flat bag of conditional ranges without branch nesting and taken-state semantics.
- Put preprocessing IDs or pointers on every AST node.
- Parse inactive branches into the canonical typed AST.
- Add an independent regex annotation scanner or synthesize imports before typed declaration analysis.
- Persist raw file IDs, pointer values, `FName` indices, or source-manager-local encodings.
- Keep legacy and reconstructed preprocessors as long-term synchronized authorities.
