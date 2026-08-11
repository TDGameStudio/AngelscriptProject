# Source Audit Method And File-Family Routing

## Mechanical Baseline Commands

Run these at implementation start and store the dated output in this change directory before editing corpus or tests:

```powershell
rg --files Plugins/Angelscript/Source/AngelscriptRuntime/Binds -g "Bind_*.cpp"
rg --files Plugins/Angelscript/Source/AngelscriptTest/Bindings -g "*.cpp"
rg --files Plugins/Angelscript/Source/AngelscriptTest/Coverage -g "*.cpp"
rg --files Plugins/Angelscript/Source/AngelscriptTest/Functional -g "*.cpp"
rg --files Plugins/Angelscript/Source/AngelscriptTest/FunctionLibraries -g "*.cpp"
rg --files Plugins/Angelscript/Source/AngelscriptTest/Syntax -g "*.cpp"
rg -n "BindGlobalFunction|\.Method\(|Namespace\(" Plugins/Angelscript/Source/AngelscriptRuntime/Binds -g "Bind_*.cpp"
rg -n "ScriptName\s*=|ScriptMixin\s*=" Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries -g "*.h"
rg --files Script -g "*.as"
```

For each manual provider, inspect registration calls and header API tables, then confirm public spelling with tests or generated API evidence. Do not classify by filename alone when a file contributes aliases, namespaces, mixins, operators, or more than one receiver.

Normalize `_Type`, `_Functions`, generated-override, and registration shards into logical provider families before assigning corpus ownership. Store the implementation-time result in `research/manual-bind-provider-audit.csv` and `research/binding-test-crosswalk.csv` using the schema in `binding-library-crosswalk.md`.

After the production engine has completed normal binding initialization, enumerate the core `UBlueprintFunctionLibrary` classes actually visible through the AS type/function database and store them in `research/blueprint-function-library-audit.csv`. This final initialized inventory is authoritative for generated/UHT/reflective libraries that cannot be discovered completely from hand-written Runtime source scans.

## Provider-Family Routing

| Provider family | Representative sources | Matrix destinations |
|---|---|---|
| Scalars and primitives | `Bind_Primitives*`, `Bind_CoreGlobals`, `Bind_Hash` | `LANG-*`, `INTEROP-*` |
| Math namespace and values | `Bind_FMath*`, FVector/Rotator/Quat/Transform/Matrix/Box/Sphere/Color/IntVector families | `MATH-*` |
| Containers and iteration | `Bind_TArray*`, `Bind_TMap*`, `Bind_TSet*`, `Bind_TOptional*`, `Bind_FRange`, foreach/iterator registrations | `CONT-*` |
| Text and utility values | `Bind_FString*`, `Bind_FName*`, `Bind_FText*`, formatting, DateTime, Timespan, Guid, Paths, Parse | `TEXT-*` |
| Reflection and object references | `Bind_UObject*`, `Bind_UStruct*`, `Bind_UEnum*`, BlueprintType/Callable/Event, soft object/class/path families | `REFL-*`, `OBJ-*` |
| Actor and Component | `Bind_AActor*`, actor/controller/pawn/player functions, `Bind_UActorComponent`, scene/primitive/mesh/projectile components | `ACT-*`, `COMP-*` |
| World and subsystems | `Bind_UWorld`, WorldCollision, scope WorldContext, GameInstance/LocalPlayer, `Bind_Subsystems*` | `WORLD-*`, `SUBSYS-*`, `COLL-*` |
| Delegates, events, timers | `Bind_Delegates*`, BlueprintEvent, delegate payload, `Bind_SystemTimers` | `DELEG-*`, `TIMER-*` |
| Input and UI | EnhancedInput, InputComponent mixins/events/settings/mapping, UserWidget/UI layout/geometry | `INPUT-*`, `UI-*` |
| Assets/data/json/files | AssetManager/AssetRegistry, DataTable, InstancedStruct, JSON/converter, FileHelper/MemoryReader/StringTable | `ASSET-*`, `INTEROP-*` |
| Diagnostics/platform/console | Logging, Debugging, Console, CVar, Stats, CPU profiler, CommandLine, PlatformMisc/Process/App/MessageDialog | `DIAG-*` |
| Registration architecture | NativeModuleFunctionBinding, deprecations, config enums, explicit bind infrastructure | `OutOfScope` unless a stable AS authoring behavior is exposed |
| UE Blueprint/static libraries | Kismet Math/System, GameplayStatics, Widget creation, Asset/Registry/DataTable helpers | `BPLIB-*` plus the dominant domain row |
| Runtime function/mixin libraries | Actor, Component, Math, FrameTime, HitResult, World/Collision, Input, Curves, SoftReferences, Subsystems, Assets, Widgets, LevelStreaming, Script | `BPLIB-*`, `BIND-*`, and the dominant domain row |
| Binding mechanics | aliases, overloads, constructors, assignments, operators, iterators, out/inout, implicit WorldContext, reflective calls, delegates, ToString, diagnostics | `BIND-*` plus the domain behavior row |

## Evidence Rules

For each matrix row, capture at least one of each applicable evidence kind:

- **Publication evidence**: exact provider/function-library/reflection source.
- **AS spelling evidence**: Bindings, Syntax, or generated API contract.
- **Behavior evidence**: Coverage, Functional, FunctionLibraries, or SDK test.
- **Project-script evidence**: themed `Script/Tests` leaf added by this change.
- **Teaching evidence**: themed corpus function/class and its API usage table.
- **Binding crosswalk evidence**: logical provider family, every contributing `Bind_*.cpp`, representative Bindings/FunctionLibraries test source, and final corpus/test disposition.

If publication evidence exists but behavior evidence does not, classify `CxxBehaviorGap`. If behavior is available only through a test-only inline AS module, normally classify `ScriptTestGap`; add `CorpusGap` only when the operation has genuine reader value.

## Current Script Classification Rules

- `Script/Examples/**`: assign `Migrate`, `Split`, `RetireAsRedundant`, or `KeepSpecialPurpose` in an implementation audit table before moving a file.
- `Script/Game/Example_Actor.as`: always `KeepSpecialPurpose` because cooked content resolves its script parent.
- `Script/Tests/Test_ReflectedScriptSuites.as`: retain as the framework authoring reference; split only if readability materially improves without losing one-stop documentation.
- Root `Script/Tests/Test_*.as` constant fixtures: identify their native source-loading/hot-reload consumers, move those consumers to meaningful themed files, then remove or reclassify the old fixture.
- `Test_GameplayTags.as`: optional-plugin legacy input, excluded from core completion and not moved across submodules by this change.
