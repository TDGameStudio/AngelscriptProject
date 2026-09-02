# Current overall progress review — 2026-09-02 01:51 CST

> **Superseded at 02:23 CST.** This file is the pre-repair snapshot that
> identified the three final Task 5.6 gaps. The current status is
> `current-overall-progress-2026-09-02-0223.md`: all three are repaired, the
> seven-owner gate is 1133/1133 PASS, Task 5.6 is checked, and formal progress
> is 111/136 = 81.6%.

## Executive result

- **Authoritative OpenSpec progress:** **110/136 = 80.9%**.
- **Remaining checklist rows:** **26**.
- **Calibrated engineering progress:** **about 85%**, honest range
  **84–86%**.
- **Task 5.6 implementation progress:** **about 88%**.
- **Task 5.6 closure readiness:** **about 75%**.
- **Immediate formal next step:** close Task 5.6 only after three confirmed
  enum/switch gaps and its seven owning-prefix gates are green; that would move
  formal progress to **111/136 = 81.6%**.

No numerator change is claimed in this review. The three independent reviews
below increased confidence in the remaining defect list, but a review finding
is not completion evidence. `openspec status isComplete=true` continues to mean
only that the proposal/design/spec/tasks artifacts exist; the task ledger is
still **110 complete / 26 open**.

## Current percentage interpretation

The single percentage to use for planning is **about 85% engineering complete**.
The stricter auditable checklist percentage is **80.9%**. The difference exists
because Task 5.6 is one broad unchecked row even though most of its internal
statement/control/evaluator work now has focused RED-to-GREEN evidence. The
engineering estimate credits that verified internal work, then discounts the
remaining lifetime, broad-language, TypedASTJIT, Bytecode/install,
entry-point/default-cutover and final-matrix umbrellas.

This is not **85% release-ready**. Default pipeline cutover and final All-suite
verification are intentionally late dependencies, so remaining risk is more
concentrated than a raw 15% tail suggests.

## Formal task state

| Section | Done | Total | Open |
|---|---:|---:|---|
| 0 AST-first gate | 3 | 5 | `0.2, 0.3` |
| 1 Baselines | 6 | 6 | — |
| 2 AST foundation | 13 | 13 | — |
| 3 Snapshot / leases | 8 | 8 | — |
| 4 Declaration / type Sema | 7 | 7 | — |
| 5 Statement / lifetime / broad Sema | 6 | 10 | `5.6–5.9` |
| 6 Cache containment | 12 | 12 | — |
| 7 TypedASTJIT | 5 | 8 | `7.2, 7.4, 7.5` |
| 8 Generate / diagnostics | 9 | 9 | — |
| 9 Canonical Bytecode | 5 | 9 | `9.1, 9.5–9.7` |
| 10 Product cutover | 2 | 9 | `10.1–10.4, 10.6, 10.7, 10.9` |
| 11 Public API / docs | 5 | 5 | — |
| 12 Final verification | 4 | 6 | `12.2, 12.4` |
| 13 Review convergence | 8 | 12 | `13.2, 13.6, 13.8, 13.12` |
| 14 Type identity / Runtime boundary | 6 | 6 | — |
| 15 Lifetime protocol subplan | 11 | 11 | — |
| **Total** | **110** | **136** | **26** |

## Latest verified progress

The current uncommitted implementation is materially ahead of plugin
checkpoint `182da08` and parent checkpoint `5b8afcd1`. The latest verified
closures are:

