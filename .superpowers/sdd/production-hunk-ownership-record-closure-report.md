# Production-Hunk Ownership Record Closure Report

Date: 2026-07-27

## Outcome

The OpenSpec ownership record is closed for the current production diff:

- 22 production files;
- 164 zero-context hunks;
- 164 unique `File + NewLine` keys;
- 164 ownership CSV rows and unique hunk IDs;
- zero missing, extra, duplicate, or `Unowned` rows;
- zero semantic/build-surface hunk owned only by
  `test-as-native-sdk-comprehensive-coverage`;
- 162 semantic/build-surface hunks with exact linked owners; and
- two explicitly user-authorized non-semantic terminology rows with no
  behavioral root-cause owner.

Comprehensive task 2.6 is checked. Task 2.7 deliberately remains open because
the linked changes have named regressions and retained historical evidence but
have not all completed fresh final build/runtime verification.

No production source, test source, or catalog was changed. No build, UE
Automation, commit, worktree, or source-generation command was run.

## Linked changes created

| Change | Exact production ownership | Existing regression owner | Record state |
| --- | --- | --- | --- |
| `fix-as-static-jit-debug-text-whitespace` | P019 only; `FAngelscriptBytecode::GetInstrDebugString()` terminal whitespace normalization | `FAngelscriptStaticJITAotTests::GeneratedOutputVerify`, `JIT-004`, and literal generated-output scan | Proposal/design/spec/background/issues/verification/tasks created. Source/regression-present tasks checked; fresh build/AOT gates open. |
| `fix-as-switch-int-max-lowering` | P066-P069; both range heuristics, dense-loop counter, and widened comparison in `CompileSwitchStatement()` | `FSwitchTests::SelectorsByCaseAndExit`, `LANG-CF-SWITCH`, `LANG-CF-005`, `LANG-CF-006` | Complete planning record created. Existing source/high-end controls recorded; fresh build/Switch/ControlFlow/SDK gates open. |
| `fix-as-double-int64-bytecode-execution` | P091-P092 only; `dTOi64`/`dTOu64` operand-1 source decoding and two-word advancement | Interpreter owners: `FConstructorParameterTests::ParameterTypesByArityAndSelection` and `FNumericConversionTests::SourceTargetFormAndValue`; exact generated owner: `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter`. | Parameters `1/1`, Numeric `4/4`, canonical regenerated/built AOT `11/11`, complete SDK `674/674`, and strict/planning/whitespace gates pass. Only the separately requested standalone build remains; evidence does not cover broader suites or unrelated StaticJIT products. |

Each new change contains:

- `.openspec.yaml`;
- `proposal.md`;
- `design.md`;
- one normative delta spec;
- `background.md`;
- `issues.md`;
- `verification.md` with exact pending commands and expected evidence; and
- `tasks.md` that distinguishes already-present source/regression facts from
  fresh verification that has not run.

## Existing reference-persistence change amended

`fix-as-reference-bytecode-ownership-persistence` now explicitly owns:

| Hunk | Contract |
| --- | --- |
| P022 | Narrow `ANGELSCRIPTRUNTIME_API` visibility for the existing `FAngelscriptPrecompiledFunction::Process` member, required so AngelscriptTest invokes the production reader rather than duplicating it. |
| P138 | Reader support for uppercase `asBCTYPE_W_rW_ARG`. |
| P142 | Restore translation adjusts only operand 1, the reference/stack offset. |
| P149 | GETOBJ comment documents its exact two-operand format. |
| P150 | Writer-side stack adjustment applies only to operand 1. |
| P151 | Writer serializes both format words. |

The record now names
`FAngelscriptPrecompiledDataArchiveTests::ReferenceCopyTypeOperandsRemapAcrossPrecompiledLoad`
as the exact precompiled-reader regression. Historical evidence includes:

- the pre-export LNK2019;
- the intended post-export operand-remap red;
- focused historical 1/1 green; and
- PrecompiledData parent historical 4/4 green.

The amendment records one rollback boundary for the six hunks, the narrow
export, and the exact production-reader regression. It also makes the opcode
classification explicit:

- uppercase `asBCTYPE_W_rW_ARG` is GETOBJ/reference persistence;
- lowercase-leading `asBCTYPE_wW_rW_ARG` is the already-supported two-word
  numeric layout used by `dTOi64`/`dTOu64`.

The four restore implementation hunks are therefore not classified as numeric
conversion work.

## Comprehensive record reconciliation

The following living records were updated:

