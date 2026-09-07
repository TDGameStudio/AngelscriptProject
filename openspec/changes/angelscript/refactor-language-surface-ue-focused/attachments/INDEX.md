# INDEX

## Current position

Creation-only planning: proposal, design, six durable delta specs and eight pending tasks. No product code, UE tests or implementation completion is claimed. The related delegate proposal/tasks are aligned to the user's no-Lambda decision; their separate design prerequisite remains pending. tasks.md is the sole execution ledger.

## Hard conclusions

- Remove source shared/external, funcdef, every Lambda, script exceptions/coroutines, user templates, virtual properties and AS BlueprintGetter/BlueprintSetter requests.
- Retain host parameterized types/intrinsics, named callable signatures, native generic calls, VM faults/unwind/GC and host Context control.
- Remove four upstream add-on packages and their consumption chain; do not delete or restore the entire Standalone project.
- The SDK change is intentionally breaking: no old-name forwarding aliases or configuration reactivation. Delegate interop consumes the resulting callable interface.

## Forbidden

- No keyword-wide deletion of Generic/Shared/External/Exception concepts.
- No new delegate feature, container implementation, module scheduler or legacy startup restoration in this Change.
- No product PASS claim from planning validation or historical VM counts.

## Attachment index

- [Current surface inventory](data/surface-inventory.md) — inspected source paths, consumer roles, retained mechanisms and bounded removals; read before any product task.
- [Planning verification](data/planning-verification.md) — creation/update commands, structural and scope checks, pending-task counts and omitted product tests; read when assessing what this delivery actually proved.
