## Why

The preserved Unreal-side preprocessor currently discovers reflected declarations through a separate chunk, regular-expression, and string-rewrite path, constructs `FAngelscript*Desc` objects independently from compiler semantics, and exposes dependency names through the legacy import-oriented model. That duplicates declaration authority, loses typed source and completeness information, and cannot provide deterministic cycle-aware dependencies for the reconstruction that no longer relies on `import`.

The new frontend already has upstream Changes for source ownership, directive processing, stable type identity, a typed AST, and declaration Sema. Its UE reflection output and module dependency output must be projections of those exact semantic facts rather than another parser.

## What Changes

- Make the fork-internal `asCPreprocessor` facade return one concrete `FAngelscriptPreprocessResult` containing the source/AST lease, resolved `FAngelscript*Desc` objects, typed dependency graphs, and structured diagnostics for the active configuration.
- Populate the existing concrete descriptor family from the same typed `Decl`, `Attr`, and resolved type events accepted by Parser/Sema. Do not add a generic metadata IR, DTO layer, regular-expression extractor, or `import`-derived fallback.
- Give descriptors an explicit `Parsed -> Resolved -> Materialized` lifecycle. This Change completes `Resolved`; all `UClass`, `UStruct`, `UFunction`, `FProperty`, `asITypeInfo`, `asIScriptFunction`, and `asCModule` pointers remain null until a later publisher performs materialization.
- Derive typed cross-module declaration edges from bases, interfaces, properties, function signatures, generic arguments, and delegate signatures. Each edge retains its reason, source range, and completeness requirement, and the graph exposes deterministic strongly connected components and a condensation DAG.
- Keep body-reference invalidation facts in a separate graph so call/reference changes do not acquire declaration-layout semantics or alter SCC scheduling.
- Move the existing descriptor definitions to one UE-aware internal header that both the frontend and existing Runtime headers consume; do not duplicate the descriptor structs.
- Place every new fork-internal leaf under `ThirdParty/angelscript/source/frontend/` and, inside `BEGIN_AS_NAMESPACE`, the lowercase `frontend` namespace. Use final leaf names without `V2` aliases or parallel compatibility classes.

## Capabilities

### New Capabilities

- `angelscript/language/frontend/reflection-dependencies`: Defines the concrete preprocessing result, semantically authoritative reflection descriptors, descriptor lifecycle, typed declaration dependencies, SCC output, and the separate body invalidation graph.

### Modified Capabilities

None.

## Impact

- The implementation is owned primarily by the `Plugins/Angelscript` submodule, under `AngelscriptRuntime/ThirdParty/angelscript/source/frontend/`, with the minimum Core header extraction needed to keep one `FAngelscript*Desc` definition.
- New focused CQTest coverage is owned by `AngelscriptTest/NewVersion/NativeEngine/Reflection/` and `ModuleGraph/` under the replacement `WITH_ANGELSCRIPT_TESTS` gate.
- The API is fork-internal and is not added to the stable public `angelscript.h` ABI. UE container and value types are allowed inside this plugin-owned boundary.
- The parent repository owns this OpenSpec record and the eventual synchronized durable specification.
- The preserved `FAngelscriptPreprocessor`, production compiler routing, ClassGenerator materialization, Builder, Engine publication, VM, Standalone, and formal removal of the legacy `import` syntax are not changed here.