- `proposal.md`: linked production-owner list;
- `impact-map.md`: seven linked root-cause changes, completed string-export
  support owner, and the two authorized non-semantic rows;
- `runtime-change-map.md`: three new owners, expanded reference owner, exact
  regressions, current closure states, and final 164-hunk accounting;
- `tasks.md`: task 2.6 checked from exact reconciliation; task 2.7 left open
  for fresh final linked evidence;
- `progress.md`: current linked list, owner counts, corrected operand-family
  classification, and verification caveat;
- `issues.md`: current index and `SDK-QUALITY-237` updated from open ownership
  defect to resolved record defect with linked execution pending;
- `verification.md`: record-level reconciliation and validation evidence;
- `handoffs/production-hunk-ownership-final.csv`: all 15 prior gap rows given
  exact terminal dispositions;
- `handoffs/production-hunk-ownership-final.md`: counts, mixed-file boundaries,
  former-gap dispositions, and verification constraints reconciled; and
- `scripts/ValidatePlanningRecords.ps1`: validator-owned linked reference list
  expanded from four to seven root-cause changes.

The earlier read-only audit was corrected to retain P073/P074 under the user's
explicit authorization. Those rows are now:

- `PrimaryLinkedChange = None-UserAuthorizedNonSemantic`;
- `Disposition = Terminal-UserAuthorizedNonSemantic`;
- behaviorally non-semantic;
- not assigned a fabricated runtime regression; and
- not reverted.

## Final owner counts

| Primary disposition | Count |
| --- | ---: |
| `fix-as-reference-bytecode-ownership-persistence` | 62 |
| `fix-as-script-class-restore-lifecycle` | 56 |
| `fix-as-object-last-native-calling-convention` | 34 |
| `fix-as-engine-property-default-initialization` | 1 |
| `refactor-as-native-sdk-regression-suite` | 2 |
| `fix-as-static-jit-debug-text-whitespace` | 1 |
| `fix-as-switch-int-max-lowering` | 4 |
| `fix-as-double-int64-bytecode-execution` | 2 |
| `None-UserAuthorizedNonSemantic` | 2 |
| **Total** | **164** |

The 15 prior gap IDs reconcile as follows:

- P019 → StaticJIT debug-text change;
- P022/P138/P142/P149/P150/P151 → reference-bytecode persistence;
- P066-P069 → upper-bound switch lowering;
- P091-P092 → double-to-64-bit interpreter execution;
- P073/P074 → terminal user-authorized non-semantic cleanup.

## Validation evidence

### Current-hunk reconciliation

The read-only PowerShell reconciliation parsed:

`git -C Plugins/Angelscript diff --unified=0 -- Source/AngelscriptRuntime`

and compared every new-file hunk key with the CSV.

Result:

- diff hunks 164;
- unique diff keys 164;
- CSV keys 164;
- missing from CSV 0;
- absent from current diff 0;
- duplicate hunk IDs 0;
- duplicate CSV keys 0; and
- `Unowned` rows 0.

Git emitted existing LF-to-CRLF normalization warnings for dirty plugin files.
They did not alter the parsed hunk set and were not treated as whitespace or
ownership failures.

### Linked paths

The scoped link check required all seven names to exist beneath
`openspec/changes/` and appear in `runtime-change-map.md`.

Result: 7 linked paths, zero missing.

### Planning validation

Command:

`openspec/changes/test-as-native-sdk-comprehensive-coverage/scripts/ValidatePlanningRecords.ps1 -ProjectRoot D:\Workspace\AngelscriptProject -OutputPath <temporary-file> -RequireClean`

Result: zero violations. The output path was placed under the operating
system's temporary directory so the validator did not rewrite a repository
artifact outside `apply_patch`.

### Strict OpenSpec validation

`openspec validate <change> --strict` passed for all five affected active
changes:

1. `test-as-native-sdk-comprehensive-coverage`;
2. `fix-as-reference-bytecode-ownership-persistence`;
3. `fix-as-static-jit-debug-text-whitespace`;
4. `fix-as-switch-int-max-lowering`;
5. `fix-as-double-int64-bytecode-execution`.

Result: 5/5 valid.

### Terminology and planning quality

The scoped case-insensitive scan across all new/edited related artifacts found
zero occurrences of the user-forbidden generic term. The four implementation
plans also contain zero `TODO`, `TBD`, placeholder, “implement later,” or “fill
in details” markers.

### Whitespace

`git diff --check` over the affected record paths exited zero. Because several
change directories are currently untracked, a second literal scan covered
every new/edited file for:

