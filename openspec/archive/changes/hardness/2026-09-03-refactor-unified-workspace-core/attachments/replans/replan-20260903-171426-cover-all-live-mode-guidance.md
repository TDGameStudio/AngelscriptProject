---
replan_id: replan-20260903-171426-cover-all-live-mode-guidance
status: applied
source: subagent
source_ref: "authoring_routes_alignment report plus coordinator live-skill rg audit"
scope: complete Task 2.1 coverage of live repository-mode guidance
base_commit: 2cb1c62e1f54eb907b8fd6f2ed9b2438042f7d27
base_tasks_sha256: 66a5b16601eb1a4c18c3d755a72a7671916268c1c9db3224cda0f6bc6f192bf6
result_tasks_sha256: 115ee98e5df2d01912c28b3a361a8b4432fbdb66defdf48b9a3cd80c53f0017d
created_at: 2026-09-03T17:14:26+08:00
resume_task: "2.1"
---

# Cover Every Live Mode Guidance Surface

## Trigger and Evidence

Before editing Task 2.1, the authoring subagent reported stale `Current/Plan` and `Goal execution` wording in `openspec-explore/references/question-rounds.md`, which the accepted Files list did not include. A coordinator scan then found the same retired repository-mode model in the live continue/update/apply Skill entries and a broken `New-HardnessContext -Mode Current` example in `unreal-engine-develop/SKILL.md`. Task 3.3 requires no live repository-mode terminology, so the existing Task 2.1 boundary could not satisfy its own downstream acceptance condition.

## Decision

Add all five discovered live guidance files to Task 2.1. Replace repository-mode wording with explicit WorkspaceRoot selection and, where autonomy is relevant, identify Codex `/goal` as an external continuation mechanism that does not choose a checkout. Limit the Unreal edit to live workflow wording and the valid context example; its scripts, routes, and substantive architecture remain deferred to the next Change.

## Impact

- Task 2.1's implementation boundary expands before those files are edited.
- Its verification command and every Task DAG edge remain unchanged.
- Completed Tasks 1.1 through 1.3 remain valid.
- No OpenSpec parser/package, Unreal runner implementation, plugin, integration, push, or worktree cleanup enters scope.

## Old Task Disposition

- `1.1`, `1.2`, `1.3`: preserved complete.
- `2.1`: preserved pending; live guidance coverage corrected before execution.
- `3.1`, `3.2`, `3.3`, `4.1`: preserved pending.

## Diff Snapshot

```text
base commit: 2cb1c62e1f54eb907b8fd6f2ed9b2438042f7d27
evidence paths: openspec-explore/references/question-rounds.md, openspec-continue-change/SKILL.md, openspec-update-change/SKILL.md, openspec-apply-change/SKILL.md, unreal-engine-develop/SKILL.md

Task ~: 2.1 Files adds five live guidance surfaces
Edge +/-: none
Artifact +: this Replan
Artifact ~: tasks.md, attachments/INDEX.md
```

## Preserved Work

- Both prior accepted Replan outcomes, including `openspec/config.yaml` coverage.
- The complete unified workspace, Git, and Hardness core implementations and focused gates.
- All unrelated dirty workspace data and every deferred Unreal implementation decision.

## References and Result

- Global evidence command: case-insensitive `rg` over live English Skill, Codex, OpenSpec configuration, and AGENTS files while excluding archived Changes and `_ZH` content.
- Result Task DAG SHA-256: `115ee98e5df2d01912c28b3a361a8b4432fbdb66defdf48b9a3cd80c53f0017d`.
- Resume at Task `2.1`.
