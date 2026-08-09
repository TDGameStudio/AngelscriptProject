## Why

Manual bindings currently combine two useful properties with several avoidable global-state costs. Each `Bind_*.cpp` owns a file-static callback, and a newly created AngelScript engine executes those callbacks directly; however, callback ordering uses integer `EOrder`, every execution copies and sorts the callback array, binding helpers resolve an ambient current engine, and traits often mutate the most recently registered function or property. Generated bindings also arrive through multiple lifecycle mechanisms. In addition, hundreds of hand-written runtime callables are registered as inline lambdas, so native breakpoints, call stacks, crash symbols, and profiler frames identify anonymous `operator()` or caller templates instead of the owning bind and operation.

The replacement should keep direct execution and its low memory cost. The runtime only needs one process-wide array of callback metadata, sorted and sealed once after generated modules load. Each `FAngelscriptEngine` can then execute that immutable array against an explicit `FAngelscriptBinds` context without retaining a second representation of every declaration, method, property, or callable.

## What Changes

- Replace nested `FAngelscriptBinds::FBind` with file-static `FAngelscriptBind` declarations whose non-capturing callback receives `FAngelscriptBinds&` and registers directly into its explicit target engine.
- Keep exactly one process-wide callback-record array. `UAngelscriptSubsystem` loads generated bind modules on the Game Thread, asks the global collection to validate/sort/seal in place, and stores no binding array, pointer list, or expanded binding data.
- Replace integer `EOrder` and `Early` / `Normal` / `Late` offsets with seven required `EAngelscriptBindPhase` values: `TypeDeclarations`, `TypeInfrastructure`, `ExplicitBindings`, `GeneratedBindings`, `ReflectionBindings`, `PostReflectionBindings`, and `Finalization`.
- Require one phase per `FAngelscriptBind`. A source file may declare multiple binds when a legacy callback mixes declarations, ordinary registrations, generated/reflection work, or finalization.
- Refactor `FAngelscriptBinds` and auxiliary binding helpers to use explicit engine-owned targets rather than ambient current-engine or unpartitioned fallback state.
- Return short-lived `FAngelscriptBoundFunction` and `FAngelscriptBoundProperty` values from direct registrations so fluent traits modify the exact registered object; remove PreviousBind state and helpers.
- Emit UHT runtime-linked, editor CodeGen, reflection, and optional-plugin integrations through the same file-static direct-callback model. Generated module `StartupModule()` implementations do not submit bindings.
- Retain the existing NativeModuleFunctionAddress POD/`IModularFeatures` transport and dynamic arrival/unload behavior as the only documented exception in this change. Target UE modules cannot instantiate Runtime-owned `FAngelscriptBind` objects without introducing a circular module dependency. A separate `refactor-as-native-module-binding-preseal-transport` change owns its eventual convergence.
- Remove runtime bind disabling, provider dependencies, registration handles, late replay/unregister behavior outside the NativeModuleFunctionAddress exception, and long-lived legacy/modern dual paths. Source changes take effect after rebuild and process restart.
- Preserve the current callable surface, including member/free pointers, explicit overload casts, `METHOD` / `METHODPR` / `FUNC`, trivial/native forms, and supported method/global/constructor lambdas.
- Give every project-owned callable registered by a hand-written production bind a stable named C++ entry point. A bind with custom callable implementations keeps registration in `Bind_<Name>.cpp`, declares one owning `FAngelscript<Name>Binds` type in `Bind_<Name>_Functions.h`, and defines non-template bodies in `Bind_<Name>_Functions.cpp`; pointer-only binds do not gain empty companion files.
- Keep lambda overloads in the DSL and cover them in focused compatibility tests, while migrating production method/global/constructor/behaviour lambdas and existing file-local callable wrappers to named functions. Type finders, local algorithms, and UE delegate/async callbacks retain their existing ownership forms.

## Capabilities

### New Capabilities

- `as-direct-bind-callback-execution`: file-static direct callbacks, seven explicit phases, one sorted/sealed global collection, subsystem lifecycle coordination, generated-source convergence except for the documented NativeModuleFunctionAddress transport, and fail-closed engine publication.

### Modified Capabilities

- `as-typed-bind-dsl`: changes the typed DSL to execute against an explicit `FAngelscriptBinds&` context while preserving declarations and callable forms.
- `as-bind-trait-fluent-api`: replaces implicit PreviousBind mutation with direct `FAngelscriptBoundFunction` / `FAngelscriptBoundProperty` fluent values.
- `as-engine-scoped-runtime-state`: keeps callback metadata process-wide while requiring all resolved AS objects, ids, databases, and auxiliary state to belong to a specific engine.
- `as-bind-execution-timing`: observes one-time collection finalization and per-engine provider/phase execution rather than a two-step build/apply model.

## Impact

- Broad source migration across Runtime manual binds, UHT RuntimeLinked emitters, generated fixtures, reflective/native-module consumers, editor CodeGen, `AngelscriptGameplayTags`, and `AngelscriptGAS`. Manual bind units with custom callables additionally gain colocated `_Functions.h/.cpp` files.
- Core behavior remains direct registration: each full engine creation replays the sealed callbacks and produces independent AngelScript state.
- Startup memory does not retain expanded registration descriptions. The only process-wide binding data is one compact callback record per logical bind.
- The global collection is immutable after subsystem-coordinated finalization; new direct callback providers loaded afterward require process restart. NativeModuleFunctionAddress retains its current dynamic transport until its follow-up change.
- `Binds.Cache`, script-visible declarations, callable behavior, RPC routing, StaticJIT/native metadata, and generated binding POD layouts remain compatible unless a separately verified implementation change requires an explicit version bump.
- The debug-symbol improvement adds no function-level binding cache, per-call tracing scope, blanket `FORCENOINLINE`, or normal-path registration/call indirection. Existing native/trivial forms remain available to StaticJIT; former ordinary lambdas do not become native forms merely because they receive names.
