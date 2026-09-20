# Final verification

Synced 2026-09-16 after 6.1 frozen snapshot `2b852fdd69e241fcb0291484937fded5`. Seven current capabilities received the Change delta. Unspecified scenarios were retained. Purpose prose now uses HostProcess / ScriptEngine / LiveRegister and shared-host injection.

## Formatting repairs

Two-space quote blocks repaired only in:

- Call native members through the current VM
- Dump sealed binding declarations
- Validate and compare dumps offline
- Seal namespace globals and retain snapshot lifetime
- Reconcile all eligible providers and expected members
- Revalidate without changing a sealed snapshot
- Analyze supported source through the replacement

Text and Requirement/Scenario parentage are unchanged except where a delta replaced the complete card.

## Requirement-to-case coverage

| Capability / requirement | Executed cases |
|---|---|
| definitions: detached host graph, leases, freeze | HostGraph FrozenSharedIdentity, RetainedRecursiveGraph, InvalidFreezeDoesNotPublish |
| definitions: inject/conflict/retire/private transfer | HostInjection TwoReceivingDirectories, ConflictLeavesPriorState; HostScriptRegistration mixed closure |
| type-registry: process IDs and shared pointers | HostGraph; HostInjection; Live* registration families |
| type-registry: live families and host protection | LiveObjects, LiveGlobals, LiveNominal, LiveServices |
| vm: admission and native leases | HostCalls AdmittedExecution, LocalOverrideAndReentry, RetireAndReachableDelegates; VM 333 including UnregisteredScriptFunctionHasNoRuntime |
| binding-engine: CreateForBindings(Collection) | HostProduction ProductionEntryReusesGraph, IsolationAndFailedCreate |
| bindings/runtime: collection/templates | HostCollection, HostTemplates |
| bindings/runtime: six families | HostCore/Math/Containers/Objects/Gameplay/Services bound + accounting |
| bindings/runtime: Blueprint writes | HostBlueprintWrites SerialParallelEquivalence, ActualClassOverlap, BaseOrderAndFailure |
| bindings/runtime: production entry | HostProduction WholeSourceReconciliation (332 = 12/242/78) |
| builder/bytecode: private script + host deps | Compile 147; SourceExecution 131 |
| isolation | RuntimeBindings.Engine.Isolation 9; Bindings.RuntimeBindingIsolation 2 |

Full prefix table: [final-execution.md](final-execution.md).

## Knowledge dispositions

- `knowledges/host-definitions-execution-ownership.md` — **promoted**. 1.2–1.5, 2.x, 5.2 and 6.1 prove shared identity is not execution authority.
- `knowledges/blueprint-class-write-boundaries.md` — **promoted**. 5.1 HostBlueprintWrites proves worker count, overlap latch and inherited X/Y-once.

Capability `knowledges/` trees for vm/bindings/runtime do not yet exist; the Change attachments remain the promoted source.

## Overlapping Changes

No other active Change delta targets these seven capability paths.

## Validation

Recorded after the 6.2 proving commands in the owning task Evidence.
