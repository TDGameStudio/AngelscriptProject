## Why

Initial compile already materializes class / struct / enum UserData. ClassGen tests omit `Methods`, so Analyze never binds `FunctionDesc.ScriptFunction` and ProcessEvent is unproven on the host path.

## What Changes

- A NativeEngine fixture hand-fills one BlueprintCallable `GetValue` on the host `ClassDesc.Methods`.
- After `CompileModules(Initial)` and existing ClassGen, that method is a live `UASFunction` whose ProcessEvent returns 7.
- ClassGen still reads host Methods. The production preprocessor remains the Methods authority.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript/runtime/class-generation`: Initial compile also materializes a callable `UFUNCTION` through ProcessEvent.

## Impact

Plugin: NativeEngine Compile `ClassGenCall` tests; host/Analyze join only if the RED shows ScriptFunction unbound or ProcessEvent fails.

Parent repository: this Change's OpenSpec records only.

## Non-goals

Language corpus execute. Real preprocessor in the fixture. Copying Builder CompileOutput Methods. Script construct. Method-body reload. ClassGen rewrite. Frontend UObject. `ALWAYS_CREATE` / `Build`. CacheV2 reuse.
