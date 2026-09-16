# Planning validation

Captured 2026-09-15T12:36:44.157829+08:00 for replan-20260915-123155-review-to-executable-plan.

## Stage and scope

This was the first Ensure plan of a seeded Change, prompted by explicit user replan. No prior tasks.md existed; the applied record uses null for absent base_tasks_sha256, not an invented empty-file digest. Approved exports/talks/knowledge and original Review findings are preserved. This operation created current proposal/design/tasks/baseline delta and oracle certification seed only.

## Preflight

- Coverage: every approved matrix axis maps to 3.1-3.6; migration conservation F01 maps to 1.1/2.1-2.6; root guidance F02 to 2.5; oracle certification F03 to 1.2 and dependent coverage. Retired rows are rejection-only.
- Placeholders: forbidden phrase scan clean; all 15 cards have Outcome, Files and exactly one proving command. Behavior cards have Interfaces fences and concrete new RED inputs/outcomes. Migration/document cards state additional semantic acceptance beyond their command.
- Names: homes/layers/Parser classes from the approved glossary; existing VMSource class/helper names from maintained tests; comparator script and helper methods follow adjacent conventions. Actual parser constructor inspected at frontend/Parser/as_parser.h:20. Module entry path confirmed as AngelscriptTestModule.cpp.
- Graph: 15 unique permanent IDs, exact body/graph key set, existing prerequisites, no cycle; shared files restrict execution rather than add fake edges. Matrix tasks depend on both completed migration and certified oracles.
- Preserved content: Review snapshot 283 entries reauthenticated; live product and root/Skill instruction bytes match that snapshot. No test/module file was moved.

## Oracle limits

The ledger explicitly marks signed overflow, shift width, floating zero divisor, out-of-range narrowing and conditional dispatch/storage/retired cells as certification obligations. This plan does not invent product semantics or claim that those cells already have proof. Task 1.2 cannot finish with unsettled required rows; it records exact decisions/defects through update policy if existing contracts do not resolve them. Independent relocation can proceed. In arithmetic shorthand in 3.2, symbols label operations: A=7,B=3 gives A+B=10 and A-B=4; floating A=7.5,B=2.0 gives A+B=9.5 and A-B=5.5.

## Actual checks

```powershell
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-testing-nativeengine-home','--strict','--json')
Invoke-Harness -Command task.status -Context $context -Parameters @{ Change = 'angelscript/refactor-testing-nativeengine-home' }
```

Strict Change validation: Succeeded, one valid item, zero issues. Canonical task.status: Succeeded; 15 total, 0 complete, 15 remaining; Ready 1.1 and 1.2. Resume 1.1. Tasks SHA-256: 2fad8749b936f9200316c4fa2545451f112d349493c4f474a067fad7dfde71c5.

No UE build/test or broad Harness suite was run: this turn only changes planning records. Future per-tenant and matrix proving commands are requirements, not execution evidence. Current durable specs are not synced, root guidance is not yet edited, Review remains open, and no archive/Git/workspace operation occurred. Candidate artifacts under Saved/Harness/ReplanPrepare are removed after validation.
