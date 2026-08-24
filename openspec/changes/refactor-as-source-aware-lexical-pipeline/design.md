## Context

The maintained fork has two lexical authorities today.

The core frontend calls `asCTokenizer::GetToken` from `asCParser::GetToken`. The Parser receives a small `sToken` containing token kind, byte position, and length. Parser lookahead and recovery save a byte position, later call `RewindTo`, and tokenize the same source again. Source row/column conversion remains a separate `asCScriptCode` concern, so a token is not intrinsically tied to a stable authored, processed, or generated source identity.

The UE host independently scans source in `FAngelscriptPreprocessor::ParseIntoChunks`. It must avoid interpreting text inside comments and string literals while recognizing directives, identifiers, delimiters, `UCLASS`/`USTRUCT`/property/function shapes, namespaces, imports, and generated-code boundaries. This code does useful host work, but it also duplicates low-level lexical questions already answered by `asCTokenizer`. The two implementations can drift; for example, identifier-boundary handling and literal/comment edge cases have historically required separate fixes and tests.

The active `refactor-as-canonical-typed-ast-compiler` OpenSpec already chooses an AngelScript-native, Clang-inspired `SourceManager -> Parser + Sema -> ASTContext` architecture. It owns the eventual canonical typed AST, Sema, Bytecode CodeGen, public AST snapshots, and Cache V2 AST DTOs. It does not currently name a Lexer, token model, buffered cursor, or host-preprocessor lexical boundary. This change fills that missing layer without becoming a second AST/compiler design.

Clang is used as an architectural reference, not a dependency. The useful ideas are stable `SourceLocation`, compact tokens, a Lexer that advances monotonically, a token-producing preprocessor/source layer, Parser consumption through current/lookahead tokens, and a clear separation between spelling and semantic AST. AngelScript does not need Clang's C/C++ macro language, header search, PCH/module machinery, Objective-C/C++ token semantics, or concrete classes.

This is a record-only, plan-now change. No plugin source is modified by creating it. Future implementation is a dual-repository operation: OpenSpec records are committed in the parent repository, while maintained frontend/UE host/test changes are committed first in the `Plugins/Angelscript` submodule and then published through the parent gitlink.

## Goals / Non-Goals

**Goals:**

- Establish one source-aware lexical truth for the maintained frontend and the low-level scanning needs of the UE preprocessor.
- Preserve accepted AngelScript syntax, public `ParseToken` behavior, compile acceptance/rejection, maintained diagnostics, source coordinates, UE descriptors/transforms, and VM-observable behavior.
- Ensure each immutable source-buffer generation is scanned monotonically; Parser backtracking uses token indices rather than re-running the lexer over the same bytes.
- Make authored, processed, and generated source provenance available from token ranges through `asCSourceManager` without storing section strings or source owners in every token.
- Separate raw spelling recognition, trivia, identifiers, keywords, literals, host directives, Parser grammar, and Sema responsibilities.
- Provide deterministic token dumps and differential oracles suitable for tokenizer, Parser, preprocessor, Script-corpus, Standalone, and later canonical-AST work.
- Keep core components standard C++ and usable by both UE and Standalone without Unreal, Clang, or LLVM dependencies.
- Make the lexical interface a clean input boundary for the existing Parser first and the canonical Parser+Sema pipeline later.
- Bound malformed-input behavior, memory use, token counts, lookahead, checkpoints, and source offsets so untrusted script text cannot cause non-progress or arithmetic overflow.

**Non-Goals:**

- Implementing or linking Clang's Lexer, Preprocessor, SourceManager, token kinds, diagnostics, header search, modules, PCH, or macro system.
- Changing AngelScript keyword, identifier, numeric, string, heredoc, escape, comment, whitespace, or operator semantics in the same migration. Any intentional language change requires a separate capability and compatibility review.
- Implementing canonical Decl/Type/Stmt/Expr nodes, Sema, Bytecode CodeGen, TypedASTJIT migration, LLVM IR lowering, ORC, object caching, or native executable memory.
- Moving UE descriptors, `#include`/conditional policy, source-provider selection, generated declaration construction, virtual paths, or ClassGenerator semantics into the raw Lexer.
- Persisting a mandatory token stream in Cache V2 or publishing a stable concrete C++ token-buffer ABI.
- Making token objects independently heap-owned, reference counted, polymorphic, or mutable after publication to Parser consumers.
- Creating a permanent production old/new lexer selection. Shadow selection exists only for development and tests until cutover.
- Solving incremental parsing or language-server reuse end to end. The token model must permit later reuse, but this change only establishes whole-buffer generation correctness.

