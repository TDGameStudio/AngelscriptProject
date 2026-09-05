## Context

The retained implementation combines syntax, semantics, module construction, and runtime publication. `asCParser` can be constructed from `asCBuilder` or `asCScriptEngine`; the method named `BuildParallelParseScripts` currently iterates source sections sequentially; and Builder creates `asCObjectType` instances and inserts them into module and Engine collections during type generation. The existing root-level `asCDecl`, `asCStmt`, and `asCExpr` are wide enum-tagged records, not the concrete Clang-style hierarchy approved for reconstruction.

This Change directly consumes these active Changes, which are prerequisites expressed here rather than illegal cross-Change task IDs:

1. `angelscript/refactor-frontend-lexer-token-pipeline`
2. `angelscript/refactor-frontend-preprocessor-directive-record`
3. `angelscript/refactor-frontend-stable-type-identity`
4. `angelscript/refactor-frontend-clang-typed-ast`

The NativeEngine test foundation and source/diagnostics Changes are transitive prerequisites already required by those four direct inputs.

Together they supply frozen source, diagnostics, token, directive, stable-identity, concrete typed-AST, and focused-test contracts. This Change does not revise those contracts opportunistically. All new files remain under `ThirdParty/angelscript/source/frontend/`, inside `BEGIN_AS_NAMESPACE` and lowercase `namespace frontend`, with final leaf names and no `V2` suffix.

## Goals / Non-Goals

**Goals:**

- Make concrete typed declarations and `frontend::asCSema` the sole declaration-semantic authority.
- Establish a collection barrier followed by whole-session declaration resolution.
- Remove live Builder and Engine access from new Parser/Sema declaration work.
- Support deterministic fragment collection and merge across source files.
- Preserve useful typed recovery nodes and continue after local declaration failures.

**Non-Goals:**

- Analyze function bodies, build control-flow or lifetime facts, generate bytecode, or touch the VM.
- Create `asCObjectType`, script functions, modules, UObjects, or Engine registry entries.
- Interpret UE reflection annotations or emit module dependency output; that belongs to `angelscript/refactor-preprocessor-reflection-dependency-output`.
- Add a new source-level `import`, simulate forward declarations with runtime stubs, or require source-file topological sorting.
- Switch production to the new frontend or maintain two selectable production pipelines.

## Decisions

### A compilation session owns phase transitions and immutable inputs

`frontend::asCCompilationSession` receives immutable frontend options, source snapshot, token/directive products, stable-identity services, diagnostics, and an AST context. It exposes explicit collection and declaration-resolution transitions and returns one frozen declaration result. It has no `asCScriptEngine*`, `asCBuilder*`, `asCModule*`, or callback that can mutate those objects.

The parser's semantic construction boundary is explicit: `frontend::asCParser(frontend::asCPreprocessor&, frontend::asCSema&)` consumes the preprocessor-owned active-token result and reports typed grammar actions to the supplied Sema. Neither constructor argument is obtained from a live Engine or Builder, and Parser does not create an alternate semantic record before calling Sema.

The result owns or leases all memory needed to query concrete declarations, source ranges, canonical symbols, typed declaration-reference edges, deferred body ranges, and diagnostics. Process-local arena addresses are never exposed as stable identity.

### Parser drives Sema actions; Sema creates semantic declarations

This follows Clang's important division without copying its C++ grammar. Parser owns grammar control, bounded lookahead, balanced-delimiter tracking, and synchronization. At a declaration milestone it calls a typed Sema action such as entering a declaration context, starting a record, completing a function signature, or attaching an attribute. Sema validates the action, performs lookup appropriate to the current phase, and creates the corresponding concrete `Decl` subclass through `frontend::asCASTContext`.

Parser does not construct a generic declaration record and later ask Sema to reinterpret it. Sema does not reach back into parser cursor state. U-prefixed annotation spellings retained by the preprocessing/AST Changes arrive as typed attributes on declarations; this Change preserves them but does not project them to UE reflection objects.

### Collection and resolution are separate semantic phases

Collection parses every declaration header and records unresolved type locations, context paths, attributes, and deferred function-body ranges. It performs only semantics required to form structurally valid declarations and nested contexts. Each source contributes a fragment that contains concrete typed nodes, not a vague intermediate IR.

After all fragments reach the barrier, the session merges declaration contexts and stable symbols in canonical order. Resolution then completes base types, member/property types, parameter and return types, funcdefs, overload sets, redeclarations, and declaration-reference edges. All sources in the request are visible automatically; there is no new `import` construct and no Engine type stub.

### Fragment isolation is the parallelism boundary

Workers own their parser, Sema collection state, local typed-node storage, and diagnostic fragment. They consume only frozen inputs. The merge adopts or copies those typed nodes into the session AST context according to logical source key, byte range, stable semantic key, and fragment-local ordinal. The barrier then creates a read-only canonical declaration environment for resolution.

Resolution may later parallelize operations proven independent, but this Change does not require speculative shared mutation. One-worker and multi-worker executions must serialize to the same semantic projection and diagnostic sequence.

### Recovery is typed and non-publishable

Parser uses grammar-specific synchronization sets and always makes source progress. Sema can create concrete invalid declarations or dedicated recovery declarations that retain authored ranges and diagnostic relations. These nodes remain visitable so later declarations and tooling retain structure, but they never enter the valid canonical lookup set, satisfy a type reference, or become runtime candidates.

An error-bearing declaration result is finalizable for inspection and testing. “Finalized” is not synonymous with “publishable”; the later publication design must require an error-free, verified frontend candidate.

### Runtime projection is an explicit later boundary

No compatibility adapter is installed in the production Builder during this Change. Once declarations, bodies, and reflection/dependency output are complete, a later batch may define a Builder-independent candidate graph and transactional publication into the Engine. The sequencing and entry criteria are recorded in `attachments/talks/talk-20260905-010701-frontend-reconstruction-sequencing.md` rather than hidden as current tasks.

## Risks / Trade-offs

- Fragment-owned typed nodes make adoption and identity remapping more complex than mutating one global arena. Stable semantic keys and explicit remap tables keep that complexity at the barrier instead of leaking thread synchronization into every node.
- Some language rules appear local but depend on a complete overload or base-type set. Collection therefore stays deliberately conservative and resolution owns authoritative answers.
- Deferring bodies retains tokens and source bytes longer. The compilation result already owns the source lifetime, and the following body Change consumes the deferred ranges before any production candidate is formed.
- Keeping production untouched means the new path initially has no runtime parity proof. Focused structural CQTests are the correct evidence until a separately approved unified cutover.
