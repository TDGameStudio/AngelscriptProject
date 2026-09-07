---
replan_id: replan-20260905-161909-guidance-language-scope
status: applied
source: verification
source_ref: issue-20260905-161909-guidance-language-scope
scope: task 2.1 owner-test English scan inputs only
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: c6346b48cce28823639c1683d058f6e5e848b0d0e4ef8f00f2172bd618aaa7f0
result_tasks_sha256: 51468076dc7884ec73fc84870741b16737c95b774c8edacadb47f826478c32b4
created_at: 2026-09-05T16:19:09+08:00
resume_task: "2.1"
---

## Trigger and Evidence

The default owner test rejects two existing unrelated language violations. Repairing those files is outside the accepted guidance scope; treating that full scan as the only task proof would couple this change to unrelated work.

## Decision

Retain default full-scan behavior. Add an explicit optional LanguagePaths input to the owner test, validating actual workspace-relative paths and failing on invalid selections. Scope only the English scan; all other package, protocol and fixture checks remain active. New real fixtures prove selected failures, default failures and selection rejection.

## Impact

Task 2.1 gains the exact stable surface selection shown in its execution context. No product, CLI, Harness route, dependency or completion rule changes. Global baseline failure remains reported rather than hidden.

## Old Task Disposition

All three nodes are preserved. Completed 1.1 remains checked. The candidate reuses the just-validated portable TaskPlan's IDs, done values and dependency edges; only verify text and its declared command input change.

## Diff Snapshot

- Task ~2.1 verification; no added/removed nodes or edges.
- Parent has this change untracked plus owned prompt/test modifications among pre-existing dirty files.
- Artifacts ~tasks.md, ~design.md, ~INDEX; +this replan and its issue.

## Preserved Work

Both unrelated language-bearing files, all plugin source, existing user changes and prior test evidence remain unchanged.

## References and Result

Source: baseline OpenSpecSkill.Tests.ps1 exit 1. Resume 2.1; strict validation and scoped owner proof run after application. This record does not claim the unscoped check passed.
