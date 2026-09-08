---
review_schema: review-v2
review_kind: external
requested_by: user
state: superseded
assigned_at: 2026-09-06T20:21:49.9237172+08:00
reviewed_at: 2026-09-06T20:23:17.8363658+08:00
closed_at: 2026-09-08T13:17:22.117476+08:00
snapshot_ref: D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/review-20260906-202149-recheck
snapshot_sha256: 4032cb45dd3084eb23e9dce322819d1dca5552446405a10f56c142c53a899b5d
verdict: CHANGES_REQUIRED
---

# Second progress review — repair recheck

## Assignment / snapshot / limits

User explicitly requested another Review of angelscript/refactor-vm-symbolic-execution. Inline tests-first External Review against the new materialized file set. SNAPSHOT.json inside snapshot_ref lists every captured relative path and raw SHA-256; its hash is snapshot_sha256. Copies were hash checked during capture and made read-only. This is an immutable file-set review, not an atomic live-worktree or source/binary equivalence claim.

Scope: previous progress findings P01–P05, their follow-ups 6.5/7.3, latest task/evidence progress, and bounded adjacent tests. Maintained SDK/frontend source, NativeEngine tests, active Change artifacts and a bounded latest-per-label report selection (last 220 run directories) were copied. UE source/binaries, unrelated dirty work and subsequent edits are excluded. No crash experiment, build or UE test was run by this reviewer. This is not an exhaustive new audit of every source emitter or opcode path.

Snapshot tasks: 44 total, 43 checked, 11.3 unchecked. Final exact-source/binary acceptance and opcode-case reconciliation remain intentionally pending; their absence is not an implementation failure by itself.

## Recheck of prior progress findings

| Prior finding | Current assessment |
| --- | --- |
| P01 missing executable lease | The original caller-release counterexample is addressed: Engine publication AddRef, locked AcquirePublishedExecutable and Context m_boundSnapshot exist. New ExecuteAfterCallerSnapshotReleaseReturnsFortyTwo passes. This is not certification of every nested/concurrent shutdown path. |
| P02 recursive ActiveScriptData fallback | Fixed: as_context.cpp:792–795 now returns nullptr when no executable script data exists. NativePrepareExecuteAddTwentyAndTwentyTwo and missing-script Prepare tests pass. |
| P03 skipped calls / fallthrough | Partly fixed: no-argument two-int CALLSYS and ordinary final PshC4 reject. Full width/mode and conditional terminal paths remain defective (R01/R02 below). |
| P04 flat cleanup | Partly fixed: normal/exception duplicate sets are separate; target range and empty type-table checks now exist. Constructed/live state is still not CFG-derived (R03). |
| P05 dispatch failures | Previous exact group now has a successful 16/16 report b0d5b0f916414d6980b0a3eb98036492. Do not repeat the old 14/16 as current evidence. |

These are new-snapshot assessments. Prior records are preserved, not silently edited or lifecycle-closed.

## Findings

Paths are relative to snapshot_ref. SDK prefix: Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/. Tests prefix: Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/.

### R01 — Parameter count is incorrectly used as argument DWORD size

severity: Required
status: resolved
Location: SDK as_bytecode_verifier.cpp:83–98, especially 91; call transfer at 313–320.
Affected acceptance: 6.4/6.5 full signature-derived argument modes, widths and effects.

Observation: CallArgumentDwords computes Requirement.Parameters.Num(), adds receiver width, and never reads each parameter's TypeUse or PassingMode. A Win64 reference or int64/double value occupies more than one DWORD, irrespective of the number of formal parameters. Hidden result storage is also not derived here.

Source-derived counterexamples, not executed:
- Authenticate a native function taking one int64 (or one reference), provide only PshC4, CALLSYS, RET. The verifier consumes one DWORD and can report success although the actual call requires two.
- A balanced loop that pushes one 64-bit argument and calls a void(double) function should restore its starting stack height. Verification subtracts one instead of two, leaving a phantom DWORD and rejecting the backedge as an unequal join.

