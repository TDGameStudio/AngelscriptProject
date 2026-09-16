## Context

The accepted [scoped design](attachments/drafts/design.md) and [handoff](attachments/drafts/handoff.md) settle product and test-cleanup decisions. The predecessor already owns shared HostProcess identity, inject admission, live Register, and class-owned Blueprint writes. This Change removes the remaining dual path.

## Goals / Non-Goals

**Goals:** Prove a bound engine with Temp Prepare/Execute calls and bind logs first. Then capture every registered bind through one seven-phase freeze, inject that graph from `BindScriptTypes` and `CreateForBindings()`, keep S1 / S4-S6 on HostScheme and S2/S3 compile on Temp after inject, record P1-P4, migrate family/Calls contracts onto Host fixtures, and delete Store/Apply.

**Non-Goals:** Reopen `host-collect-inject`. UHT, disk cache, old cache suites, manifest v2, directory rearrange, legacy revival, hot-replace, "must be faster", Insights, unconditional Quick/Integration.

## Decisions

1. **Editor inject-only.** Dual-path replay would keep frozen host types and live `ExistingClass` writes in conflict. All seven phases run before freeze so those writes happen on the Collection. Sidecars that need a live Engine keep `IsHostTarget()` early returns; the phase still runs.
2. **Temp oracle first, then product.** Task 1.0 proves a bound engine with Temp Prepare/Execute calls and bind logs before capture or inject-only edits. Legacy module compile is unavailable; 2.1 owns `asCBuilder` compile after inject. HostScheme keeps S1 / S4-S6. Family migration stays later nodes.
3. **Store corpus is not the green gate.** Recording and Store-only accounted tests retire. Distinct-pointer Isolation cases cannot remain success criteria.
4. **Perf records, no speed bar.** P1-P4 require `attachments/data/` numbers and invariants (no rerun, graph survives). A missing attachment cannot complete a perf node.
5. **Readable Host tests.** One method, one scene. Prefer `ASTEST_AS` for compile/call. Do not pack Collection+inject+call+accounting.
6. **Temp is the post-bind oracle.** `Angelscript.UnitTest.Temp` constructs a local `FAngelscriptEngine`, calls `InitializeWithoutInitialCompile` (`BindScriptTypes` at AngelscriptEngine.cpp:1705), Prepare/Executes `TArray` / `FString` / `FVector` / `Print`, and asserts bind logs. Cache exclusion is `IsCacheV2Enabled() == false`. Host* pointer calls are not that proof.

## Risks / Trade-offs

Reflection and TypeInfrastructure callbacks still assume a live Engine in places. The flip condition is evidence that Blueprint reflection cannot finish the host graph before freeze; then replan, do not restore DirectBinds. Test-module `Host*` records may enter the production freeze; filter them only with the existing OwnerModule convention.

## Compatibility / migration

`CreateForBindings(Store)` and `GetBindingInstallation()` remain only until 4.4 deletes them. Existing packed `Bindings.Host*` tests stay until a migrating node splits or replaces them. Python Store dump/validation tools lose their production owner with the Store requirements; Collection `InspectHostDeclarations` remains the inspection surface.
