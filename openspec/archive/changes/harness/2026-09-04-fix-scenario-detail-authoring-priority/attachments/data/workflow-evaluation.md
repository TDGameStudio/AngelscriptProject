---
record: harness-workflow-evaluation-v1
result: passed
change: harness/fix-scenario-detail-authoring-priority
closure_kind: completed
input_sha256: 2d5d93a76e1acadd20dc7349bfde1a50ec07f08eed41fb7dd870500d6c4b46e7
captured_at: 2026-09-04T21:59:00+08:00
---

# Workflow evaluation

## Lifecycle

- The user-reported prompt regression entered one focused Harness Change in the selected primary workspace; it was a clear corrective change and did not require deep Explore.
- Proposal, four durable deltas, design, a Ready Task DAG, and the attachment index were strictly validated before implementation.
- Task 1.1 used a focused RED/GREEN cycle for the authoring reference, OpenSpec entry, lifecycle Skills, workflow instruction, and template.
- Generated-instruction inspection then proved that the original Task file boundary omitted `openspec/config.yaml`. Applied Replan `replan-20260904-215500-align-generated-instructions` preserved Task 1.1, added Task 1.2, and made durable synchronization depend on the corrected live prompt.
- Task 2.1 synchronized the complete modified Requirements and Scenario Cards into four current specs and completed impact-scoped verification.

## Material friction and corrective action

The sole planning-invalidating finding was the independently injected config rule. It was recorded as an immutable applied Replan because the accepted task path boundary and dependency edge were incomplete. No implementation issue or Review was required. Intermediate missing-token failures after the initial RED were local test-guided corrections within the accepted authoring contract.

## Verification

- `OpenSpecSkill.Tests.ps1`: passed after proving active evaluation, the smallest useful combination, omission only when detail adds no durable information, exact clause ownership, and the complete palette of quoted notes, prose, ordered or unordered lists, examples, and tables across all maintained authoring sources.
- The same fixture covers all 24 current Scenario Cards introduced by the four recent affected Changes, requiring useful clause-owned `WHEN` and `THEN` detail and representative non-blockquote forms.
- Fresh `openspec instructions specs`: contained the new priority and complete palette; contained neither complex-only nor compact-first regression wording.
- Skill Creator `quick_validate.py`: passed for `openspec`, `openspec-continue-change`, `openspec-update-change`, `openspec-sync-specs`, and `openspec-verify-change`.
- `Protocol.Tests.ps1`: passed.
- `HarnessEvolution.Tests.ps1`: passed.
- Semantic synchronization identity: 12 modified Requirement bodies and 26 replacement Scenario Cards matched between delta and current specifications.
- OpenSpec doctor: valid with zero errors.
- `angelscript` workflow validation: passed.
- Strict exact Change validation: passed with a complete 3/3 Task DAG.
- Strict all-current-spec validation: 7/7 passed.

## Synchronization and ownership

Current `harness/core`, `harness/unreal`, `angelscript/runtime/startup`, and `angelscript/testing/baseline` specifications received meaningful clause-owned detail. Historical archive records were not changed. The portable OpenSpec parser, executable, validator profiles, Task DAG schema, Harness public commands, Unreal code, and plugin code remain unchanged.

## Exclusions

Harness Quick, Performance, the aggregate Integration profile, real Unreal builds, UE Automation, plugin tests, and Standalone tests were intentionally omitted. This Change affects Markdown authoring policy, generated prompt text, static fixtures, and durable specification content only; focused owner/protocol tests and strict OpenSpec validation directly prove the affected behavior. No executable, performance, release, product, or cross-component runtime boundary changed.

## Raw-data provenance

Command results were observed directly in the current PowerShell 7 session. No ignored run output or machine-local path was promoted. The workflow evaluation retains the exact proof summaries and the applied Replan retains the one durable task-boundary correction.
