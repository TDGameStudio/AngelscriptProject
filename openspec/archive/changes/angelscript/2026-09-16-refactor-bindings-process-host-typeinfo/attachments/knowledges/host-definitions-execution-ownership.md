# Shared definition identity is not execution ownership

## Reusable Insight

An immutable type/function can be shared across Engine directories while execution authority and mutable native state remain local. A process ID identifies an object; admission authorizes its use in a specific Engine.

## Evidence

[Execution contracts](../drafts/findings/three-engine-contracts.md), [StableKey/VM analysis](../drafts/findings/stable-key-and-vm.md) and the [source check](../drafts/findings/change-readiness-20260916.md) identify owner checks, ID maps and native interface lookups.

## Boundaries

Disposition: promoted. 1.2–1.5, 2.x, 5.2 and 6.1 prove shared HostProcess pointers with receiving-Engine admission. Script/live private ownership, retirement and object cleanup remain exact-owner constraints. Null GetEngine cannot bypass admission.

## Application

When adapting Prepare, native calls, delegate creation or mixed dependency registration, identify the receiving Engine, exact admitted pointer, callable target and lifetime lease separately. Test an uninjected third Engine, consumer destruction, owner override and nested callbacks.

## Sources

Confirmed carryover Q68, originating in bindings-gap-audit; canonical truth is in the Change specs/design/tasks. Promote only after relevant execution and regression evidence exists.