- trailing horizontal whitespace;
- missing final newline; and
- extra blank line at end of file.

The first literal scan found one trailing Markdown hard-break on the date line
of the earlier read-only audit. That line was corrected with `apply_patch`.
The final scan covered 44 new/edited files, including this report, and found
zero trailing-whitespace, missing-final-newline, or extra-blank-EOF violations.

## Rejected or corrected command paths

1. The normal `openspec new change <name>` scaffold commands were intentionally
   not executed because they write files directly and the user required
   `apply_patch` as the only repository edit mechanism. Schema instructions
   were read from the existing `spec-driven` change, all new artifacts were
   added by `apply_patch`, and strict validation confirms the resulting record
   shape.
2. A combined read-only probe requested optional `background.md` and
   `issues.md` files from `fix-as-engine-property-default-initialization`.
   Those optional files do not exist, so the combined read returned exit 1
   after successfully reading its available verification record. No file or
   process state changed, and no result from the missing paths was used.
3. The first literal whitespace scan found the single audit date-line issue
   described above. The initial scan was not accepted as final evidence; the
   corrected scan is the authoritative one.
4. A later combined final wrapper omitted required PowerShell token spacing
   around `Join-Path` while assembling the comprehensive file list. PowerShell
   emitted non-terminating module-resolution errors and scanned only 34 files,
   so its apparent exit 0 and partial whitespace count were rejected. The
   corrected wrapper used `-LiteralPath`, explicit `-Path`/`-ChildPath`,
   `$ErrorActionPreference = 'Stop'`, covered all 44 files, and reported zero
   violations.
5. No build/test command was attempted or rejected. Historical build/runtime
   artifacts are labeled retained evidence throughout and are not reported as
   fresh execution.

## Remaining work

Ownership accounting is terminal, but behavioral acceptance is not:

- every open linked change must run its recorded coherent build and focused
  regressions;
- the double-to-64-bit change must first implement a real generated StaticJIT
  `dTOi64`/`dTOu64` parity owner, then record its exact signed/unsigned result
  and cleanup comparison separately from interpreter evidence;
- the new changes must record fresh AOT, switch, conversion, and aggregate
  evidence as applicable;
- reference persistence still requires its broader stream compatibility,
  malformed-input, lifetime, cleanup, and aggregate gates; and
- comprehensive task 2.7 stays open until all linked final evidence is current.

This remaining work is intentional and does not reopen task 2.6.

## StaticJIT parity-owner correction — 2026-07-27

The independent closure review found that
`FAngelscriptStaticJITPrimitiveConversionTests::BitCastAndNumericParity` had
been recorded as the StaticJIT parity owner for P091/P092 even though its
template calls convert `int` and `asDWORD` inputs to `double` directly. It
does not convert double to signed/unsigned 64-bit integers and does not execute
generated StaticJIT code.

The living records now preserve the exact boundary:

- P091/P092 remain owned by
  `fix-as-double-int64-bytecode-execution` as the interpreter operand-1 decode
  and two-word advancement repair.
- `FConstructorParameterTests::ParameterTypesByArityAndSelection` remains the
  primary interpreter reproducer.
- `FNumericConversionTests::SourceTargetFormAndValue` remains the
  signed/unsigned interpreter breadth owner.
- Exact current owner
  `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter`
  executes generated StaticJIT `asBC_dTOi64` and `asBC_dTOu64` paths.
- The delta requirement remains unchanged: interpreter and StaticJIT
  execution must agree for representative signed and unsigned
  double-to-64-bit conversions.
- Tasks 3.4 and 3.5 are checked after implementation and the canonical
  regenerate/generated-build/AOT workflow. The exact owner passes within AOT
  `11/11` and retains the matched generated artifacts, all three attached
  entries, per-function entry counts, exact interpreter parity, and cleanup.
- Fresh interpreter evidence passes Parameters `1/1` and Numeric `4/4`.
- The complete SDK prefix passes `674/674`, and final linked strict/planning/
  whitespace gates pass. Only the separately requested standalone task-3.1
  build remains open.
- These conversion and SDK results are not evidence for NativeCore,
  whole-project full-suite, Disabled-test, obj-last, or counted-reference
  products.

Corrected records include the linked change's proposal, design, background,
issues, tasks, and verification plan; the comprehensive progress,
runtime-change, fork-limitation, and final ownership handoff records; and the
two SDD closure/audit reports that repeated the false ownership claim.

### Correction validation

