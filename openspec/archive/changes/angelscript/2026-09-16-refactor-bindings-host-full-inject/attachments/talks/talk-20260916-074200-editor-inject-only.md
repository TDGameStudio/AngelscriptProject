# Editor injects the frozen graph and never replays migrated hosts

## Context

Production still captures a tiny Host whitelist, then `BindScriptTypes` runs `ExecuteRegisteredBinds` on the live editor. Frozen host types reject later `ExistingClass` writes, so the editor cannot inject the full FString/FVector package today.

## Evidence

[Remaining bind coverage](../drafts/findings/remaining-bind-coverage.md) shows the three paths. [Accepted design](../drafts/design.md) records Q73=A and Q74=A. Current `BindScriptTypes` logs a Verbose skip on capture failure and then always replays.

## Options

Keep dual-path editor replay for "safety"; inject only a whitelist; or capture every registered bind through all seven phases and inject the freeze. The user chose the last option.

## Settled Decision

`EnsureProcessHostCollection` copies every registered record. `ExecuteToHost` runs TypeDeclarations, TypeInfrastructure, ExplicitBindings, GeneratedBindings, ReflectionBindings, PostReflectionBindings, and Finalization. `BindScriptTypes` injects that freeze and does not call `ExecuteRegisteredBinds`. Host-incompatible sidecars may return early on `IsHostTarget()`; that is not a skipped phase.

## Consequences and Flip Condition

Startup now depends on a complete host freeze. A callback failure fails `BindScriptTypes` instead of falling back to DirectBinds. If Blueprint reflection cannot finish the host graph before freeze, replan. Do not restore editor replay.

## Visual

```text
all FAngelscriptBind -> seven-phase ExecuteToHost -> freeze
BindScriptTypes -> InjectDefinitions only
```

## Sources

Local provenance: bindings-gap-audit Q73, Q74; create authorization 2026-09-16. Canonical truth is the Change design and specs.
