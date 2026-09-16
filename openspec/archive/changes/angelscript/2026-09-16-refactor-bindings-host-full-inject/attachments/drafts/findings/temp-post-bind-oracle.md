# Post-bind oracle is Temp scripts plus bind logs

Observation 2026-09-16 after the user asked how to verify a bound engine, pointed at `Plugins/Angelscript/Source/AngelscriptTest/Temp`, and asked to run TArray / basic-type tests and look at logs.

## What was run

Harness `ue.test` prefix `Angelscript.UnitTest.Bindings.Host`, Fast, run `c359689768d04f8abb85ad11f0918f37`.

- Outcome: 30/30 Success, 0 Fail, 0 NotRun. Duration 25624 ms.
- Cases include `HostContainers.ContainersBoundBehavior`, `HostCore.CoreBoundBehavior`, `HostMath.MathBoundBehavior`.
- Unreal.log: `Angelscript: Display: [RuntimeStartup] Legacy runtime is disabled; module remains dormant.`
- No `AS_BIND_CALLBACK_SUMMARY`, `AS_BIND_PHASE_TOTAL`, or `AS_BIND_CALLBACK_TOP` lines.
- `UAngelscriptSubsystem::Get()->GetEngine()` stays null in HostProduction.

Trimmed record: [host-baseline-run.md](../../data/host-baseline-run.md).

## What those 30 cases actually prove

```text
local FAngelscriptBindCollection
  Append a few production names + handwritten Host* members
  ExecuteToHost
  call native function pointers (Len / opAdd / Add)
  inject two raw asCScriptEngine
```

They do not:

- call `FAngelscriptEngine::BindScriptTypes` or `InitializeWithoutInitialCompile`
- compile an `.as` that uses production `TArray` / `FString` / `FVector`
- execute `Print` / `Log` on a bound engine
- emit bind-execution logs

`Plugins/Angelscript/Source/AngelscriptTest/Temp` does not exist. Legacy `AngelscriptTArrayBindingsTests.cpp` is dormant.

## How to verify after a specific engine binds

```text
FAngelscriptEngine Engine
  InitializeWithoutInitialCompile   // AngelscriptEngine.cpp:1599; calls BindScriptTypes at 1705
        │
        ├─ Prepare/Execute bound functions  // TArray.Add/Num, FString.Len, FVector opAdd, Print/Log
        │    asCBuilder compile waits for inject-only (task 2.1)
        └─ read bind logs
             AS_BIND_CALLBACK_SUMMARY
             AS_BIND_PHASE_TOTAL
             AS_BIND_CALLBACK_TOP
             FAngelscriptBindExecutionObservation::GetLastSnapshot()
             optional as.DumpEngineState CSV
```

Do not use `UAngelscriptSubsystem::Get()->GetEngine()` (null while the default runtime is dormant). Do not start cache. Old `Legacy/Cache` and `VMCache*` stay out.

## Settled for this Change

The first proof that a bound engine works is Temp basic-type scripts plus those bind logs. HostScheme keeps inject-only / share / freeze / no-half-graph. Host* family tests are not that oracle.