Fresh validation produced:

- exact claim scan:
  `EXACT_CLAIM_SCAN_PASS files=15 exactMethodReferences=5 falseClaims=0
  checkedGapRecord=1 uncheckedImplementationTask=1
  deltaRequirementPreserved=1`;
- `openspec validate fix-as-double-int64-bytecode-execution --strict`:
  valid;
- `openspec validate test-as-native-sdk-comprehensive-coverage --strict`:
  valid;
- planning validation with `-RequireClean`: zero violations;
- terminology/planning scan:
  `TERMINOLOGY_PLANNING_SCAN_PASS editedFiles=13 linkedPlanFiles=8
  genericTerm=0 residue=0`; and
- literal hygiene plus scoped `git diff --check`:
  `WHITESPACE_PASS files=13 trailing=0 missingEof=0 blankEof=0 nul=0
  empty=0 diffCheck=0`.

The authoritative post-append wrapper reports:

`FINAL_RECORD_VERIFICATION_PASS strict=2/2 planningViolations=0 claimFiles=15
falseClaims=0 exactRejectedMethodRefs=5 explicitGapRecords=5
uncheckedImplementation=1 uncheckedParityRun=1 deltaRequirementPreserved=1
p091p092Owners=2 genericTerm=0 residue=0 editedFiles=13 whitespace=0 eof=13
diffCheck=0`

The exact method name remains only in corrective text that explicitly rejects
it as the parity owner. The review artifact retains the original High finding
as historical review evidence and is intentionally not rewritten.

The first planning-residue probe was discarded because it scanned unrelated
pre-existing comprehensive content and matched both a legitimate
“application placeholder” language-contract term and this report's historical
statement that plans had zero placeholders. The corrected scan covers the
complete linked-change plan for planning residue and all edited records for
the forbidden generic terminology; it passes as recorded above.

Two final wrapper attempts were also discarded before the authoritative final
gate. The first required “StaticJIT” on the same physical line as the
background table's “No exact current owner” cell even though the adjacent role
cell supplies that context. The second guessed a nonexistent CSV property name
instead of the actual `RepresentativeRegressionOrGap` header. Both attempts
had already passed strict and planning validation and stopped only on their
own guard expressions. The corrected final wrapper uses file-specific gap
assertions and the real CSV header.

No production source, test source, delta requirement, P091/P092 ownership, or
primary interpreter owner changed. No build, UE Automation test, or commit was
run for this record correction.

## Follow-up double-to-int64 execution evidence — 2026-07-27

The centralized workflow later implemented and executed the previously open
owner without changing the P091/P092 production boundary:

- Parameters
  `Saved/Tests/fix-as-double-int64-bytecode-execution-parameters/20260727_203151_605_0fd20e0c/Report/index.json`
  passes `1/1`.
- Numeric
  `Saved/Tests/fix-as-double-int64-bytecode-execution-conversions/20260727_203229_950_2e0e4480/Report/index.json`
  passes `4/4`.
- The canonical AOT workflow retains baseline build
  `Saved/Build/fix-as-double-int64-bytecode-execution_01_baseline_build/20260727_202852_089_10e42f40/`,
  four-artifact generation
  `Saved/StaticJIT/Preflight/Commandlet/fix-as-double-int64-bytecode-execution_02_generate/20260727_202908_402_984e4dd6/`,
  generated-source build
  `Saved/Build/fix-as-double-int64-bytecode-execution_03_generated_build/20260727_202929_592_4249eac7/`,
  and AOT report
  `Saved/Tests/fix-as-double-int64-bytecode-execution_04_tests/20260727_202944_840_d76cfee4/Report/index.json`.
  AOT passes `11/11`; exact method
  `Angelscript.TestModule.StaticJIT.AOT.FAngelscriptStaticJITAotTests.DoubleInt64ConversionsMatchInterpreter`
  succeeds with normal shutdown and no crash or timeout.

This resolves the generated-owner gap described by the historical review.
The complete SDK report
`Saved/Tests/fix-as-double-int64-bytecode-execution-sdk/20260727_203343_148_771283d0/Report/index.json`
passes `674/674`, exits `0/0` with `GIsCriticalError=0`, and has no crash or
timeout. Strict validation passes for both linked and comprehensive changes;
planning reports zero violations; scoped parent/plugin whitespace checks pass.
Only the standalone task-3.1 build remains open. This evidence does not extend
to NativeCore, the whole-project full-suite, Disabled tests, obj-last, or
counted-reference behavior.
