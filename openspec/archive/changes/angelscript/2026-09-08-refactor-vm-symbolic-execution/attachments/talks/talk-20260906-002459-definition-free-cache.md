# Decision: Pre-registered Definitions and Symbolic Executable Cache

## Context

The user wants hand-authored bytecode plus stable type references to run against small SDK Engines, including ordinary native C++ and AS-created types, and later enable independent bytecode caching. The accepted first mode requires definitions to be supplied before loading; no UE integration is requested now.

## Evidence

Actual metadata objects already exist independently of an Engine and expose stable keys before registration. Registration binds original pointers and local IDs transactionally to one Engine. However, VM/native-call/object/GC services remain dormant or coupled to old UE/table ownership; a stable-key lookup alone cannot execute or retain those resources. See data/runtime-dependency-inventory.md via the attachment index for exact source anchors.

## Options

| Option | Consequence | Decision |
|---|---|---|
| Pre-register all definitions, cache bodies and stable requirements | Explicit small fixtures, authentic current host contracts, no second definition loader | Accepted first mode |
| Restore AS types and callable declarations from cache | Requires definition serialization, dependency reconstruction, metadata ownership and new admission rules | Later separate Change if requested |
| Remove the SDK Engine entirely | Duplicates allocation/GC/Context/binding ownership before the execution boundary works | Rejected for this Change |
| Hash object memory or only short type names | Process/registration sensitive or nominally ambiguous; cannot prove schema/layout | Rejected |
| Execute only a scalar subset | Fails the user's accepted full maintained VM scope | Rejected |

## Settled decision and consequences

Use the minimal SDK Engine as runtime owner. Keep existing identity hashes and add separate schema/layout witnesses. All types, callable declarations and globals/storage must preexist; cached signatures authenticate, bodies bind through separate runtime snapshots. This includes free functions, methods, constructors, destructors and native declarations uniformly. String constants belong to the code image; heap/global/suspended state does not.

New AS heap storage owns dynamic type and lifetime before the payload; fields remain payload-relative. Code and live runtime leases protect execution, while metadata leases preserve readable definitions only. The full maintained interpreter, supported Generic/typed native calling, object lifecycle, dispatch, GC and Context control all require actual tests. Complete does not mean merely opening CreateContext.

## Flip condition

A request to restore definitions, share one attached image between Engines, hot-replace installed bodies, support real UE classes, or change the target ABI requires a new explicit product boundary or evidence-backed Replan. Ordinary local implementation failures do not reopen this choice. No unresolved choice requires a second exploration before the Ready task.

## Visual

```text
+ persistent image                         + destination runtime
| code + signatures + stable requirements | registered definitions + native/storage bindings
+---------------------+                   +----------------------+
                      +---- validate / resolve / atomic link ----+
                                             |
                                live snapshot -> actual SDK VM
```
