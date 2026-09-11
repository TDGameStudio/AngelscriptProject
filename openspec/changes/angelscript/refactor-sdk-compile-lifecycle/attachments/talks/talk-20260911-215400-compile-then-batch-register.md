# Full compile does not register into Engine between units

## Context

Delayed registration meant compile (and Emit) without an Engine. A tempting pipeline is compile A, Register A, compile B from Engine types.

## Evidence

- Snapshot `asCBuilder` takes no Engine; DefinitionConsumer TypeInfo has `engine == nullptr`.
- Image `AddDependency` already allowed Frozen definitions without attach.
- User chose compile-all then one Install+Link (Round 7 Q20 A).

## Options

| Option | Result |
| --- | --- |
| A. Compile entire DAG, then one Registration | Engine is not the type library |
| B. Register each unit before the next compiles | Engine becomes compile-time types |
| C. Full compile as A; incremental against live Engine types | Host later; not SDK default |

## Settled Decision

Option A for this Change.

## Consequences and Flip Condition

`GetTypeId` is -1 until Install. Flip if the SDK default must be hot-compile one module against a live Engine.

## Sources

- attachments/drafts/design.md
- attachments/drafts/findings/compile-then-batch-register.md
- draft log.md Round 7 Q20
