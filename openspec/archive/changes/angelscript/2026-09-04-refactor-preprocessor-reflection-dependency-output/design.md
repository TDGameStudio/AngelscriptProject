## Context

This Change is implementation-ready only after these directly consumed frontend Changes complete:

- `angelscript/refactor-frontend-preprocessor-directive-record`
- `angelscript/refactor-frontend-stable-type-identity`
- `angelscript/refactor-frontend-declarations-semantic-authority`

Those are cross-Change prerequisites, not edges in this Change's `task_graph`. The declaration-Sema prerequisite already transitively depends on the NativeEngine test foundation, source ownership, lexer, and typed-AST work. Body Sema is deliberately not a prerequisite: this Change defines a separate body invalidation sink that can be empty, while `angelscript/refactor-frontend-bodies-semantic-authority` may later supply body facts without changing the declaration graph contract.

The current `FAngelscriptPreprocessor` in `AngelscriptRuntime/Preprocessor` uses regex and chunk analysis to create descriptors, processes explicit imports, and returns modules in collected file order. Existing descriptor definitions in `Core/AngelscriptEngine.h` combine parsed facts with live Runtime and UE pointers. All of that code stays available as dormant reference; the reconstruction is implemented under `ThirdParty/angelscript/source/frontend/` and is not connected to the current production route by this Change.

All fork-internal leaves introduced there are declared between `BEGIN_AS_NAMESPACE` and `END_AS_NAMESPACE` in the lowercase `frontend` namespace. `Frontend` is not an alternate namespace, and reconstructed leaf classes use their final names without `V2` suffixes or compatibility twins.

## Goals / Non-Goals

**Goals:**

- Return concrete, resolved `FAngelscript*Desc` output directly from the new `asCPreprocessor` facade.
- Make typed Parser/Sema declarations and attributes the only producer of reflection meaning.
- Represent automatic declaration dependencies with source-aware typed edges, completeness rules, SCCs, and a deterministic condensation DAG.
- Preserve a separate body-reference invalidation graph.
- Keep all output detached from live Engine and UE reflection state.

**Non-Goals:**

- No production route switch, compatibility fallback to the old preprocessor, or dual production frontend.
- No UObject/reflection materialization, Builder registration, Engine publication, bytecode, VM, or Standalone work.
- No generic reflection IR, generic DTO, regular-expression metadata scanner, or source-repair pass.
- No dependency on, generation of, or recommendation to use `import`; formal removal of the dormant syntax is separately owned.
- No implementation of body parsing or body semantics.

## Decisions

### 1. `FAngelscriptPreprocessResult` is the direct facade result

The fork-internal frontend `asCPreprocessor` returns a concrete `FAngelscriptPreprocessResult`. It owns or leases:

- the immutable source and sealed typed-AST snapshot needed by every source anchor;
- the successful directive-phase result and preprocessing record used for active-token routing and AST backquery;
- the resolved `TSharedRef<FAngelscriptModuleDesc>` collection;
- `FAngelscriptModuleDependencyGraph`;
- `FAngelscriptBodyInvalidationGraph`;
- structured diagnostics and success/configuration identity.

This result is not named or modeled as an IR. The typed AST is already the semantic representation; adding a generic metadata layer would create another schema and another opportunity for drift. The direct result also makes the user-visible answer to preprocessing unambiguous: callers receive the concrete descriptors they need for later UE type creation.

Only declarations from the active preprocessor branch enter the result. The SourceManager and preprocessing record retain inactive ranges independently.

### 2. One concrete consumer observes typed Sema events

`frontend::FAngelscriptDescriptorConsumer` is a concrete frontend component. Sema calls it with typed declaration and attribute objects after the relevant semantic facts are accepted. It does not receive string-keyed event records and does not reparse source.

The consumer handles the concrete declaration families directly:

```text
Parser syntax
    -> Sema validates Decl + Attr + canonical type uses
       -> typed AST node is authoritative
       -> FAngelscriptDescriptorConsumer populates the matching FDesc
```

Descriptor construction is transactional. Candidates may be `Parsed` while callbacks are in progress. A successful final resolution pass validates ownership, stable keys, type uses, attributes, and dependencies, then promotes the complete result to `Resolved`. A failed session returns diagnostics and no publishable descriptor collection; it never exposes a mixture of resolved and guessed objects.

