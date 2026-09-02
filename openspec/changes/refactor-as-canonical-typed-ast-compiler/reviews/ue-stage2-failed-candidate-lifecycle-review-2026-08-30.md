# UE Stage 2 failed-candidate lifecycle review — 2026-08-30

## Verdict

The CTA-S70 repair is accepted for the covered non-Standalone direct
per-module lifecycle boundary. A candidate that has failed at or immediately
after Stage 2 is now abandoned before its own class/destructor layout, global
allocation, function layout, Canonical Seal/CodeGen and JIT. Builder ownership
is released at a deterministic phase boundary, while the existing failed phase
events and final batch rollback remain intact. The engine-global deferred
template size/validation queue is a recorded non-claim.

The implementation is materially safer than relying only on final swap
suppression: the latter kept the old generation active but previously allowed
the rejected candidate to crash in global allocation or become visible to JIT.

This is not a final acceptance of Task 13.6 or the CANONICAL default flip.

Reviewed plugin implementation commit:
`9cba53be77583cea8e3cc449a6db692ac06e2d64`.

## Findings and disposition

| Finding | Severity | Disposition |
|---|---|---|
| UE outer orchestration continued class/destructor layout after Stage 2 failure | High | Fixed with per-module error gate before `BuildLayoutClasses` |
| UE outer orchestration continued global allocation after Stage 2 failure | Critical | Fixed; permanent mutable-global fixture locks the former null-property assertion |
| Function layout could run for a failed candidate | High | Fixed with the same per-module gate and immediate layout-error promotion |
| Stage 3 sealed/generated code for a candidate already known to be failed | High | Fixed; failed entry is Builder cleanup only |
| `JITCompile()` ran unconditionally after Stage 3 | High | Fixed; JIT is inside successful-publication branch only |
| Skipping Stage 3 entirely would defer Builder cleanup because `InternalReset()` does not own it | High ownership risk | Avoided; wrapper remains and deletes/nulls Builder before failed CompileCode event |
| Failed Layout/CompileCode events might disappear and break listeners | Compatibility risk | Avoided; milestones remain, carry failure, and CompileCode reports no JIT handoff |
| Failed hot-reload candidate could replace generation A | High | Existing aggregate rollback plus new regression prove A remains active/executable |
| Same-name retry might inherit poisoned staged state | High | Permanent generation C retry executes successfully |
| Unresolved-call fixture was initially classified as Stage 2 failure | Test-design error | Corrected; it fails at Seal/Stage 3 and is not used as Stage 2 evidence |
| Engine-global deferred template validation can still process a mixed batch after one module fails | Remaining transaction boundary | Recorded for a separate mixed-module/template gate; no simple skip applied |
| Broad replacement maps may indirectly touch a failed candidate in a mixed batch | Remaining transaction boundary | Recorded for dedicated mixed success/failure batch authentication |

## Architecture assessment

### What is now correct

1. **Failure state is a phase gate, not merely a final-result flag.**
   `bCompileError` now prevents post-failure per-module materialization at each
   outer UE phase, matching the intent of direct SDK `Build()` result chaining.
2. **Cleanup and observability are separated.** The wrapper performs required
   ownership cleanup, while events describe phase milestones. This avoids both
   leaked Builder lifetime and event-contract breakage.
3. **Publication remains generational.** The failed candidate is never made
   active; the previous executable generation continues to own its Runtime
   TypeIds, pointers, snapshot and code.
4. **Dynamic identity does not escape.** Because the candidate is abandoned
   before JIT/snapshot publication and then discarded, its generation-local
   TypeIds/pointers cannot become durable identity or replace the last-good
   view.
5. **The error is retryable.** A corrected source rebuild does not need process
   restart or manual module cleanup.

### Why the design is Clang-like in the useful sense

The relevant Clang lesson is phase discipline, not C++ feature complexity:

```text
Parse/Sema candidate
  -> if diagnostics reject it, do not lower or publish it
  -> release candidate-owned compiler state
  -> retain the last-good generation
```

The old UE orchestration treated diagnostics primarily as a final commit
decision. CTA-S70 turns the diagnostic into an actual phase barrier. The
retained native AngelScript AST/Builder/Compiler still exists for the explicit
LEGACY pipeline, syntax/recovery, reference and differential testing; this
repair does not delete it or recreate HIR.

## Event and lifecycle contract

The accepted lifecycle is:

```text
GenerateFunctions event succeeds
  -> candidate becomes failed
  -> no class/global/function layout mutation
  -> failed Layout milestone
  -> Stage 3 wrapper releases Builder only
  -> failed CompileCode milestone, no JIT handoff
  -> no Globals milestone
  -> batch rollback/discard candidate
  -> generation A remains current
  -> later corrected generation C may publish
```

This contract is stronger than checking only the return value. The permanent
test observes internal pre-discard flags specifically because final discard
would otherwise hide forbidden intermediate mutation.

## Remaining risk and next review cluster

The next lifecycle review should use a single mixed-batch fixture rather than
many one-line tests:

1. publish two generation-A modules with a real type/reference relationship;
2. rebuild one valid module so it contributes a non-empty replacement map;
3. fail the other after successful Stage 2;
4. authenticate that the failed candidate receives no reflection/bytecode
   replacement, template validation, global allocation, CodeGen or JIT;
5. authenticate rollback of successful candidates and retention of both
   generation-A modules;
6. retry both logical names successfully.

That clustered test should also classify every entry in the engine-global
`unvalidatedTemplateInstances` queue by generation/module ownership before any
production change is proposed. Today the Layout block runs
`CalculateTemplateSize()` over the complete queue before failed Stage 3 Builder
abandon, and the Stage 4 prelude later uses `EvaluateTemplateInstances(false)`
to move/drain and validate that same queue. A blind
`if (bHadCompileErrors) skip` could leave deferred validation state behind; a
blind global drain can mutate a failed candidate. This needs evidence, not a
local conditional.

After that boundary, the larger remaining work is still full-language
Canonical Sema/CodeGen coverage, detached installation/relocations, complete
lifetime/debug/exception data, broad differential execution and final default
cutover. Standalone remains deferred by user direction.

## Verification

- Runtime/Editor/Test build: PASS.
- BuilderIntegration: **4/4 PASS**.
- final post-review build: **4/4 actions, PASS**; final BuilderIntegration:
  **4/4 PASS**.
- Compiler Events: **7/7 PASS**.
- project Compiler prefix: **83/83 PASS**.
- Canonical ProductionCodeGen: **150/150 PASS**.
- `git diff --check`: clean before OpenSpec record update.
- Standalone: not modified, not run, not claimed.

Detailed RED chronology, crash artifacts, exact paths and permanent test names
are recorded in
`attachments/ue-stage2-failed-candidate-abandon-gate-2026-08-30.md`.