## Decisions

### 1. This change is the lexical prerequisite of the canonical compiler change

The ownership boundary is:

```text
refactor-as-source-aware-lexical-pipeline
  SourceManager lexical substrate
  Token / RawLexer / classification
  TokenBuffer / TokenCursor
  legacy Parser input migration
  UE preprocessor lexical-facts adapter
  public ParseToken compatibility
                 |
                 v
refactor-as-canonical-typed-ast-compiler
  Parser Sema actions
  ASTContext / Decl / Type / Stmt / Expr
  Bytecode + TypedASTJIT consumers
  public AST snapshots / Cache V2 AST DTO
  legacy semantic tree and sidecar-HIR retirement
```

This change may migrate the existing `asCParser` to `asCTokenCursor` while the Parser still builds `asCScriptNode`. That produces a separately testable lexical cutover and does not pre-empt the later semantic-AST migration.

The existing canonical change's Tasks 2.1-2.2 currently name `asCSourceManager`. Before source implementation begins, the two task lists must be reconciled so only one implementation owns `as_source_manager.h/.cpp`. This lexical change owns the source-buffer, compact-location, line-table, and authored/processed/generated mapping substrate needed before lexing. The canonical change extends that same implementation with AST snapshot, public view, and Cache DTO responsibilities. Existing canonical tasks remain unchecked until their own requirements and tests pass.

Alternative rejected: add Lexer work directly to the 93-task canonical change. A separate lexical change can be completed and validated against the current Parser/preprocessor without coupling every scanner correction to AST/Sema/Bytecode migration.

Alternative rejected: define a second SourceManager for the preprocessor. Duplicate source IDs and mapping tables would make diagnostics, Cache V2, Hot Reload, and public AST ranges disagree.

### 2. Use a two-stage host/core flow around immutable source buffers

The host-neutral core path is:

```text
immutable source buffer generation
          |
          v
asCSourceManager
          |
          v
asCRawLexer -> asCTokenClassifier/asCLiteralParser
          |
          v
asCTokenBuffer -> asCTokenCursor -> asCParser
```

The UE host path has an authored-source preparation stage:

```text
authored buffer + logical source key
          |
          v
asCSourceManager + asCRawLexer lexical facts
          |
          v
FAngelscriptPreprocessor
  host directives, descriptors, policy, rewrites, generated text
          |
          v
processed/generated buffer + authored mapping
          |
          v
core RawLexer -> TokenBuffer/Cursor -> Parser
```

Scanning authored text once for host preparation and scanning the resulting processed text once for Parser input is valid because they are different immutable buffers with different spellings and source mappings. Re-scanning the same buffer because Parser rewound a byte position is not valid after cutover.

Standalone uses the same core Lexer/TokenBuffer/Parser. Its own source-preparation frontend may provide a host adapter, but it cannot fork raw token semantics.

Alternative rejected: make the UE preprocessor emit the final Parser token stream. The UE host can rewrite, remove, inject, and concatenate text, while Standalone has a different host boundary. Re-lexing the final immutable processed buffer keeps Parser input deterministic and host-neutral.

### 3. SourceManager owns buffer generations, locations, line tables, and mappings

`asCSourceManager` is the only owner of source-buffer identity used by tokens. It distinguishes:

- a stable logical source key used by module identity, diagnostics, cache records, and cross-generation comparison;
- a snapshot/build-local `asCSourceBufferId` used for compact lookup;
- an immutable byte buffer and explicit byte length;
- line-start offsets for row/column conversion;
- authored, processed, and generated origin mappings;
- a generation/content identity so token/checkpoint data cannot cross buffers accidentally.

The lexical substrate uses compact value types conceptually equivalent to:

```cpp
struct asCSourceLocation
{
    asDWORD bufferAndKind;
    asDWORD byteOffset;
};

struct asCSourceRange
{
    asCSourceLocation begin;
    asDWORD byteLength;
};
```

The exact bit packing is an internal implementation detail selected after overflow and memory benchmarks. A location must represent invalid state explicitly; offsets and lengths must be checked before addition; a range may not cross buffer generations. AST/public/cache layers translate through stable source keys and mappings rather than persist live buffer IDs.

