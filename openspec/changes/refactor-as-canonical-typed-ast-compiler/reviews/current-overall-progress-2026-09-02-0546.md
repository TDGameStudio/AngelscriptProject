# Current overall progress review — 2026-09-02 05:46 CST

## Executive result

- Authoritative OpenSpec checklist: **110/136 = 80.9%**.
- Unchecked rows: **26**.
- Calibrated engineering implementation: **about 85%**, reasonable range
  **84–86%**.
- Default-CANONICAL cutover readiness: **about 72%**, reasonable range
  **70–73%**.
- Recommended planning number: **85%**.
- Recommended auditable number: **80.9%**.

The checklist percentage is unchanged because Task 15.8 still lacks a green
generated-provider publication chain. The internal state did improve: the
exact `FString(const FString&inout)` copy-constructor dependency defect is now
fixed and both the Complete-composition regression and the full
GenerationFacts owner are green. The next official StaticJIT Generate then
advanced past that dependency gate and exposed a different, deterministic
fallback-classification mismatch: the isolated non-final instance-method
fixture expects `UnsupportedFunctionTrait`, while the new frozen entry-plan
precheck reports `UnsupportedSignature:
StaticJITEntryPlanTypedReceiverUnsupported` first.

This is meaningful progress inside an open umbrella, not checkbox closure.
Task 15.8 remains unchecked until Generate, generated-source build, Verify,
generated diagnostic transport and its owner prefixes all pass.

## Fresh authoritative state

- `tasks.md`: **110 checked / 26 unchecked / 136 total**.
- Parent HEAD: `84e1c0c41578`.
- Plugin HEAD: `0816dd453e4a`.
- Plugin worktree: nine modified files, **626 insertions / 8 deletions**.
- Parent review/task edits are intentionally uncommitted while CTA-S184a is
  being validated.
- Unrelated `.claude/skills/openspec-design.md` and `list/` remain untouched.

Exact unchecked rows:

    0.2, 0.3,
    5.7, 5.8, 5.9,
    7.2, 7.4, 7.5,
    9.1, 9.5, 9.6, 9.7,
    10.1, 10.2, 10.3, 10.4, 10.6, 10.7, 10.9,
    12.2, 12.4,
    13.2, 13.6, 13.8, 13.12,
    15.8

## What became green in this pass

### CTA-S184a-DEP is fixed

The authentic RED proved that `EmitCopyConstructValue` emitted a `CALL` or
`CALLSYS` relocation to the selected copy constructor without publishing the
same exact compiler dependency. Production now calls
`builder->MarkDependency(copyCtor, 0, 0)` before emitting that call.

Fresh official evidence:

| Gate | Result | Evidence |
|---|---:|---|
| implementation build | **PASS** | `Saved/Build/cta-s184a-copy-dependency-green-build/20260902_053752_176_c55b0d1b` |
| exact Complete dependency oracle | **1/1 PASS** | `Saved/Tests/cta-s184a-copy-dependency-green/20260902_053809_351_b150797a` |
| complete GenerationFacts owner | **2/2 PASS** | `Saved/Tests/cta-s184a-generation-facts-green/20260902_053858_951_ff908399` |

Both generation-facts tests report `Candidates=7 Captured=7 Skipped=0`.
Therefore the original `Candidates=7 Captured=6 Skipped=1` blocker is closed;
the exact dependency firewall was retained rather than weakened.

### StaticJIT Generate advanced to the next gate

Official command:

    Tools\RunStaticJITTests.ps1 -Mode Generate

The baseline build passed. Every observed complete-composition capture stayed
at `Candidates=7 Captured=7 Skipped=0`, proving that the copy-constructor fix
survives the real commandlet workflow. Generate later failed in an isolated
differential fixture:

    expected: UnsupportedFunctionTrait
    actual:   UnsupportedSignature:
              StaticJITEntryPlanTypedReceiverUnsupported

Evidence:

    Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit_02_generate/
    20260902_053952_303_3a8f460a/Commandlet.log

The affected source is the non-final instance method
`UStaticJITAotFunctionCarrier::ObjectLifetimeEntryForAOT`. Bytecode fallback
still emits successfully; the failure is the harness's exact typed fallback
classification assertion, not loss of fallback or a returned dependency
failure.

## New blocker classification

The mismatch is introduced by the 2026-09-01 frozen-body signature gate:

- the entry plan marks a non-final native-object receiver as
  `StaticJITEntryPlanTypedReceiverUnsupported`;
- `EvaluateAngelscriptTypedASTJITEligibilityFromCanonical` now returns any
  `FrozenBodySignatureFailure` as `UnsupportedSignature` before it reaches
  the existing function-trait test;
