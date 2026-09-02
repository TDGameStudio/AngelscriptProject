# Canonical Hot Reload publisher and failed-publication gate

## Outcome

The real UE `SoftReloadOnly` path already reuses the staged canonical compiler
transaction. The missing work was an explicit host-entry-point proof, not a
new production implementation. A permanent Hot Reload test now proves that a
successful replacement publishes Bytecode from the changed sealed canonical
AST and that a rejected replacement preserves the last good executable,
digest, and snapshot generation.

This closes the Hot Reload row of Task 10.1. It does **not** close Task 10.1 as
a whole: generation, commandlet, and Standalone still need their own real
entry-point publisher gates. It also does not change the product default from
LEGACY, claim complete-language Sema/CodeGen support, or bring Cache V2 restore
back into this change.

## Permanent test

- File:
  `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptCanonicalASTSnapshotReloadTests.cpp`
- Method:
  `CanonicalSoftReloadPublishesNewDigestWithoutLegacyCompiler`
- Group:
  `Angelscript.TestModule.HotReload.CanonicalAST.Snapshot`

The fixture uses the shared real `FAngelscriptEngine`, selects CANONICAL on the
whole underlying script Engine for the duration of the test, and restores the
previous pipeline on exit. It does not substitute a native-only helper for the
UE Hot Reload host path.

```text
source A: return 11
        |
        v
real staged compile
        |
        +--> publisher = CANONICAL_CODEGEN
        +--> legacy invocation count = 0
        +--> digest A + retained generation A

source B: return 29
        |
        v
SoftReloadOnly commit
        |
        +--> publisher = CANONICAL_CODEGEN
        +--> legacy invocation count = 0
        +--> digest B != digest A
        +--> generation B is current; held A lease remains valid but old
        +--> execution returns 29

source C: unresolved unknown_symbol
        |
        v
SoftReloadOnly reject
        |
        +--> no legacy fallback
        +--> publisher/digest/generation remain B
        +--> generation B remains current and executable
        +--> execution still returns 29
```

The first success-path audit was green immediately. That is recorded as an
evidence-gap discovery rather than a fabricated RED phase: no production
mutation was necessary because the real Hot Reload path already satisfied the
contract. Failure atomicity was then added to the same permanent gate.

## Verification

- Initial focused host-path audit: **1/1 PASS** —
  `Saved/Tests/cta-canonical-hotreload-publisher-gate-red/20260825_011021_710_9aa97ae7`.
  The historical label contains `red`, but the actual first result was green.
- Final publisher and failed-publication gate: **1/1 PASS** —
  `Saved/Tests/cta-canonical-hotreload-failure-atomicity-gate/20260825_011202_923_384773e5`.
- Complete Hot Reload CanonicalAST group: **6/6 PASS** —
  `Saved/Tests/cta-canonical-hotreload-complete-regression/20260825_011243_509_bb301652`.
- Initial incremental build: **PASS** —
  `Saved/Build/cta-canonical-hotreload-publisher-gate-build/20260825_011001_448_c94a4b57`.
- Final failure-atomicity build: **PASS** —
  `Saved/Build/cta-canonical-hotreload-failure-atomicity-build/20260825_011142_769_7d04dca3`.

## Remaining boundary

The test proves host-path selection, publisher provenance, exact AST-digest
replacement, retained-snapshot generation behavior, failure rollback, and VM
behavior for this representative Hot Reload slice. The remaining cutover work
is broader:

1. prove generation, commandlet, and Standalone through their actual entry
   points rather than aliases;
2. finish complete-language Sema and CodeGen authority;
3. complete the multi-publisher snapshot audit;
4. run the final AST-first and subsystem matrices before changing the default.

