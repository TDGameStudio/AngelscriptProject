---
replan_id: replan-20260906-235131-verifier-admission-residuals
status: applied
source: review
source_ref: "attachments/reviews/review-20260906-223032-final-recheck-reviewer.md V01-V04"
scope: "6.6 owns remaining verifier admission: call DWORD effects, final conditional successors, CFG-aware cleanup, full-width result spans"
base_commit: d8343d314f0b948a43a323fc443cf305ff2f5dc3
base_tasks_sha256: 9f736cf3ff7ad832efef48a31e7e6ffbca78bca42cbdc1a947771d9f8964e667
result_tasks_sha256: dc1a3fb583bdf6139ff95855c1c00aee5ec8b721e000dde7447f366c2095dedd
created_at: 2026-09-06T23:51:31+08:00
resume_task: "6.6"
---

## Trigger and Evidence

User-requested Review `review-20260906-223032-final-recheck-reviewer.md` is CHANGES_REQUIRED. Live `as_bytecode_verifier.cpp` matches the snapshot:

- V01 `CallArgumentDwords` uses `Parameters.Num()` (line 91), not TypeUse/PassingMode.
- V02 conditional fallthrough only when `Index + 1 < Count` (line 356).
- V03 Normal/Exception sets are static; CFG worklist is stack height only (lines 177–213, 292–375).
- V04 `ResultDwords * 4` is clamped to `uint8` 255 (lines 141–145).

6.3/6.4/6.5 are `[x]`. Their existing prefixes do not contain these negative cases. 909/909 does not discharge F01 admission.

## Decision

Keep 6.3–6.5 and 11.3 checked. Add 6.6 after 6.5. Do not add 11.3→6.6 (completed node cannot depend on pending work). 11.3 receives `needs_followup` in prose only.

6.6 owns one prefix `VMFlowAdmission`: wide/reference CALLSYS underflow and a balanced wide-call loop; final JZ/JNZ missing fallthrough plus a valid last JMP; declared live slot without Normal cleanup; exclusive-branch Normal destroys of one slot; 64/65-DWORD result span and ResultDwords overflow. TypeUse `NativeOffset` is value-parameter stack DWORDs when a TypeUse requirement is present; missing TypeUse keeps 1 DWORD so existing two-int CALLSYS cases stay GREEN. PassingMode ≠ 0 consumes `AS_PTR_SIZE`. CFG duplicate Normal destroy only when one destroy index can reach the other.

## Impact

Task +1: 6.6. Edge +1: 6.6←6.5. 6.3/6.4/6.5/11.3 `needs_followup` → 6.6. No requirement dropped.

## Old Task Disposition

- 6.3/6.4/6.5/11.3 preserved `[x]` + needs_followup → 6.6
- All other checked nodes preserved

## Diff Snapshot

```text
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/
```

- Task +: 6.6
- Task -: none
- Task ~: 6.3, 6.4, 6.5, 11.3 dispositions
- Edge +: 6.6 depends_on 6.5
- Artifact +: this record; INDEX; tasks.md

## Preserved Work

No product/test source is edited by this record. Historical 1.1–11.3 stay `[x]`. Review files stay immutable until later appended resolution.

## References and Result

Resume at Ready 6.6. Strict change validation is the planning proof.
