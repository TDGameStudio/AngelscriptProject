# Verification still missing after the host Change

Observation from 2026-09-16. Predecessor 6.1 proved the Host graph, inject, and thin family ledgers. The user asked to add tests, prove the post-bind scheme, and measure performance.

## What is missing now

```text
existing Host*                         // 30 cases: ledger + a few Prepare/Execute
old RuntimeBindings.*                  // ~310: Store/Apply, not the post-inject surface
.as compiled against injected host     // Host tests almost never CompileModule
BindScriptTypes inject-only            // not productized; no startup assertion
second inject cheaper than first       // Isolation checks pointers, not time
shared graph counted once              // predecessor deferred
call throughput                        // Legacy/Performance microbenchmarks use editor DirectBinds + ExistingClass
```

`FAngelscriptBindExecutionObservation` already has `BeginBindScriptTypesTiming` and per-provider observation. The old two-stage observability spec (Record/Install stages, shared database counted once) describes the replaced architecture; those numbers are not this Change's gates.

Legacy `Angelscript.TestModule.Performance.*` lives under `Legacy/`. It loops script self-calls and native property/function hits using `ExistingClassForTarget` on live types. After inject those either adapt or cannot be this Change's green gate.

## What "scheme after bind" means

After the freeze is injected, scripts and tests must:

1. Find the same HostProcess pointers and process IDs by name
2. Compile / Analyze an `.as` that uses FString/FVector/TArray/Blueprint shells without a second `RegisterObject*`
3. Prepare/Execute admitted host functions
4. After a second Engine injects the same freeze, calls match and pointers match
5. A write to a host type after freeze fails

That is not "make the old Store tests green".

## Performance that can be a real gate

Comparable and tied to this architecture:

- one `ExecuteToHost` wall-clock (seven phases)
- first `InjectDefinitions` versus second (index, not another callback run)
- shared graph still present after destroying one engine

Not a completion gate unless separately approved:

- must be faster than current DirectBinds (no frozen old baseline)
- WriteWorkers N=4 must speed up (the spec already says no implied speedup)
- full Insights / allocation traces (predecessor deferral still holds: noise, facility switches)

Call throughput may adapt a Legacy microbenchmark against injected host types, record median/p95, and set no "must be faster" bar.

## Settled (Q78=A)

The gates are S1-S6 / P1-P4 in [verification-gates.md](verification-gates.md). Q77 later authorized this Change.
