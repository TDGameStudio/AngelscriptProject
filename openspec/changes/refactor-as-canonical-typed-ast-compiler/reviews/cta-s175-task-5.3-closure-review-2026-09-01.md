# CTA-S175 / Task 5.3 closure review — 2026-09-01

## Review result

Task 5.3 is complete. No blocking correctness finding remains in the
ABI-independent Canonical call model after CTA-S175. Formal progress is now
**108/136 = 79.4%**, with **28** rows open. The risk-weighted whole-change
assessment rises modestly from approximately 81% to **approximately 82%**;
cutover, backend consumption, LEGACY isolation and final regression still carry
substantially more risk than one checklist row suggests.

## What closed

CTA-S175 recreates the last deleted historical call oracle:
`BindRebindAndUnbindRetainTheImportedSlotInsteadOfTheMutableBoundFunction`.
The retained AST names one stable provider-A `ImportDecl` and one concrete
zero-argument `int` Call. It does not name the Runtime slot or either provider
FunctionId. Bind A, rebind B and unbind mutate only `sBindInfo`; after every
mutation, AST dump and Sidecar V12 bytes remain identical. CodeGen keeps
`CALLBND` and execution changes `11 -> 29 -> exception` with zero LEGACY
compiler invocations.

The only RED was a valid test-harness boundary: a module that had not selected
`asAST_RETAIN_SNAPSHOT` did not expose a retained context. Enabling the public
retention policy made both characterizations green without a production edit.

## Final Task 5.3 evidence

| Gate | Result |
|---|---:|
| Focused import Sema immutability | **1/1 PASS** |
| Focused import CodeGen execution | **1/1 PASS** |
| Complete SemaAuthority | **533/533 PASS** |
| Complete ProductionCodeGen | **229/229 PASS** |
| Complete Frontend CanonicalAST | **189/189 PASS** |
| Complete Cache V12 | **586/586 PASS** |
| Build after CTA-S175 test addition | **PASS** |
| OpenSpec strict validation | **PASS** |

Git history's seven literal `TypedSemanticIR/Call*` methods now all map to
current Canonical gates: hidden/native call shape, concrete result and operand
boundary, compile-out rewrites, declaration/body identity, import slot
immutability, receiver position, and reverse-formal argument order.

## Percentage interpretation

- Formal OpenSpec: **108/136 = 79.4%**. This is the authoritative checklist
  number.
- Evidence/risk weighted: **~82%**. This estimates remaining delivery risk, not
  checkbox count.
- Section 5 formal: **4/10** rows complete after 5.3. The low row ratio reflects
  broad sequencing/control/lifetime umbrellas, not missing ordinary call
  families.

## Remaining boundaries

Task 5.3 closure does not close:

- 5.4–5.9 sequencing, control, lifetime and advanced semantic umbrellas;
- 7.4 complete native ABI/bridge/direct/fallback and cross-TU consumption;
- 9.x Bytecode lifecycle/backend closure;
- 10.x default cutover and LEGACY isolation/deletion;
- 12/13 final regression, archive, and broad Sema acceptance.

The next work should be chosen from those independently open rows; reopening
5.3 would require a concrete missing historical/source call oracle, not merely
ABI work already assigned to 7.4.
