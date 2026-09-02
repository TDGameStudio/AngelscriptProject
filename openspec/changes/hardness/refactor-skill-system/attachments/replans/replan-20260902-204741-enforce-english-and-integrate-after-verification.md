---
replan_id: replan-20260902-204741-enforce-english-and-integrate-after-verification
status: applied
source: user
source_ref: "User decisions: maintain OpenSpec in English, exempt only _ZH filenames temporarily, validate before integration, use top-level hardness/core, preserve dogfooding knowledge, and self-monitor Replan correctness"
scope: language-identity-knowledge-closure-and-integration-contracts
base_commit: 4129487f63fab930800a896ae7f932d7bd4e6e70
base_tasks_sha256: 969db2efd82408e8f9ff8f0c111b48957822970a9ff7dc97c2a912416d65efca
result_tasks_sha256: 37d8cac0d3ed5e10a57295963362d6bdb4815807473f036fd59ea22999ccabba
created_at: 2026-09-02T20:47:41.9646841+08:00
resume_task: "1.4"
---

# Replan — Enforce English and integrate only after verification

## Trigger and Evidence

The user confirmed that maintained OpenSpec material must use English and later narrowed the temporary localization exception to files whose own names contain exact uppercase `_ZH`. The reviewed 0.7.1 source still contained non-English maintained records and its package gate did not cover the complete maintained surface, so the release and acceptance boundary had become false. The user also explicitly requested eventual integration, but corrected that request to require all implementation, verification, Review, commit, closure, and archive-audit gates first.

Dogfooding then exposed two identity and knowledge issues. The capability name `angelscript/tooling/hardness-harness` duplicated repository context even though Hardness is the high-level domain, and current evidence had no durable Hardness spec/knowledge target. The canonical change was therefore moved through the CLI to `hardness/refactor-skill-system`, preserving UID `change_96d0ba36-d839-423e-8a76-f49973b87e18` and the old ID as an alias; the capability target became `hardness/core`.

## Decision

- Preserve immutable `v0.7.0` and `v0.7.1`. Add Task `1.4` to publish, package, and independently review a new English-only 0.7.2 snapshot.
- Scan the complete maintained OpenSpec surface. Exempt only a filename containing exact uppercase `_ZH`; do not exempt an ordinary file, directory, or linked label.
- Move the active change through the CLI to `hardness/refactor-skill-system`, retain its UID and alias, and target the durable capability at `openspec/specs/hardness/core/`.
- Keep concise dogfooding and evolution knowledge as change evidence, then promote only reusable guidance explicitly during closure.
- Treat integration as already authorized but still post-gated: archive and audit first, then perform a read-only overlap audit of the dirty primary checkout and integrate only reviewed commits, without push, reset, stash, blanket copy, or worktree removal.
- Translate the two older applied Replans once as representation-only migration while preserving their IDs, timestamps, task hashes, decisions, and dispositions; they are immutable again afterward.

## Impact

- Proposal, design, delta spec, task paths, project OpenSpec records, Skills, source documentation, package tests, and release evidence change to the English-only 0.7.2 contract.
- Task `1.4` is added after `1.2`; Task `1.3` now waits for `1.4`. Tasks `2.2`, `3.1`, and `4.2` gain knowledge, language/package, durable-spec, and post-task closure requirements. Other task IDs remain stable while file paths follow the canonical identity move.
- Completed Tasks `1.1` and `1.2` remain checked and are not reopened.
- Resume from Task `1.4`.

## Old Task Disposition

| Task | Previous state | Disposition | Reason |
|---|---|---|---|
| 1.1, 1.2 | done | preserved | Initialization and the immutable 0.7.1 snapshot remain valid evidence |
| 1.3 | pending | modified in place | Review must inspect the fixed 0.7.2 snapshot, not 0.7.1 |
| 1.4 | absent | added | English-only source/package/release is a distinct prerequisite |
| 2.2 | pending | modified in place | Dogfooding knowledge and explicit promotion are now required |
| 3.1 | pending | modified in place | Distributed package and language gates target 0.7.2 |
| 4.2 | pending | modified in place | Durable target is `hardness/core`; archive audit precedes authorized integration |
| 2.1, 2.3, 2.4, 3.2, 4.1 | pending | preserved | Their implementation and verification boundaries remain valid; paths follow the identity move |

## Diff Snapshot

```text
paths/status: 85 entries captured at the user trigger; 91 entries at application in the isolated Goal worktree
diff stat at application: 56 tracked parent paths, +681/-7102; active openspec change tree remains untracked at the base commit
tasks: +1.4; ~1.3 ~2.2 ~3.1 ~4.2; completed 1.1/1.2 preserved; other task paths follow the canonical move
edges: +1.2->1.4 +1.4->1.3 -1.2->1.3
artifacts: ~proposal ~design ~delta-spec ~tasks ~INDEX ~OpenSpec package/tests/docs; +Hardness knowledge; ~change identity via CLI
```

## Preserved Work

The two earlier Replans, 0.7.0/0.7.1 tags, Rust fixes and tests, package Review, Workspace/Hardness/UE work, Task IDs, and all resolved implementation evidence remain valid. The identity move preserved the change UID and alias. All affected text is recoverable from Git, fixed snapshots, or the worktree, so no patch sidecar was created.

## References and Result

- `attachments/replans/replan-20260902-185805-add-risk-review-gates.md`
- `attachments/replans/replan-20260902-202922-republish-openspec-and-repair-gates.md`
- `attachments/knowledges/dogfooding.md`
- `attachments/knowledges/harness-evolution.md`
- `design.md` Decisions 8–11
- Pre-write self-monitor: canonical UID and alias matched; the candidate Task DAG had 12 nodes, 2 complete, 10 remaining, Ready nodes `1.4` and `2.1`, no task issues, and strict validation passed `1/1`.
- Result: `tasks.md` SHA-256 is `37d8cac0d3ed5e10a57295963362d6bdb4815807473f036fd59ea22999ccabba`; resume Task `1.4`. Post-write checks must confirm the same hash, DAG, INDEX link, canonical identity, English gate, and strict validation before any task advances.
