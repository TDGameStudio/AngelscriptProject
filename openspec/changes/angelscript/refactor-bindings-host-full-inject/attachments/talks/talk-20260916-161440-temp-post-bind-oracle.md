# Temp scripts and bind logs are the post-bind oracle

## Context

The user asked how to verify the result after a specific engine binds, pointed at `Plugins/Angelscript/Source/AngelscriptTest/Temp`, asked to run TArray and other basic types, look at logs, and replan. Earlier they excluded the previous cache system.

## Evidence

[Temp post-bind oracle](../drafts/findings/temp-post-bind-oracle.md) and [Host baseline run](../data/host-baseline-run.md). Current Host* tests are green on a local collection and native pointers. They never call `BindScriptTypes`, never compile production `TArray`/`FString`/`FVector` scripts, and the run emitted no `AS_BIND_*` lines. The Temp directory is missing.

## Options

Keep HostScheme ASTEST_AS as the first compile/call proof; treat Host* pointer calls as enough; or put the first bound-engine proof under Temp: `InitializeWithoutInitialCompile` then compile/run basic-type scripts and assert bind logs. The user chose the last option.

## Settled Decision

`Angelscript.UnitTest.Temp` is the post-bind oracle. One engine, `BindScriptTypes` via `InitializeWithoutInitialCompile`, then `.as` for `TArray`, `FString`, `FVector`, and `Print`/`Log`. Bind logs are `AS_BIND_CALLBACK_SUMMARY` / `AS_BIND_PHASE_TOTAL` / `AS_BIND_CALLBACK_TOP` plus `GetLastSnapshot()`. HostScheme still owns inject-only, shared pointers, freeze reject, and no half graph. Cache tests stay out.

## Consequences and Flip Condition

Task 1.0 creates that oracle before product freeze work. After inject-only, the same Temp prefix must stay green. Restoring HostScheme-only compile/call as the first proof, or treating Host* pointer calls as bind-after-engine success, needs another replan.

## Visual

```text
FAngelscriptEngine.InitializeWithoutInitialCompile
  -> BindScriptTypes
  -> Temp ASTEST_AS (TArray / FString / FVector / Print)
  -> AS_BIND_* + GetLastSnapshot
```

## Sources

User 2026-09-16 request in this Change. Canonical truth is the updated design and tasks.