| Slice | Current evidence | Result |
|---|---|---:|
| typed constant/recovery result model | `cta-s179-task56-typed-result-green/20260902_012201_844_79b4f8ae` | **3/3 PASS** |
| enum authenticated 32-bit Case-domain consumption | `cta-s179-task56-enum-codegen-authority-green/20260902_012800_093_992fd4b6` | **1/1 PASS** |
| negative-enum exhaustiveness normalization | `cta-s179-task56-negative-enum-exhaustive-green/20260902_013032_170_9656d547` | **1/1 PASS** |
| runtime dividend / constant-zero diagnostic recovery | `cta-s179-task56-runtime-zero-diagnostic-green/20260902_013335_648_5430444a` | **1/1 PASS** |
| Canonical AST Sidecar V13 | `cta-s179-task56-sidecar-current/20260902_013550_625_c42eea1b` | **27/27 PASS** |
| mutable-global constant-provenance repair | `cta-s179-task56-mutable-global-green/20260902_013946_760_2d98ecc1` | **1/1 PASS** |
| current full SemaAuthority owner | `cta-s179-task56-sema-current-green/20260902_014022_928_1231d762` | **564/564 PASS** |
| reduced Tail DeclId/context-reuse oracle | `cta-s179-tail-declid-strengthened/20260902_011308_781_6e3217c8` | **1/1 PASS** |

The `Summary.json` files for the current SemaAuthority, Sidecar, enum CodeGen
and Tail gates were re-read during this review and report zero failures and
zero skips. No source changed after those results before this review.

## Three confirmed Task 5.6 blockers

Three independent read-only subagent reviews inspected separate code paths.
They made no edits and reached the following corroborated conclusions.

### 1. Canonical Bytecode does not consume `SwitchInvalidValue`

Sema already seals `asAST_SAFEPOINT_SWITCH_INVALID_VALUE`, and the verifier
accepts it. Production `EmitSwitch()` currently ignores the role and sends an
unmatched selector without a source `default` straight to the switch end.
LEGACY instead emits `asBC_ThrowException(0)`, producing
`Invalid enum value passed to switch` for an invalid raw enum value.

Required TDD closure:

- prepared script enum, exhaustive cases, no default;
- assert the sealed Switch role before CodeGen;
- execute one valid raw value as a control row;
- execute one undefined raw dword and require the exact VM exception;
- require Canonical CodeGen publisher and zero LEGACY compiler invocations;
- ensure a normal final-case fallthrough jumps over the synthetic throw block.

CodeGen must consume the authenticated role only. It must not traverse enum
members or re-evaluate exhaustiveness.

### 2. Cross-enum mismatch loses the second diagnostic

With `asEP_TYPECHECK_SWITCH_ENUMS=1`, LEGACY reports an enum nominal mismatch
and then continues 32-bit normalization and duplicate checking. Canonical
currently returns immediately after the mismatch, so an alias with the same
normalized value never emits the maintained second `Duplicate switch case`.

Required TDD closure:

- first Case from the selector enum and a later cross-enum Case with the same
  value;
- require mismatch diagnostic first and duplicate diagnostic second;
- preserve analyze-all / commit-none behavior;
- require publisher `NONE`, zero LEGACY calls, no Runtime function and no
  retained snapshot.

The repair belongs in the Sema result model: record the mismatch as diagnosed,
continue numeric recovery and duplicate analysis, then refuse graph commit at
the aggregate diagnosed boundary.

### 3. `MAX` / `*_MAX` sentinels block Canonical exhaustiveness

LEGACY case-sensitively ignores an enum member named exactly `MAX` or ending
in `_MAX` when deciding whether a no-default enum switch is exhaustive.
Canonical currently requires every enum child value to be covered, so it can
leave the role as ordinary `Statement` where LEGACY authors an invalid-value
exception edge.

Required TDD closure:

- exact `MAX` omitted -> `SwitchInvalidValue`;
- suffix `_MAX` omitted -> `SwitchInvalidValue`;
- ordinary case-sensitive `Max` omitted -> ordinary `Statement`;
- use the Canonical enum child declaration's bare `name` in Sema;
- do not duplicate the name policy in Bytecode or TypedASTJIT.

## `+=` permanent issue record

The compound-assignment history remains exactly four resolved defects:

