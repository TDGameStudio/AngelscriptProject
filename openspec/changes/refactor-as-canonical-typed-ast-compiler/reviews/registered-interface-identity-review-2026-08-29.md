# Registered interface identity implementation review

Date: 2026-08-29  
Slice: CTA-S68  
Detailed evidence: `attachments/canonical-registered-interface-identity-gate-2026-08-29.md`

## Review outcome

CTA-S68 is implementation- and verification-complete. The ordered plugin
checkpoint is `36dd4e7`; the parent commit carrying this review updates the
submodule gitlink. The new architecture no longer identifies an AngelScript
interface by object size. Interface identity is an explicit Runtime declaration
fact created at the registration/declaration boundary, copied into Canonical
Sema facts, used to route Builder relations and persisted in full module stream
V4.

This is the correct boundary for the current mixed architecture. The native
AngelScript Parser AST, Builder and Compiler remain available for explicit
LEGACY, syntax/recovery, differential/reference and rollback use; the Canonical
pipeline receives a pointer-free copied fact and does not retain an
`asCObjectType*` or numeric TypeId as semantic identity.

## Findings closed in this slice

1. **Interface/class ambiguity** — `IsInterface()` always returned false, while
   the dormant size heuristic could not distinguish a valid empty class from an
   interface. Fixed with `isInterfaceDeclaration`, set only by exact interface
   producers and copied by value.
2. **Incorrect type-relation routing** — Builder treated every script-object
   base as `derivedFrom`. Fixed by routing explicit interface identity through
   `AddInterfaceToClass()`.
3. **Missing interface dispatch layout** — the maintained split compilation
   path did not build the per-interface vtable chunks that the writer and
   runtime relationship model expect. Fixed at final class layout, after normal
   method slots have stable indices.
4. **Incomplete module restore** — restore rebuilt the ordered method-id array
   but not the name-indexed `methodTable`, so interface methods disappeared from
   lookup after load. Both views are now rebuilt.
5. **Ambiguous persisted identity** — full module stream V3 had no declaration
   kind. Stream V4 stores and validates one explicit object declaration-kind
   byte; older streams fail closed instead of guessing from layout.

## Architecture assessment

The resulting ownership chain is coherent:

```text
RegisterInterface / Builder::RegisterInterface
                    |
                    v
       asCObjectType explicit identity
          |          |           |
          v          v           v
  Canonical Sema   Builder     Save/Restore V4
  copied fact      relations   durable identity
       |              |
       v              v
pointer-free AST   interface vtable chunks
```

The key positive property is that declaration identity is now orthogonal to
layout and dynamic numeric TypeId allocation. Canonical Sema consumes stable
keys and copied declaration facts; Runtime continues to allocate TypeIds as a
generation-local concern. This avoids spreading dynamic TypeId through the AST
or serializing it as permanent identity.

The [official AngelScript `as_builder.cpp`](https://raw.githubusercontent.com/anjo76/angelscript/master/sdk/angelscript/source/as_builder.cpp)
was consulted as a control-flow reference for interface relation routing and
per-interface vtable chunks. The maintained fork does not copy its size-based
interface heuristic because zero-size classes are valid here.

## Remaining non-claims

- Canonical CodeGen still does not publish lexical interface declarations as a
  complete type/method/inheritance transaction; that belongs to Tasks 9.5/13.6.
- Raw `@` handle tokenization is intentionally disabled by existing parser
  coverage. CTA-S68 proves identity, relationship, lookup and persistence, not
  executable source-level interface-handle dispatch.
- The default remains `LEGACY`; no production `dual` or silent fallback has
  been introduced.
- The native AngelScript AST is retained. HIR remains absent and is not
  recreated.
- Standalone remains deferred and was neither edited nor run.

## Verification snapshot

- Exact AST-first gate: `1/1` PASS.
- Exact module lifecycle gate: `1/1` PASS.
- Nine-prefix regression matrix: `667/667` PASS, `0` failed, `0` skipped.
- Final Runtime/Editor UBT validation: PASS; target graph up to date.
- Strict OpenSpec validation and parent/plugin `git diff --check`: PASS.
- Formal task ledger remains `101/136 = 74.3%`; this bounded slice advances
  parts of Tasks 4.3, 4.5 and 13.2 without falsely checking whole tasks.
- Default-cutover ledger remains `2/9 = 22.2%` until the remaining publication,
  compatibility and cutover gates close.