- the generation fixture and deterministic verification contract still
  require `UnsupportedFunctionTrait` for this exact non-final method;
- the older entry-plan receiver restriction and the later function-trait
  rejection both remain valid fail-closed gates, but their precedence is now
  inconsistent.

Current disposition: **OPEN / stale exact-reason expectation identified by
independent review**. The receiver-first failure predates CTA-S184a and is the
authoritative frozen entry-plan result; `UnsupportedSignature` was added later
than the fixture's `UnsupportedFunctionTrait` expectation, and the production
files involved in that precedence are clean in this worktree. Keep the gate
exact—update the test to require
`UnsupportedSignature: StaticJITEntryPlanTypedReceiverUnsupported`, then rerun
the complete generation chain. Do not broaden it to accept arbitrary fallback
categories.

The independent review also found that the legacy
`NonCloneableEffectRejected` harness label is misleading: this fixture exits
at the receiver gate before its `FString` body lifetime is analyzed. It must
not be counted as CTA-S184a lifetime coverage. The source-authentic temporary
test and the generated-provider lifetime-summary transport test carry that
proof separately.

## CTA-S184a gate state

| Gate | Result |
|---|---:|
| source-authentic Typed summary | **1/1 PASS** |
| installed-provider diagnostic/firewall | **1/1 PASS** |
| exact copy-constructor dependency | **1/1 PASS** |
| full GenerationFacts owner | **2/2 PASS** |
| official StaticJIT baseline build | **PASS** |
| official StaticJIT Generate | **FAIL at later classification gate** |
| generated-source build | **NOT REACHED** |
| Verify | **NOT REACHED** |
| generated diagnostic transport | **NOT REACHED** |
| TypedASTJIT/provider owner prefixes | **NOT RE-RUN after Generate** |

Task 15.8 therefore remains correctly reopened. The code and evidence are
closer to closure, but generated-provider publication has not completed.

## Permanent compound-assignment record

The `+=` family remains exactly four resolved semantic defects:

1. **CTA-S146 — overloaded lvalue:** `Object += 7` was represented as generic
   Assign instead of resolved `opAddAssign` Call.
2. **CTA-S157 — rvalue receiver:** `Make() += 7` was rejected because one-time
   receiver materialization was confused with lvalue assignability.
3. **CTA-S177-ORDER — indexed sequencing:** receiver/index effects preceded
   the RHS (`1,2,3`) instead of required RHS-first order (`3,1,2`).
4. **CTA-S177-SCALAR-REF-SNAPSHOT — aliasing:** a scalar-reference RHS retained
   an address instead of freezing its pre-mutation value (`21` instead of
   `11`).

`Tail += 100` remains **REDUCED / NOT REPRODUCIBLE**, not a fifth defect. Its
strengthened fresh/reused-context oracle remains **1/1 PASS** at:

    Saved/Tests/cta-s179-tail-declid-strengthened/
    20260902_011308_781_6e3217c8

The copy-constructor dependency defect and the new fallback-classification
mismatch are StaticJIT generation-integrity issues, not compound-assignment
issues.

## Cache V2 boundary

The prior scope decision is unchanged:

- Cache V2/V12 production restore redesign is **deferred / non-gating**;
- opt-in restore prototypes stay as non-blocking regression evidence;
- the Cache default-disabled lifecycle boundary remains in the final gate;
- AST Body Sidecar remains in scope;
- no completion percentage counts the deferred product restore redesign as
  required work for 136/136.

## Why the percentage is still flat

The formal counter only moves when a whole OpenSpec row closes. CTA-S184a has
advanced through several nested gates—source facts, provider firewall, exact
dependency correctness and complete fact capture—but Task 15.8 explicitly
requires the generated Provider and owner matrices too. The current Generate
failure prevents an honest change from 110 to 111.

The three useful numbers therefore remain:

- **80.9%** — auditable checklist completion;
- **about 85%** — calibrated engineering implementation;
- **about 72%** — default-CANONICAL cutover readiness.

The remaining critical path is concentrated in lifetime breadth, TypedASTJIT
closure, canonical Bytecode artifact/install/rollback, full differential
coverage, production entry points, default/rollback selection and final
matrices. These rows are dependency-heavy umbrellas, which is why recent
correctness progress does not translate linearly into checklist percentage.

## Bottom line

> **Formal 110/136 = 80.9%; engineering about 85%; cutover readiness about
> 72%.**

CTA-S184a's original copy-constructor dependency blocker is closed and proven
green. The current blocker is a narrower stale exact-reason expectation
discovered only after the workflow reached farther. Until the expectation is
synchronized and Generate/build/Verify/provider-owner validation pass, Task
15.8 and the formal percentage must remain unchanged.
