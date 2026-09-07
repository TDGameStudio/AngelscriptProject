# Acceptance-gap Replan validation

Captured 2026-09-06T11:58:30+08:00. Scope: user-requested fixed-snapshot External Review, current planning truth, missing-acceptance Task DAG and exact source-follow-up ownership correction. These checks are not product RED/GREEN or evidence that the Review findings have been repaired.

## Actual checks

| Check | Actual result |
|---|---|
| Harness task.status | Succeeded; RunId 7c44b8b91cf04e5c8d2119bc85a7f092; 42 total, 19 complete, 23 remaining; only Ready 6.1. |
| Strict Change validation | Succeeded; RunId 5908842011984bac8a6e394687f3b551; one item passed, zero issues. |
| Scoped OpenSpecSkill.Tests.ps1 | Exit 0; OpenSpec package safety tests passed and OpenSpec skill package tests passed. |
| Ordinary harness.evolution.status | Succeeded; RunId 0efeb7eeb2124e80a08f8d21d44ed872; no StructuralErrors, one open review-v2, ClosureReady=false as required for incomplete work. |
| Candidate and saved task contract | Graph/body IDs/states agree; acyclic; all original incoming edges and completed states preserved; all 19 Evidence lines preserved. |
| Original task bodies | Byte-text comparison after newline normalization and removing only new Disposition lines agrees with the fixed snapshot. Original Cases and evidence were not rewritten. |
| Exact saved tasks SHA-256 | b6a410c5af79f681373015d23d2a9232dd841f87b5678f2c2494af7f2be5e3a3; matches the final applied source-ownership correction result digest. |
| Opcode partition | 213 unique assigned ordinals/names; 121 rows for 9.1, 43 for 9.2, 49 for 9.3; 212 supported executions plus STR rejection and 43 reserved/pseudo rejections. |
| Review snapshot | 281 copied files rehashed and read-only; zero mismatches. Manifest SHA-256 4a143b0f981b679a625550dd035b4fba71184188c2eec5213c45082499632b5d. |
| Product preservation | All 251 selected plugin-source/test/header/reference files match their pre-review snapshot hashes; none was edited by this delivery. |
| Attachment navigation | Exact membership of every attachment, once, using the canonical backtick-list form; INDEX remains below 120 lines. |

## Commands actually used

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
Invoke-Harness -Command task.status -Context $context -Parameters @{
    Change = 'angelscript/refactor-vm-symbolic-execution'
}
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @(
    'angelscript/refactor-vm-symbolic-execution', '--type', 'change', '--strict', '--json'
)
& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1 -SurfacePaths @(
    'openspec/changes/angelscript/refactor-vm-symbolic-execution'
)
Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{
    Change = 'angelscript/refactor-vm-symbolic-execution'
    ClosureKind = 'completed'
}
```

The ordinary evolution query does not include RequireTerminal. Its open Review, missing closure evaluation and incomplete tasks are expected closure blockers, not a failed planning delivery or a claim of terminal approval.

## Friction and correction evidence

- Initial strict validation and owner tests passed. The ordinary evolution query additionally reported zero recognized Review index entries because the initial navigation used a Markdown table link. Harness.psm1 Get-HarnessAttachmentIndexCount recognizes the canonical line beginning with a hyphen and a backtick-wrapped relative path. Converted this Change's inventory to that existing form; the repeat query has no StructuralErrors. No Harness parser/API or general prompt change was made; this is recorded navigation-format friction with a local correction.
- Independent source-plan consistency checking found missing AST projection/codec header ownership in 10.3, an undecidable conditional array-source case in 10.5, and a missing explicit negative for external defaults lacking typed data. The small applied ownership correction records exact headers, the omission-reject/explicit-argument-pass control, and nested completed-member destruction order. It preserves the initial applied Replan instead of rewriting that immutable record.
- git status identifies this whole Change as untracked, as before the update. Its scoped git diff --stat / --check are empty and do not by themselves prove untracked text integrity; explicit snapshot/body/hash checks supply that evidence.

## Evidence and authority exclusions

The historical NativeEngine 704/704 runs and warning-bearing three-case Baseline remain unchanged in implementation-verification.md. They do not prove every current source byte or the new missing cases. Source-derived Review counterexamples are unexecuted observations.

No C++ implementation or test source, AGENTS/Skill/Harness implementation, public API or durable capability spec was changed. No UE build, Automation, full suite, Standalone, JIT, Quick/Performance/Integration profile, sync, archive, commit, push or worktree action ran. The five accepted capability deltas remain unchanged. The Review stays open with CHANGES_REQUIRED and all ten Required findings open; new task ownership is not a resolution.
