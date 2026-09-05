## Why

The current canonical frontend records group all declarations, statements, expressions, and types into a few wide tagged classes. Their `kind` values select which fields are meaningful, so irrelevant payload combinations remain representable, casts are weak, traversal and verification switches drift, and every node pays for fields it can never use. Calling those records “typed AST” does not provide the compile-time structure expected by Parser, Sema, diagnostics, reflection, or future code generators.

The reconstruction needs a genuine semantic object model: concrete `Decl`, `Stmt`, `Expr`, `Type`, and `Attr` subclasses with family-specific APIs, context ownership, checked casting, exhaustive traversal, and explicit source/lifetime contracts. Clang is the primary shape reference, but AngelScript keeps its own language taxonomy, immutable source snapshots, Unreal same-module implementation freedom, the preceding stable-identity contract, and separate later runtime boundaries.

## What Changes

- Add real C++ node hierarchies and orthogonal `DeclContext` ownership under `ThirdParty/angelscript/source/frontend/`, inside `BEGIN_AS_NAMESPACE` and lowercase `namespace frontend`.
- Define declaration, statement/expression, type, and attribute taxonomies once in `.def` files and derive kind enums, forward declarations, casts, visitor dispatch, dump names, and exhaustiveness checks from them.
- Give each concrete node only its valid semantic payload and expose checked `isa`, `cast`, and `dyn_cast`-style helpers.
- Make `frontend::asCASTContext` the arena, type-uniquing, and lifetime owner; nodes are mutable only during construction/semantic completion and immutable after successful seal.
- Separate canonical `Type`/`QualType` from authored `TypeLoc`/`TypeSourceInfo`, and use the preceding stable-identity contract rather than string keys.
- Add deterministic child traversal, typed attribute attachment, source ranges, structural verification, and a new versioned pointer-free projection/codec with no compatibility promise to the current sidecar wire shape.
- Treat the new hierarchy as the sole AST authority for the reconstructed frontend; root-level wide canonical records remain isolated reference material rather than a long-term synchronized shadow graph.
- Permit UE core types such as `FString`, `FName`, `TArray`, `TMap`, and `TSharedPtr` inside ThirdParty while keeping live `FAngelscriptEngine`/`UObject` state outside the AST model.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript/language/ast/core`: Replace the empty core contract with the typed node hierarchy, context lifetime, casting/traversal, source, attribute, verification, and sole-authority guarantees required by later frontend stages.

## Impact

New implementation files belong only under `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/`; replacement tests belong under `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/AST/`. It consumes `angelscript/refactor-frontend-source-diagnostics-model`, `angelscript/refactor-frontend-stable-type-identity`, and `angelscript/refactor-native-engine-test-foundation`. Those sibling outcomes are external coordinator prerequisites, not local Task DAG nodes.

The typed hierarchy becomes the input contract for `angelscript/refactor-frontend-declarations-semantic-authority`, `angelscript/refactor-frontend-bodies-semantic-authority`, and reflection/dependency output. This Change does not implement parsing or semantic resolution, bytecode/JIT generation, reflection descriptors, runtime registration, compatibility with the old Canonical AST sidecar/public-view wire contract, or a stable `angelscript.h` ABI.