### 3. Descriptor definitions move, but descriptor identity does not fork

The existing descriptor family is extracted from `Core/AngelscriptEngine.h` into `Core/AngelscriptDescriptors.h`. `AngelscriptEngine.h` includes that header so existing Runtime consumers retain their source include path. There is no copied ThirdParty version and no conversion DTO.

The shared definitions gain only the frontend facts required before materialization: lifecycle state, stable declaration/type-use identities, and stable source anchors. Existing live pointer fields remain for the later materializer, but every such pointer is null in a `Resolved` frontend result. In particular, a native superclass is represented by its resolved stable host type identity before publication; `CodeSuperClass` is not filled by consulting a live `UClass` registry.

This is an internal plugin contract. It may use `FString`, `FName`, `TArray`, `TMap`, `TSet`, `TOptional`, `TSharedPtr`, and the established `FAngelscript*Desc` types. It may not read live `GEngine`, mutable `asCScriptEngine` registries/configuration, editor globals, the filesystem, or asynchronous I/O.

### 4. Declaration dependencies retain use-site meaning

`FAngelscriptDependencyEdge` contains stable source and target module keys, `EAngelscriptDependencyReason`, an authored SourceRange/anchor, and `EAngelscriptCompletenessRequirement`. Reasons cover bases, interfaces, stored properties, function returns, function parameters, generic arguments, and delegate signatures. Nested type uses are traversed recursively, and completeness is inherited from the semantic rule of the enclosing use.

The edge direction is `consumer -> provider`. Exact duplicate edge tuples may be removed, but two distinct source ranges are retained. References within the same module do not create cross-module edges. A resolved host/builtin type that is not owned by this source set remains a host semantic fact rather than a synthetic source-module vertex.

SCC computation uses the module adjacency derived from these typed edges. It preserves the original edges for diagnostics, sorts members by stable module key, and emits a deterministic condensation DAG. Sema—not the graph algorithm—decides whether a completeness-requiring cycle is invalid.

### 5. Body invalidation has a different graph type

`FAngelscriptBodyInvalidationGraph` receives calls, globals, and other body-only references. It has no completeness field and cannot influence declaration SCCs or layout order. Its input is optional so this Change can proceed in parallel with body Sema. Once body fragments exist, their producer calls the typed sink; it does not change `FAngelscriptModuleDependencyGraph`.

### 6. Ordering and result assembly are deterministic

Before sealing the result:

1. modules and descriptors are ordered by stable identity, using stable source position only as an authored tie-breaker;
2. dependency use sites are ordered by source key, target key, reason, source file key and byte range, then completeness;
3. SCC members are ordered by stable module key and condensation traversal resolves ties by the smallest member key;
4. body invalidation facts use the same stable-key and source-range discipline.

The result does not include registration order, pointers, absolute paths, `FName` indices, Runtime type IDs, or worker completion order in any durable identity or ordering decision.

## Compatibility and Migration

- No caller is routed to the new facade in this Change. Tests call it explicitly.
- The old `AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.*` remains untouched and receives no adapter or fallback.
- Existing consumers continue to include `Core/AngelscriptEngine.h`; that header re-exports the single extracted descriptor definition.
- A later unified cutover may pass a successful `Resolved` result to a materializer. It must reject any other state and is solely responsible for attaching Runtime/UE pointers and marking descriptors `Materialized`.
- Rollback removes the isolated frontend files and restores the descriptor declarations to their former header location; because production routing is unchanged, no stored runtime data migration is required.

## Risks / Trade-offs

- Extracting the descriptor header can expose include cycles. Keep it data-focused, forward-declare live pointer types, and retain out-of-line methods in the existing Core implementation.
- Existing fields such as `FAngelscriptTypeUsage` carry runtime-oriented state. Resolved stable type-use identity is authoritative before materialization; legacy runtime-bearing fields remain default rather than being populated from a live Engine.
- Per-use-site edges consume more memory than a module-name set. They are required for diagnostics and completeness evidence; SCC adjacency is separately compacted.
- A concrete UE descriptor result intentionally couples this ThirdParty fork to UE types. That is accepted for this plugin. A future non-UE host would require an explicit new product decision, not a generic DTO inserted preemptively.
