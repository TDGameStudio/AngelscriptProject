# Impact-scoped Verification

Read this reference when choosing a task command, expanding verification after a failure, verifying a Change, or selecting the smallest post-archive check. Begin with the smallest reliable scope that directly proves the changed behavior.

## Select the proving scope

1. For a Skill, Markdown, template, or specification change, run the owner's static or protocol test and strict OpenSpec validation for every affected record or specification.
2. For a single Harness route or module change, run that route or module's direct test. Add protocol coverage only when the public envelope, dispatcher routing, or shared state is affected.
3. For a `ue.*` route change, run its focused route fixture first. Start the matching Unreal operation only when the fixture cannot prove the affected real-UE behavior.
4. Select `Performance` only for a performance contract or suspected performance regression.
5. Select `Integration` only when a cross-component integration boundary changes.
6. Select `Quick` only when a change spans multiple Harness core groups, its affected surface cannot be bounded reliably, or an explicit user request asks for broader regression.
7. Select a complete Unreal suite, build, or Automation run only for matching product-code impact, a release gate, or an explicit user request.
8. When a focused test fails, use its evidence to expand to the adjacent affected surface. Do not jump directly to every aggregate profile or Unreal suite.

The profiles remain public supported entry points; this policy governs when to select them. A broader run needs a concrete reason tied to the affected contract, observed evidence, release policy, or user request.

## Apply, verify, and archive

- Each ready task names one exact impact-related verification command. For behavior work, run it in RED, make the smallest passing change, and rerun the same command in GREEN.
- An ordinary local failure is diagnosed and repaired in the current task. Replan only when evidence invalidates an accepted requirement, design boundary, Task DAG edge, verification contract, or required artifact.
- Completion verification reruns the exact task proofs still relevant to the final content identity, then adds only adjacent checks justified by shared impact or failure evidence.
- Post-archive verification adds strict archived validation and the smallest non-destructive lifecycle check that can expose archive-path coupling. It does not repeat implementation tests merely because the directory moved.

## Record evidence

Use ordinary Task Card text or final evidence to record the exact commands, outcomes, scope, and tests actually run. Name each intentionally omitted heavier test and its reason when that makes the bounded scope auditable. This rationale is Markdown evidence; it does not add a parser field or change `record-v1`, `requirements-v1`, or the portable OpenSpec CLI.