`asCScriptCode::ConvertPosToRowCol` remains a compatibility adapter during migration and delegates to SourceManager line tables once its source has been registered. It is removed or narrowed only after every caller uses the new source API.

### 4. Tokens are compact lexical facts, not syntax or semantic nodes

The target internal shape is conceptually:

```cpp
struct asCToken
{
    eTokenType kind;
    asCSourceLocation location;
    asDWORD byteLength;
    asDWORD flags;
    asCIdentifierId identifier;
    asCLiteralId literal;
};
```

The exact field sizes/order are benchmark-driven and not a public ABI. Required facts are:

- final token kind expected by the current Parser, including explicit end-of-file and lexical-error kinds;
- one contiguous spelling range in one immutable buffer;
- flags such as start-of-line, leading-space, trivia/generated/authored origin, and recovery state where needed;
- an optional interned identifier reference for identifier/keyword spelling;
- an optional literal record reference only when validation/decoding produced data worth retaining.

A token does not contain Parser nodes, AST pointers, Runtime type/function pointers, Unreal types, Clang/LLVM objects, owning strings, mutable source cursors, or Cache V2 identities. Derived origin ranges live in SourceManager mapping tables. Parser syntax ranges are composed from token locations without retaining a full token buffer after the owning build releases it.

EOF has a valid buffer identity and an offset equal to buffer length. Every non-EOF lexer result consumes at least one input byte/code unit, including malformed input, so callers cannot loop forever.

### 5. Raw spelling, classification, and literal interpretation are separate layers

`asCRawLexer` advances monotonically over one immutable source buffer. It recognizes physical spellings and boundaries for:

- whitespace/newline and comments;
- raw identifiers;
- numeric, string, character, and heredoc-like literal spellings supported by the maintained language;
- operators and punctuation using longest-match rules;
- malformed/unterminated input;
- end of file.

The raw lexer does not know Parser grammar, declarations, UE macros/descriptors, overloads, types, or AST nodes.

`asCTokenClassifier` maps raw identifier spelling through an engine/compiler-option snapshot to keyword or identifier tokens. Keyword lookup is isolated from raw boundary recognition so host code can request a raw identifier view without accidentally applying Parser keyword policy.

`asCIdentifierTable` interns identifier spellings within the owning compiler/module build and provides stable equality during that build. Its numeric IDs are never persisted as cross-process identity. Stable source/cache identity uses spelling or canonical stable keys owned by the later semantic layer.

`asCLiteralParser` validates and decodes lexical literal information such as base, suffix, escape validity, decoded bytes/code points, and stable lexical error category. It does not select overloads, infer final semantic type, perform implicit conversion, or create Runtime values. Literal semantic typing remains Parser/Sema/compiler behavior until the canonical change moves it to Sema.

Trivia is a policy, not a second scanner. Raw tokens can expose whitespace/comments to the UE adapter and deterministic dump tests. The Parser channel normally filters trivia while preserving start-of-line/leading-space and source gaps needed for diagnostics. Tooling retention beyond the active build is a later product decision.

### 6. TokenBuffer scans on demand once; TokenCursor owns Parser position

`asCTokenBuffer` owns one lexer/configuration chain and an append-only token array for one immutable source-buffer generation. `EnsureToken(index)` advances the lexer only until that token exists. It never invalidates existing indices and never asks the lexer to start again from a prior byte offset.

`asCTokenCursor` is a lightweight consumer with APIs conceptually equivalent to:

```cpp
const asCToken &Current();
const asCToken &LookAhead(asUINT distance);
asCTokenIndex Consume();
asCTokenCheckpoint Checkpoint() const;
void Restore(asCTokenCheckpoint checkpoint);
void Commit(asCTokenCheckpoint checkpoint);
```

Checkpoints contain owner/generation identity, token index, and nesting discipline in debug/test builds. Restoring a checkpoint from another buffer, generation, or token source fails deterministically. Parser lookahead has an explicit configured maximum; attempts beyond the limit produce a controlled compiler diagnostic rather than unbounded allocation.

Nested speculative parsing uses checkpoints. Error recovery advances through tokens by index. A committed checkpoint may release bookkeeping but does not erase tokens still addressable by an older live checkpoint. The first implementation keeps the buffer append-only for the build; prefix reclamation is deferred until profiling proves it necessary.

