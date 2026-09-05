## Why

The retained compiler performs name lookup, expression typing, control-flow interpretation, lifetime work, and bytecode preparation through objects tied to `asCBuilder` and `asCScriptEngine`. Existing root-level statement and expression records are broad enum-tagged containers, so they cannot be the approved concrete Clang-style semantic model merely because more fields are populated.

After declaration collection and resolution are authoritative, function bodies need their own explicit semantic phase. Each deferred body should be parsed against a frozen whole-session declaration environment, produce concrete typed `Stmt` and `Expr` nodes plus control/lifetime facts, recover without discarding the rest of the source set, and remain completely independent of bytecode and runtime publication.

## What Changes

- Consume only an error-free or inspectable frozen declaration result from `angelscript/refactor-frontend-declarations-semantic-authority`.
- Parse deferred function bodies through `frontend::asCParser` and typed `frontend::asCSema` actions after the declaration barrier.
- Make concrete `Stmt` and `Expr` subclasses, explicit conversions, resolved declaration references, value categories, control targets, and lifetime/cleanup facts the sole body-semantic authority.
- Analyze independent bodies as isolated fragments and finalize them in stable function/source order so worker scheduling cannot change results.
- Recover with typed error expressions/statements and grammar-specific synchronization while continuing later statements and functions.
- Add focused CQTest coverage under `Angelscript.UnitTest.NativeEngine.Bodies`.
- Leave bytecode generation, runtime functions, Builder/Engine publication, production routing, and VM decoupling for later Changes.

## Capabilities

### New Capabilities

- `angelscript/language/frontend/bodies`: Deferred body parsing, expression and statement semantics, control/lifetime facts, recovery, and deterministic body fragments.

### Modified Capabilities

None.

## Impact

Future implementation changes isolated ThirdParty frontend files and replacement NativeEngine tests in the `Plugins/Angelscript` submodule, then synchronizes one parent-repository capability spec. It does not change public `angelscript.h`, source syntax, production Parser/Builder routing, runtime object layout, bytecode, JIT, VM, or Unreal reflection behavior.
