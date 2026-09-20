# INDEX

## Current position

1.1, 2.1, and 3.1 complete. Specs synced into current `angelscript/runtime/delegates` and `angelscript/bindings/delegates`. Ready for terminal evaluation and completed archive.

## Hard conclusions

- This Change is `angelscript/feature-delegates-uproperty-execute`.
- CallPtr stays the script source of truth.
- Native fire converts from CallPtr; do not `ProcessDelegate` property bytes.
- Prove NativeEngine `Compile.DelegateProperty` plus adjacent Compile prefixes touched by Sema/VM.
- Representative map, not a 60-row `UPROPERTY` execute matrix.

## Forbidden

- Do not depend on `openspec/drafts/` paths.
- Do not treat Language execute, full cook, or PIE as this Change's green gate.
- Do not overlay `FMulticastScriptDelegate` on `UPROPERTY` bytes.
- Do not reuse `feature-delegates-property-storage` as this Change's name.

## Attachment index

- [design](drafts/design.md) — accepted scoped design — when planning tasks
- [handoff](drafts/handoff.md) — accepted handoff and Change identity — before Ensure plan
- [Origin](data/harness-origin.json) — frozen export list — when checking seed identity
- [Harness execution](data/harness-execution.json) — Workspace assignment and repository evidence
- [planning-validation](data/planning-validation.md) — Ensure-plan self-review — before plan.verify
- [Talk](talks/grill-20260918-185519-handoff-8ecfec44c2224c89.md) — closed — draft disposition and execution arrangement
- [closure](data/closure.yaml) — completed closure — before archive
- [workflow-evaluation](data/workflow-evaluation.md) — terminal evaluation digest (harness-workflow-evaluation-v1) — before `harness.evolution.status` RequireTerminal; load before completed archive