Alternative rejected: retain byte-position rewind plus a faster Lexer. It would preserve multiple lexical passes, make source-preparation tokens difficult to buffer, and leave Parser recovery coupled to byte encodings.

Alternative rejected: make Parser own a vector of fully eager tokens. On-demand append-only buffering gives deterministic indices while avoiding mandatory tokenization of unused trailing input after an early fatal error.

### 7. The UE preprocessor consumes shared lexical facts through a narrow adapter

The maintained-fork Lexer remains standard C++. `FAngelscriptPreprocessorLexicalAdapter` converts SourceManager/token views into UE-friendly non-owning views and traversal helpers. It may expose:

- token kind/channel and exact source range;
- raw spelling view;
- comment/string/literal boundaries;
- raw identifier spelling and delimiter/operator facts;
- matching-delimiter assistance built over tokens with explicit depth/limit checks;
- authored-to-generated mapping hooks when the host emits replacement text.

The adapter does not move host behavior into the core lexer. `FAngelscriptPreprocessor` continues to own:

- `#include`, conditionals, import/module policy, source-provider access, and virtual paths;
- UCLASS/USTRUCT/UENUM/property/function/mixin/default/namespace descriptor parsing;
- source edits, wrapper/generated declarations, diagnostics wording, and compile summaries/events;
- ClassGenerator-facing metadata and UE reflection conventions;
- host cancellation, async orchestration, and generated-source publication.

Migration occurs feature cluster by feature cluster. Each migrated cluster compares descriptor records, processed text bytes, source mappings, diagnostics, and compilation events against the existing scanner. The old cluster helper is removed only when parity passes; the project must not keep two production comment/string/identifier boundary implementations indefinitely.

The raw Lexer accepts no file/network/provider capability and performs no includes or macro expansion, so using it on authored input does not expand the trust boundary.

### 8. Parser consumes a cursor but keeps grammar and recovery authority

`asCParser::GetToken`, `RewindTo`, and their callers migrate behind a compatibility adapter first. The adapter preserves current token kinds and parser-control behavior while translating saved byte positions into token checkpoints. Tests then migrate to explicit cursor APIs. Final production Parser code does not invoke `asCTokenizer` directly or reconstruct tokens from byte offsets.

Parser remains responsible for grammar, contextual interpretation, speculative alternatives, and syntax recovery. Keyword classification that is genuinely language-global occurs before Parser; contextual keywords and grammar-dependent meanings remain Parser decisions.

This change does not alter the tree that Parser builds. When `refactor-as-canonical-typed-ast-compiler` later replaces `asCScriptNode` semantic consumption with Parser-to-Sema actions, it consumes the same cursor and source ranges.

### 9. `ParseToken` remains a compatibility facade

`asIScriptEngine::ParseToken` is an established public embedding API and remains available with its current signature, return token kinds, length semantics, input boundary behavior, and engine-property behavior covered by tests.

The implementation creates an isolated lexical view over the caller-provided bytes, runs the new raw/classification path for one token, and translates the result to the public contract. No internal SourceManager, token-buffer, identifier-table, or literal-record lifetime escapes the call.

A future public token-stream API, if needed by tooling, must be separately versioned and snapshot-based. It cannot expose this change's concrete internal token layout.

### 10. Diagnostics and dumps derive from the same locations

Lexer errors use stable categories plus a source range. Existing maintained message text and row/column results remain differential gates where tests assert them. New internal categories may include invalid byte/encoding unit, malformed numeric spelling, invalid escape, unterminated literal/comment, offset overflow, token limit, lookahead limit, and foreign checkpoint.

Normalized token dumps are address-free and deterministic. Each row includes logical source key, buffer kind/generation-independent content identity, byte range, normalized kind, flags, escaped spelling or spelling hash, optional identifier spelling, optional literal summary, and lexical error category. Dumps never become compiler input and never include raw pointers or process-local IDs as durable identity.

SourceManager performs authored/processed/generated remapping for diagnostics. A generated token can report its generated location and, when a valid origin exists, the authored range. Missing/ambiguous mappings fail explicitly rather than fabricate coordinates.

### 11. Live token state is not a Cache V2 or public AST authority