Tests: VMFlowPathTests.cpp:46–62 creates two nominal TypeUse keys without actual width-bearing type contracts. Its call controls use only two PshC4 values, precisely the case where parameter count accidentally equals DWORD size. Native ABI execution tests do not substitute for malformed admission tests.

Impact: both under-supplied calls admitted to execution and valid signature-sensitive control flow rejected.

Resolution: resolve authenticated parameter/result/receiver storage contracts and passing modes into exact call effects; track pointer/value compatibility as required, not only height. Add valid and under-width int64/double/reference/value-return controls plus a balanced wide-call loop.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.1–6.13: real callable storage contracts, complete typed argument consumption and opcode-defined operand/frame/CFG admission. VMCallAdmission, VMManualAdmission and the complete VM admission selections pass. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### R02 — Final conditional branch still permits fallthrough beyond the function

severity: Required
status: resolved
Location: SDK as_bytecode_verifier.cpp:348–360.
Affected acceptance: 6.5 every executable CFG exit must be valid.

Observation: the conditional-jump branch enqueues the jump target, then only enqueues fallthrough when Index + 1 < Count. If the conditional is the last instruction, it silently omits the false edge. The new ordinary-fallthrough rejection at 370–372 is in a different branch and does not apply.

Source-derived counterexample, not executed: end a nonempty body with JZ to a valid earlier instruction; arrange for the condition to be nonzero. All encoded targets remain in range and stack heights can be balanced, but the not-taken edge exits the bytecode buffer. The verifier accepts the graph rather than reporting InvalidJump at the final conditional.

Tests: PshC4WithoutReturnRejectsFallthrough proves only an ordinary final instruction. No new test covers final taken/not-taken conditional exits.

Impact: malformed control flow can still reach execution and advance PC beyond the function body.

Resolution: explicitly reject the missing fallthrough successor for every conditional control instruction, with final JZ/JNZ and valid backward-branch controls. Retain the valid unconditional-terminal-jump case.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.6/11.4: both final conditional successors are validated; VMFlowAdmission executes direct/decoded final JZ/JNZ rejection and retains valid terminal/backward jump controls. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### R03 — Two cleanup sets still do not prove object state across branches

severity: Required
status: resolved
Location: SDK as_bytecode_verifier.cpp:177–213 and 292–375.
Affected acceptance: 6.4/6.5 initialized/live state merge and guarded conditional cleanup.

Observation: DeclaredLive is copied directly from Frame.InitializedObjectSlots. DestroyedNormal/DestroyedException only partition static records by path category. The CFG worklist still stores just int32 stack heights. It does not interpret object construction, destruction, live guards or cleanup coverage at joins.

Source-derived counterexamples, not executed:
- An initialized live object followed by RET with all cleanup records removed has no check demanding normal cleanup coverage.
- Two normal-path destroy records for the same frame slot, belonging to mutually exclusive branches, are rejected as duplicates regardless of InstructionIndex.
- A lexical slot marked initialized in the descriptor is not checked against a branch that skips construction before reaching cleanup.

Tests: DisjointNormalAndExceptionCleanupSucceeds contains one RET and no conditional construction. It proves path-category partitioning, not a CFG live-state merge.

Impact: the verifier still cannot establish constructed-only / exactly-once cleanup and can reject legitimate disjoint branch descriptions. Runtime source cleanup traces are valuable but do not prove admission of arbitrary hand-authored symbolic images.

Resolution: derive per-instruction object states and guard facts, merge compatible incoming states and verify cleanup coverage/targets against those states. Add branch-local construction, missing cleanup, skipped construction and mutually exclusive same-slot cleanup cases. Do not equate a two-set table check with path-sensitive verification.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.8/6.12: VMLifetimeAdmission and VMIndexedAdmission reject skipped construction, bypass, repeated destruction and incompatible joins. VMSourceUnwind preserves constructed-only reverse cleanup and return-97 recovery. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### R04 — Existing cache regression lacks replacement passing evidence

severity: Advisory
status: resolved
Location: tests VMCacheTests.cpp:308–322; copied run 87c08d17de7c4d7fbd37f373b96be703/AutomationReport/index.json.
Affected acceptance: pending 11.3 adjacent/full regression reconciliation.

