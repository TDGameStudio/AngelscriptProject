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

- Each ready task names one exact impact-related verification command and concrete acceptance cases. For behavior work, prepare the bounded feature group's related tests, observe their expected RED together, implement that group, and rerun the same proving selection in GREEN. Use the [TDD Skill](../../test-driven-development/SKILL.md) for test design and missing-interface or existing-code boundaries.
- An ordinary local failure is diagnosed and repaired in the current task. Replan only when evidence invalidates an accepted requirement, design boundary, Task DAG edge, verification contract, or required artifact.
- Completion verification establishes the exact task proofs for the final content identity. A fresh task or shared run may already supply them; rerun stale or missing proof, then add only adjacent checks justified by shared impact or failure evidence. A prior snapshot's passing counts never prove later unverified code.
- Post-archive verification adds strict archived validation and the smallest non-destructive lifecycle check that can expose archive-path coupling. It does not repeat implementation tests merely because the directory moved.

## Feature-group batching

Choose group boundaries when writing the task, not after accumulating untested code. Several normal, negative and boundary cases can prove one outcome. Separate independently acceptable products; do not create one Task per test, command or commit. A batch has named outcomes, case selections and a stopping point, not a fixed case count or time quota.

Batching changes process scheduling, not proof order. Run the group's RED before implementing its new behavior and its GREEN afterwards; do not require a fresh UE process for every case or promise one total run for the whole group. Use a cheaper existing real-behavior check when reliable, but do not replace necessary product C++/UE execution with a text scan.

Compatible Ready tasks may share a documented union or justified superset selection. Preserve each task's exact command as its proving selector and record the actual shared command, case identities/results and source/binary identity. One full report can satisfy those selectors without redundant subset launches. Do not invent runner parameters for a union; use only supported selectors or commands. If their scopes cannot be combined reliably, run them separately.

The coordinator alone schedules UE operations and freezes source writers for both build and Automation. Any intervening source change invalidates use of that binary as evidence for the changed code. Completion needs all required and adjacent cases actually executed; aggregate counts, crashes, missing discovery, in-process/not-run cases or an incomplete report do not suffice. A task in a partially failing batch may complete only when exact evidence proves its entire outcome and the other failure cannot invalidate it; never call that whole batch green.

An explicit user-authorized delayed-first-run exception remains bounded to its stated scope and is recorded as missing preimplementation RED, not strict TDD. Merely requesting batching grants no such exception. Preserve existing code and historical evidence; never delete it or fabricate RED to repair provenance. Subsequent work follows the latest accepted policy.

For material instruction changes, use a realistic independent consumer exercise before and after editing, with the same raw request and artifacts. Judge task boundaries, ordering and evidence decisions; a structural/link test alone cannot prove an agent follows prose. Record compensated old-policy behavior honestly rather than manufacturing a failing baseline.

Lifecycle Git verification uses real isolated parent/plugin repositories, actual normal hooks, shared-file selections and interrupted stages. A simulated conversation host can retain actual question payloads and source choices, but cannot prove that a real popup rendered, a user understood or a prompt became statistically more reliable. Knowledge-only factual additions need source/current-contract/example checks and observable later reuse, not a fabricated behavior failure.

`Protocol.Tests.ps1 -ActiveChange <exact-id>` scopes its active material-issue audit to the selected Change; default invocation audits every active issue. All other structural and historical fixture checks still run. If unrelated baseline records fail the default command, retain that failure and its baseline evidence; do not call the repository-wide audit green or repair unrelated records merely to pass it.

## Record evidence

Use ordinary Task Card text or final evidence to record the exact commands, outcomes, scope, and tests actually run. Name each intentionally omitted heavier test and its reason when that makes the bounded scope auditable. This rationale is Markdown evidence; it does not add a parser field or change `record-v1`, `requirements-v1`, or the portable OpenSpec CLI.
