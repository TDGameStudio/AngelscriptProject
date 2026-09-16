# BindScriptTypes injects a frozen host graph

## Reusable Insight

Editor binding startup is collection plus inject, not a second live registration pass. Capture failure fails startup. A frozen host type cannot accept later `ExistingClass` writes.

## Evidence

[Accepted design](../drafts/design.md) Q73/Q74. Current `BindScriptTypes` still Verbose-skips capture failure and calls `ExecuteRegisteredBinds` (AngelscriptEngine.cpp). Predecessor HostProduction already asserts empty `GetBindingInstallation()` on Collection-created engines.

## Boundaries

Disposition: candidate. Applies to production `BindScriptTypes` and no-arg `CreateForBindings()`. Host-incompatible sidecars may no-op on `IsHostTarget()`. Live Register remains a separate per-Engine path for non-host types. Do not treat this as permission to hot-replace a published freeze.

## Application

When adding a bind that writes a host type, put it in a phase that runs before freeze. When adding a sidecar that needs a live Engine, guard it with `IsHostTarget()` rather than skipping the whole phase.

## Sources

Confirmed carryover from bindings-gap-audit host-bind-completion. Canonical truth is the Change specs/design/tasks.