TokenBuffer, TokenCursor, lexer offsets, checkpoints, identifier IDs, and literal-table IDs are build-local. They are destroyed after Parser/Sema/CodeGen no longer needs them unless a future explicit tooling snapshot owns a separate versioned representation.

Cache V2 and canonical AST records may contain:

- stable logical source keys and content hashes;
- authored/processed/generated source mappings;
- compact source ranges translated into pointer-free DTOs;
- compiler/lexical contract revision as part of the compatibility fingerprint where needed.

They do not contain a required serialized live token stream. A lexical contract revision mismatch is a normal safe miss followed by recompilation from authoritative source when allowed. `SaveByteCode` remains a VM artifact API and gains no token payload.

### 12. Shadow convergence is isolated and evidence-driven

Development/test builds support old, new, and comparison lexical modes through separate Engine/build invocations over identical immutable inputs. Comparison covers:

- token kind, length, spelling boundary, trivia classification, and lexical diagnostics;
- Parser acceptance/rejection, recovery, maintained diagnostics, and source ranges;
- UE processed text, descriptor graphs, mappings, summaries/events, and generated output;
- Script-corpus compile results and VM behavior;
- deterministic repeated output and malformed-input termination;
- scanner invocation counts, wall time, allocations, and peak memory.

Only one selected path publishes processed source or executable module state. Comparison never merges token streams or descriptor graphs. A mismatch is evidence that blocks that migration cluster; it does not silently choose individual tokens from both paths.

Shipping remains on the existing production path until the relevant gates pass. After final cutover, no Shipping/runtime setting selects the removed legacy scanner. Rollback is performed by reverting the cutover change or selecting the prior released plugin, not by preserving permanent dual production code.

### 13. Performance, bounds, and thread-safety are explicit contracts

Source buffers are immutable after registration. A TokenBuffer and its cursor are confined to one compilation worker unless an explicit synchronization owner is added later. Identifier/literal tables are compilation-local. No process-global mutable lexer cursor or token table is introduced.

Every loop must make progress or return a bounded error. Offset arithmetic uses checked operations. Configurable hard limits cover source bytes, token count, trivia span, literal length/decoding output, lookahead, checkpoint nesting, and delimiter depth. Existing Parser cartesian/depth guards remain in force.

The acceptance benchmark records the current frontend and preprocessor median/p95 time, tokenization count, allocations, and peak memory over representative native SDK, Script corpus, large generated binding surface, and malformed inputs. The initial target is no more than 10% median compile-time regression and no more than 15% peak-memory regression for the lexical/preprocessor slice unless a measured diagnostic/provenance benefit is explicitly accepted in the change record. Exact absolute budgets are filled from the baseline rather than invented before measurement.

### 14. Clang ideas are translated, not copied

The following concepts are adopted:

- compact source locations resolved through a SourceManager;
- compact tokens separate from AST nodes;
- monotonic Lexer progress and explicit EOF/error handling;
- raw identifier/literal spelling before higher-level classification;
- a token-producing layer between Lexer and Parser;
- Parser lookahead independent from source-buffer ownership;
- diagnostics and source mappings derived from common locations.

The following are explicitly not adopted:

- Clang token numeric values or concrete layouts;
- C/C++/Objective-C keyword sets, preprocessing tokens, macro expansion, header search, modules, PCH, pragma handlers, or language-option graph;
- Clang allocator/diagnostics/source classes as linked dependencies;
- any claim that copying Clang implementation automatically preserves AngelScript or UE semantics.

The pinned architecture evidence and current-code mapping are recorded in `attachments/current-state-and-clang-reference.md`.

## Risks / Trade-offs