Observed run: exact VMCache. prefix reports 8/9; TamperedBytesRejectDecode failed its expectation that Decode reject. The captured test still flips Bytes[Bytes.Num()/2] and expects unconditional decode failure. New VMCacheContracts reports 14/14, but this is a different prefix and does not rerun the old method. A historical VMIntegration run also has zero completed cases; a later single-method passing run is not whole-group completion.

This is an evidence gap, not a claim that the current source necessarily reproduces the old failure. A midpoint byte flip may alter semantically valid payload; whether decode must reject arbitrary changes depends on the actual authenticated wire contract, so the reviewer does not prescribe weakening or strengthening the checksum contract without that check.

Resolution: final 11.3 should run the whole unchanged binary, reconcile the old cache oracle with the intended corruption contract, diagnose any reproduced failure and retain its passing replacement. Do not count the new Contracts group as evidence for this old case.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 11.3/11.4: final-runtime-drain-acceptance.md authenticates all 55 task selectors, 213 opcode rows and 112 source cases against the final 1080/1080 report and frozen source/four DLL identities; existing VMCache and adjacent regressions have current passing proof. Historical crashes, fixture failures and missing earlier RED remain explicitly historical. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

## Tests and actual progress

Existing reports inspected (not tests executed by this review):

| Group | Run | Result |
| --- | --- | --- |
| VMFlowPath | 1bec4eda00864c75b33e85233efdf454 | 6/6 |
| VMFlowVerification | 44cee0168d20448eb64b0dcc01f1d16a | 5/5 |
| VMExecutableLeases | 8ff7688d7e6a464583e00b7ee0e4a70f | 3/3 |
| VMExecutableOwnership | cbe01da75fd343cdb5d2279aafff3ace | 6/6 |
| VMDispatch | b0d5b0f916414d6980b0a3eb98036492 | 16/16 |
| VMIntegerOpcodeMatrix | 4e34f49fa4d74583b52c824cddddff70 | 18/18 |
| VMFloatingOpcodeMatrix | 61b28b69f17c49228842418de1c6b1be | 7/7 |
| VMResourceOpcodeMatrix | e7f1fe6fb03c4f40b09ac4973ec7d36f | 12/12 |
| VMSourceUnwind | 3d133a7005dc431a80dd13aaf6fd686f | 7/7 |
| VMSourceScopeCleanup | be4fc8a5477949cabb940a26822f1502 | 10/10 |
| VMSourceCacheContracts | dead4cd3d0644e19ae58c38731b74870 | 9/9 |
| VMCacheContracts | 9d531ab6d2164e9397046dd78a9268b3 | 14/14 |
| VMCache. | 87c08d17de7c4d7fbd37f373b96be703 | 8/9 |

Expanded tests now include real execution of many integer/floating/resource instructions, native receivers/references, object/Context lifetime, source numeric/call/scope/unwind behavior and source cache restoration. These are substantial advances from the previous snapshot. Method totals do not by themselves establish every required opcode-row oracle; that reconciliation remains assigned to 11.3. Different run times and overlapping prefixes must not be summed into a fresh full-suite count.

R01–R03 are source-derived findings with unexecuted counterexamples; the actual native verifier was not run against newly authored malformed fixtures here. Existing grouped GREEN demonstrates those groups' supplied cases, not absence of these errors. No full UE build/Automation, Quick, Performance, Integration profile or Standalone tests were run: this bounded review reuses existing evidence. No implementation, tasks, spec, old Review, archive or commit was changed.

## Verdict

CHANGES_REQUIRED. The original lease-release and recursion defects have concrete repairs and focused passing tests, and the old dispatch failure has passing replacement evidence. The verifier fixes remain narrower than the accepted contracts. Resolve R01–R03 and perform the pending exact-source/binary final acceptance before claiming complete VM symbolic execution closure.


## Coordinator supersession

Superseded 2026-09-08T13:17:22.117476+08:00 by [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md) because this report describes an earlier immutable implementation. Its CHANGES_REQUIRED verdict and original finding text remain historical truth. Every finding now has a specific appended resolution and the new snapshot re-evaluation is APPROVE.
