# Current progress delta — 2026-09-01 08:38 CST

This report supersedes `current-progress-and-blockers-2026-09-01.md` only as
the newest status snapshot. The earlier report remains an immutable 01:39 CST
record.

## Headline

- Exact OpenSpec completion: **107/136 = 78.7%**, up from 104/136 at 02:01 and
  103/136 at the earlier review snapshot.
- Remaining formal rows: **29**.
- Estimated practical engineering completion: **about 90% (±3%)**.
- Product default remains **LEGACY**; this is not cutover-, archive-, or
  merge-ready.

The three newly closed rows are Task 4.5, Task 4.6, and Task 5.2. Section 4
(declaration Sema) is now **7/7 complete**. Section 5 is **3/10** and Task 5.3
is the active implementation front.

## Newly closed work

### Task 4.5 — declaration dependencies, lifecycle and diagnostics

CTA-S128/S129 close the remaining declaration-authority families:

- class base relation and stable dependency;
- generated `__InitDefaults` identity/origin;
- sealed global constant value;
- default-argument overload conflict diagnosed by Sema;
- editor-only base method versus non-editor override rejected before
  publication.

Recorded gates include focused RED-to-GREEN, SemaAuthority up through 485/485,
and Frontend CanonicalAST 189/189.

### Task 4.6 — production declaration shadow mismatch fail-closed

CTA-S130 adds the missing production publication firewall. If a generated
Runtime candidate's owner/type/traits/source disagree with the sealed Canonical
Decl, `Build()` returns failure, publishes neither snapshot nor Runtime
function, and does not merge the two graphs. This closes the declaration
shadow-diff task rather than merely comparing two offline dumps.

### Task 5.2 — expression assignability belongs to Sema

CTA-S131 makes const-lvalue assignment rejection a sealed Sema fact. An
authored `const int X = 1; X = 2;` now fails before CodeGen with
`expression-not-assignable`, while a mutable control remains valid. This closes
the accumulated 5.2 expression-authority work and moves the active front to
call planning in 5.3.

## Task 5.3 progress

The current call/operator migration has advanced through CTA-S132–S152,
including:

- overloaded `opIndex` and array index/rvalue decay;
- native REF method direct dispatch;
- implicit constructor conversion and structured Construct call arguments;
- hidden WorldContext and named/default arguments;
- namespaced functions and prepared imports;
- non-POD generated getter call rewrite;
- imported dependency generation;
- `opAssign`, `opAddAssign`, reverse operators, inequality, `opCmp`, swapped
  `opCmp`, bitwise-or and bitwise-not rewrites;
- postfix property single-evaluation as an overlapping Task 5.4 slice.

The previous review's non-POD generated-getter failure is closed by CTA-S144.
`Owner.Inner.ReadStored()` now rewrites to generated `GetInner()` and runs the
exact by-value copy-constructor plan, while TMap Iterator/opFor in-place
protocol receivers remain `MEMBER_REF`.

Fresh stable-checkpoint results before the newest call card are:

- exact ProductionCodeGen class prefix: **156/156 PASS**;
- SemaAuthority: **493/493 PASS**;
- Frontend CanonicalAST: **189/189 PASS**;
- the original generated-getter CodeGen method: **1/1 PASS**.

## Current active checkpoint

The next Task 5.3 gate is:

`CanonicalApplyFormatFNameSelectsFStringOverloadAndNamedPrintWithoutLegacyCompiler`

The first attempted GREEN result was:

- **0/1 FAIL**, exit 255;
- Runtime/Editor build immediately before the test passed with exit 0;
- Canonical CodeGen failed with code `-7` for
  `ASemaFormatPrintActor::ShowFormatted()`;
- the unresolved contract is unique `FName -> FString` overload selection for
  `ApplyFormat(GetName(), ">40")` plus the named `Print(Duration: ...)` call
  plan, without legacy compiler use.

The corrected focused rerun is now **1/1 PASS**, exit 0:
`cta-sema-call-53-applyformat-green/20260901_083816_248_35e2a456`.
The matching ScriptCorpus regression is also **1/1 PASS**, exit 0:
`cta-sema-call-53-applyformat-scriptcorpus/20260901_083859_634_605b766f`.
The exact symptom and its corpus fixture are green. No post-fix full
SemaAuthority/Frontend/ProductionCodeGen result exists yet for this card, so
the broad post-fix checkpoint remains pending.

## Formal section status

| Section | Done | Total | Percent |
|---|---:|---:|---:|
| 0 | 3 | 5 | 60.0% |
| 1 | 6 | 6 | 100% |
| 2 | 13 | 13 | 100% |
| 3 | 8 | 8 | 100% |
| 4 | 7 | 7 | 100% |
| 5 | 3 | 10 | 30.0% |
| 6 | 12 | 12 | 100% |
| 7 | 5 | 8 | 62.5% |
| 8 | 9 | 9 | 100% |
| 9 | 5 | 9 | 55.6% |
| 10 | 2 | 9 | 22.2% |
| 11 | 5 | 5 | 100% |
| 12 | 4 | 6 | 66.7% |
| 13 | 8 | 12 | 66.7% |
| 14 | 6 | 6 | 100% |
| 15 | 11 | 11 | 100% |

The declaration front is now closed. Remaining risk is concentrated in call,
sequencing/control/lifetime Sema (section 5), TypedASTJIT closure (section 7),
production Bytecode/publication (section 9), product cutover (section 10), and
final regression/convergence gates (sections 12/13).

## Workspace and validation

- Node OpenSpec strict validation: PASS.
- Parent `git diff --check`: PASS.
- Plugin `git diff --check`: PASS.
- Parent status: 89 entries before this report (8 tracked, 81 untracked), branch
  12 behind / 33 ahead of `main`.
- Plugin status: 92 entries (89 tracked, 3 untracked), branch 0 behind / 30
  ahead of `main`.
- Plugin tracked diff: 89 files, approximately +35,464 / -9,561 lines.

The implementation has advanced materially, but integration readiness has not:
the parent evidence/attachment set has grown substantially and remains mostly
untracked.

## Updated assessment

Use **78.7%** as the auditable OpenSpec number. Use **about 90%** as the
practical engineering estimate. The next material milestone is Task 5.3, not
another single operator gate: its full ordinary/member/mixin/import/native
call, receiver, argument, rewrite, route and dependency matrix must close, then
the broad tests must re-green on one stable source snapshot.