- **[Risk] SourceManager work overlaps the canonical compiler plan.** -> Reconcile task ownership before source changes; implement one shared `as_source_manager.*`; keep canonical AST/public/cache extensions in the canonical change and do not duplicate types.
- **[Risk] Token parity hides downstream behavioral differences.** -> Gate Parser diagnostics, preprocessor descriptors/output, Script corpus, VM behavior, and generated provenance in addition to token dumps.
- **[Risk] The UE preprocessor relies on byte-level quirks not represented by final Parser tokens.** -> Expose a raw/trivia lexical channel and exact spelling ranges; migrate host feature clusters independently; retain host grammar and transformations.
- **[Risk] Buffering increases memory.** -> Materialize on demand, keep compact POD tokens, release buffers at build end, measure peak memory, and defer tooling retention/prefix reclamation until justified.
- **[Risk] Source preparation scans authored text and Parser scans processed text, appearing to duplicate work.** -> Treat them as different immutable generations with distinct responsibilities; prohibit repeated scanning of the same generation for Parser rewind.
- **[Risk] Literal refactoring changes accepted edge cases.** -> Freeze exhaustive tokenizer/literal/public-API matrices first and keep semantic typing outside the Lexer.
- **[Risk] Identifier interning changes memory or thread behavior.** -> Use compilation-local ownership, deterministic spelling equality, explicit limits, and no process-global mutation.
- **[Risk] Error recovery depends on byte rewind quirks.** -> Record Parser recovery traces and diagnostics, introduce cursor compatibility adapters first, and cut over grammar clusters only after differential parity.
- **[Risk] Generated-source mappings become ambiguous.** -> Represent missing/one-to-one/one-to-many mappings explicitly and reject invalid ranges; never guess an authored location.
- **[Risk] A development dual lexer leaks into Shipping.** -> Add final configuration/source scans and Shipping build tests proving only the canonical lexical path exists after cutover.
- **[Risk] Internal token layout is mistaken for a public/cache ABI.** -> Keep it in private maintained-fork headers, retain `ParseToken` as the only current public facade, and use stable source DTOs rather than serialized tokens.
- **[Trade-off] A separate lexical change adds coordination overhead.** -> It also allows the current Parser/preprocessor to converge independently and gives the canonical AST change a verified input boundary.

## Migration Plan

1. **Record and reconcile.** Validate this OpenSpec, link it from the ongoing discussion record, and before implementation update the canonical compiler task wording so one SourceManager implementation has unambiguous ownership.
2. **Freeze behavior.** Expand tokenizer, `ParseToken`, Parser recovery/diagnostic, source-position, UE preprocessor, generated-provenance, Script-corpus, malformed-input, and performance baselines without changing production selection.
3. **Land SourceManager lexical substrate.** Add immutable buffers, compact locations/ranges, line tables, generation/content identity, and authored/processed/generated mappings; keep existing position APIs as adapters.
4. **Land new Lexer in shadow mode.** Implement raw scanning, classification, identifiers, literals, deterministic dumps, limits, and differential comparison while the existing tokenizer remains authoritative.
5. **Migrate Parser input.** Introduce TokenBuffer/Cursor, translate Parser rewind/recovery incrementally, prove single-scan behavior and diagnostic parity, then make the new cursor authoritative for the current Parser.
6. **Migrate UE source preparation.** Add the adapter and move comments/strings/identifiers/delimiters, then directive/descriptor feature clusters, while comparing exact processed text, mappings, metadata, and events.
7. **Cut over public/host consumers.** Route `ParseToken`, Standalone, UE Runtime, Hot Reload source builds, commandlets, and generation builds through the shared lexical truth.
8. **Retire duplicates.** Remove direct Parser `asCTokenizer` use, byte-position rewind/retokenization, and migrated UE low-level scanner helpers only after all gates pass. Keep no permanent production dual lexer.
9. **Hand off to canonical compiler.** Run the canonical change's early frontend tests against TokenCursor/SourceManager and continue Parser-to-Sema/AST migration there. Do not conflate lexical completion with semantic compiler completion.

Before Step 8, rollback is selection of the still-authoritative old path in development/test builds. After Step 8, rollback is a normal source/plugin revision rollback; cache fingerprint changes cause safe misses and source rebuild rather than attempting to decode token state.

## Open Questions

- Which current preprocessor feature cluster should be the first adapter cutover after comment/string boundaries: directives, descriptor headers, or delimiter matching? Choose using baseline defect density and test coverage before implementation Milestone 6.
- Does the existing Cache V2 compiler/profile fingerprint already change for every lexical-contract change, or does it require an explicit lexical revision field? Answer by inspecting the live key/schema implementation before the persistence task.
- Which trivia subset, if any, should a future public tooling snapshot retain after compilation? This change keeps live trivia available during build but deliberately does not create that public API.
- Should identifier normalization or non-ASCII identifier support change in a later language proposal? This migration preserves current byte/spelling behavior and treats that as a separate compatibility decision.
- Can token-buffer prefix reclamation materially reduce peak memory without complicating nested recovery checkpoints? Defer until measurements show the append-only build-local buffer exceeds the acceptance budget.
