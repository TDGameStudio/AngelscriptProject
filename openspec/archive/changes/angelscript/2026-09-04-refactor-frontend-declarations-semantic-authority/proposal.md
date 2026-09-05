## Why

The retained production path still lets `asCParser` receive `asCBuilder` or `asCScriptEngine`, lets `asCBuilder` own declaration discovery and lookup, and constructs `asCObjectType` while declarations are still being analyzed. Even a concrete typed AST would remain secondary if those mutable runtime objects continued to decide declaration meaning.

The reconstructed frontend needs one Clang-style declaration authority: Parser drives Sema actions that create concrete typed declaration nodes, all source files reach a declaration barrier, and only then does Sema resolve cross-file names and types. This is the prerequisite for source-order independence, deterministic parallel work, and a later transactional publication stage.

## What Changes

- Add an Engine-independent `frontend::asCCompilationSession` that accepts the frozen source, token, preprocessing, type-identity, and typed-AST products established by the preceding frontend Changes.
- Split declaration processing into collection and resolution phases across the complete compilation input.
- Make `frontend::asCParser` call `frontend::asCSema` at grammar milestones so Sema-created concrete `Decl` subclasses, declaration contexts, canonical symbols, and resolved types are the only declaration authority.
- Retain function bodies as deferred typed source/token ranges during declaration processing; body semantics belongs to the following Change.
- Recover into typed invalid or recovery declarations, continue with later declarations, and merge diagnostics and declaration fragments deterministically for one or many workers.
- Add focused CQTest coverage under `Angelscript.UnitTest.NativeEngine.Declarations`.
- Keep the existing production Parser, Builder, Engine, module, runtime-object, and bytecode paths dormant and unchanged until a later unified cutover.

## Capabilities

### New Capabilities

- `angelscript/language/frontend/declarations`: Multi-file declaration collection, Parser/Sema ownership, declaration resolution, recovery, and deterministic fragment assembly.

### Modified Capabilities

None.

## Impact

Future implementation changes isolated ThirdParty frontend files and replacement NativeEngine tests in the `Plugins/Angelscript` submodule, then synchronizes one parent-repository capability spec. No public `angelscript.h` ABI, Unreal reflection surface, live production route, source-level `import` mechanism, `asCObjectType`, Builder publication, VM, or bytecode contract changes in this Change.