| Defect | Former wrong behavior | Current disposition |
|---|---|---|
| overloaded lvalue rewrite | `Object += 7` remained generic Assign instead of resolved `opAddAssign` Call | **closed** |
| rvalue receiver | `Make() += 7` was rejected rather than materializing the receiver once | **closed** |
| indexed compound order | effects ran `1,2,3`; required RHS-first order is `3,1,2` | **closed** |
| scalar-reference RHS alias | mutation reread the alias and returned `21`; required snapshotted value returns `11` | **closed** |

`Tail += 100` is not a fifth defect. The strengthened reduced oracle proves
fresh and reused contexts produce `0 -> 100 -> 0`, and initializer,
compound-assignment lhs and Return all bind the same DeclId. Its disposition is
**reduced / not reproducible**; Task 9.2 remains checked. The permanent detail
and authentic RED history remain in
`semantic-correctness-issue-ledger-2026-09-01.md`.

## Current owner-prefix state

| Owning prefix | Evidence state |
|---|---|
| SemaAuthority | fresh **564/564 PASS** |
| Cache ASTBodySidecar | fresh **27/27 PASS** |
| Frontend CanonicalAST Verifier | previous **74/74 PASS**; rerun after the three repairs |
| Frontend CanonicalAST | previous **203/203 PASS**; rerun after the three repairs |
| ProductionCodeGen | previous **231/231 PASS** plus focused enum authority; full rerun pending |
| Semantics | previous **15/15 PASS** plus reduced Tail oracle; full rerun pending |
| Module CanonicalAST Snapshot | targeted current evidence only; full rerun pending |

Passing tests that do not yet contain the three missing behaviors cannot close
Task 5.6. After adding the RED/GREEN oracles, all seven owners must be current
against the repaired source.

## Remaining dependency route

The 26 open rows are a dependency chain, not 26 unrelated features:

1. maintain Task 0.2 cards; repair the three Task 5.6 gaps; rerun all seven
   Task 5.6 owners;
2. close `5.7–5.9` with broad Sema authority `13.2`;
3. close TypedASTJIT `7.2/7.4/7.5`;
4. close Bytecode/install/metadata/differential `9.1/9.5–9.7`, production
   CodeGen `10.4/13.6`, and non-default snapshot publication `13.8`;
5. finish entry points `10.1/10.3/10.6`, run `0.3`, then perform default
   cutover `10.2/10.7/13.8/10.9`;
6. reconcile Task 0.2 cards; run focused `12.2/13.12`; run final All
   `12.4/13.12`;
7. audit all 136 rows and commit the plugin first, then the parent gitlink and
   OpenSpec records.

## Cache V2 boundary

The prior user decision remains authoritative: Cache V2/V12 restore/product
redesign is deferred and is not a current Task 5.6 or product-cutover gate.
The fresh Sidecar V13 result remains relevant only to the pointer-free Canonical
AST snapshot representation owned by this change. It does not reopen or claim
completion of the deferred Cache product path.

## Working-tree state

- plugin checkpoint: `182da08`;
- parent checkpoint: `5b8afcd1`;
- plugin working diff: **23 files**, approximately **5733 insertions / 257
  deletions**;
- parent has the plugin gitlink plus current OpenSpec attachment/review changes;
- unrelated untracked `.claude/skills/openspec-design.md` and `list/` remain
  untouched;
- `git diff --check` reports no whitespace errors, only existing LF-to-CRLF
  conversion warnings;
- no commit, merge, default-pipeline switch, archive or publication is claimed.

## Bottom line

The defensible current answer is **80.9% formal / about 85% engineering**.
Recent work has materially advanced Task 5.6 and its current SemaAuthority and
Sidecar owners are fully green, but the task remains unchecked because three
enum/switch correctness gaps are independently confirmed and five other final
owner-prefix reruns must follow their repair. The `+=` family is permanently
recorded as four resolved issues; the Tail probe is separately reduced and is
not an open fifth issue.
