---
replan_id: replan-20260903-172256-publish-project-hook-config
status: applied
source: verification
source_ref: "hardness_protocol_hooks focused hook gate plus git check-ignore -v .codex/hooks.json"
scope: make the bounded project hook configuration normally trackable
base_commit: 2cb1c62e1f54eb907b8fd6f2ed9b2438042f7d27
base_tasks_sha256: 47c00cd91004ab3df7d81e8c6626e9ddd8b37fb47ea00e38e85f95aed9f8e0eb
result_tasks_sha256: 66e028ed648fa97d33d58965a2edb6b3ea4c87092df7f40af3b22a69f11d9669
created_at: 2026-09-03T17:22:56+08:00
resume_task: "2.1"
---

# Publish the Project Hook Configuration Safely

## Trigger and Evidence

The hook adapter passed its focused runtime probes, but `git check-ignore -v .codex/hooks.json` proved that the root `.gitignore` excluded the entire `.codex/` directory. The planned project hook would therefore remain an unpublishable local file. Force-adding ignored agent configuration would contradict the Git safety policy.

## Decision

Add `.gitignore` to Task 2.1. Continue ignoring all project-local Codex files by default while explicitly allowing only `.codex/hooks.json`. Add a protocol assertion that the shared hook configuration is not ignored. Do not expose or track any machine-specific Codex configuration.

## Impact

- The project hook becomes a normal reviewable tracked file.
- Other `.codex/` files remain ignored.
- Task 2.1's verification command and all DAG edges remain unchanged.
- No forced Git add, hook behavior expansion, or non-Codex coupling is introduced.

## Old Task Disposition

- `1.1`, `1.2`, `1.3`: preserved complete.
- `2.1`: preserved in progress; publication boundary repaired before completion.
- `3.1`, `3.2`, `3.3`, `4.1`: preserved pending.

## Diff Snapshot

```text
base commit: 2cb1c62e1f54eb907b8fd6f2ed9b2438042f7d27
evidence: .gitignore:127 ignores .codex/; git check-ignore exits 0 for .codex/hooks.json

Task ~: 2.1 Files adds .gitignore
Edge +/-: none
Artifact +: this Replan
Artifact ~: tasks.md, attachments/INDEX.md, .gitignore
```

## Preserved Work

- The passing hook adapter and Protocol gate.
- Every prior accepted Task 2.1 live-surface correction.
- The existing machine-local Codex ignore boundary for every file except the shared hook manifest.

## References and Result

- Hook runtime evidence: SessionStart/SubagentStart JSON output, nested-directory resolution, and fail-open invalid-cwd behavior.
- Result Task DAG SHA-256: `66e028ed648fa97d33d58965a2edb6b3ea4c87092df7f40af3b22a69f11d9669`.
- Resume at Task `2.1`.
