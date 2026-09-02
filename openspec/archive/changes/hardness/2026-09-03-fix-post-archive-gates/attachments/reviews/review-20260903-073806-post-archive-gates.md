---
state: closed
review_result: approve
reviewed_at: 2026-09-03T07:38:06.7935931+08:00
closed_at: 2026-09-03T07:38:06.7935931+08:00
review_scope: Fixed post-archive Hardness gate repair, retained two-host performance evidence, closure policy, archive immutability, package history, and strict OpenSpec validity
snapshot:
  parent_commit: dec07a6f8e9d9be45da10e7533be8a90889d6378
  reviewed_commit: 6deb443f9f8f08f8fafad28c15506aa4e93e2981
  reviewed_tree: 8485e154c3718aa7543c222a72a77d15a549e7c4
  reviewed_file_count: 14
  original_archive_commit: d0e7d12d6bec72597ea4d361affa7ba2b189d434
  original_archive_tree: e9844db969acc23a116a2e602a414047da4e75d3
  performance_aggregate_sha256: fc2fd5aaaf3b6cf347ca62480906389deb949df268f7adb679b81f5940facba0
  predecessor_aggregate_sha256: 7a59c05d964dc4e7f2732219d4245f587d81e636ffd8fe4bb517aff13e78efd5
  hardness_module_sha256: 1ebdb251d5b10df1062558edbcd50fa9ade59d3aa1e1fab6f4d9cc9e3e5632e1
  gate_runner_sha256: 042697be046e54e93a058946c08b79fb136cd83d12a997a957ecf34f5e2f7801
  performance_leaf_sha256: 4c4a4e6677d694a8b239a0532a3ca5b381d26496937d34510852f8d0c282fec1
  ps5_raw_summary_sha256: 03b4a6d80d070cf226d170248bde7d4d459c6e0e7bead90e8f87906689cf37e0
  ps5_raw_samples_sha256: 336035e4384a7125289e66cb88480258d1f9967a80f3d8823b33e374249c0d8e
  ps7_raw_summary_sha256: 12915e721b3fcb958372a101ee697f59e7557a8df5b3d8999dbf15caebdc90c3
  ps7_raw_samples_sha256: 0c7193a38381beb818ba8c2e1ea072913d7ff859e790ae9bcc0362365fa9e480
  openspec_exe_sha256: 0c19e657120075679e12db22e5ec6b1368c245021f089043008dfd318f43a658
  tools_openspec_commit: 1930040ab18acba43d44fcd635d2a91a701f04ce
verdict: APPROVE
---

# Post-archive Hardness Gates Fixed-snapshot Review

Commit `6deb443f9f8f08f8fafad28c15506aa4e93e2981` is approved for Task `2.1`. The fourteen-file follow-up repairs the active-change coupling exposed only after the original Hardness record was archived, retains source-bound PS5/PS7 performance evidence, and strengthens the closure rule without changing the completed archive, the OpenSpec executable, or the `Tools/openspec` gitlink. No Critical, Required, or Advisory finding was identified.

This review is bound to the committed tree above. The review file itself is the only review output and is not part of the reviewed snapshot.

## Scope and Commit Integrity

- The reviewed commit has parent `dec07a6f8e9d9be45da10e7533be8a90889d6378` and changes exactly fourteen paths: six Hardness implementation/test/doc paths, one OpenSpec archive Skill entry, and seven follow-up OpenSpec record/evidence paths.
- `git show --check 6deb443f` passed. No path under Unreal Engine code, plugin source, `unreal-engine-develop`, the packaged OpenSpec binary, or the OpenSpec source gitlink is part of the commit.
- The original delivery lineage remains intact: `d0e7d12d6bec72597ea4d361affa7ba2b189d434` and all eight Goal commits remain ancestors rather than being squashed or recreated.

## Correctness and PowerShell Compatibility

- The public runner no longer supplies the archived `hardness/refactor-skill-system` ID as its default TaskStatus input. It forwards `-TaskChange` only when the caller provides a nonblank explicit value.
- The performance leaf creates a unique `hardness-performance-task-<guid>` OpenSpec project when no TaskChange is supplied. It uses the accepted packaged executable to initialize one active `fixture/performance` change and writes a real frontmatter Task Graph.
- The timed TaskStatus interval still invokes `Invoke-Hardness -Command 'task.status'`; it therefore retains the real route lookup, native OpenSpec invocation, Task Graph parsing, and result-envelope behavior. EXE copying, project initialization, domain/change creation, `tasks.md` creation, and context construction all happen before the TaskStatus stopwatch starts.
- An explicit TaskChange continues to use the caller's project context and never falls back to either the hermetic fixture or an archived record.
- The changed PowerShell constructs are compatible with Windows PowerShell 5.1 and PowerShell 7. The dual-host Quick run below also exercised both parser/runtime paths.

## Temporary-fixture Safety

- Fixture paths are absolute children of the normalized system temporary directory and use a fixed basename prefix plus a random GUID, avoiding PS5/PS7 concurrency collisions.
- The fixture setup is inside the outer `try`, so ordinary setup, measurement, or assertion failures reach the cleanup `finally` block.
- Before recursive removal, cleanup recomputes the absolute path and requires both the normalized system-temp prefix and the exact `hardness-performance-task-` basename prefix. An unexpected path is rejected instead of removed.
- Explicit TaskChange runs leave the fixture path empty and therefore cannot delete caller-owned project data.
- Independent Quick execution left no recent `hardness-performance-task-*` or `hardness-performance-contract-*` directory behind.

## Performance Evidence Audit

The retained aggregate `attachments/data/hardness-performance-post-archive-20260903-072834.json` hashes to `fc2fd5aaaf3b6cf347ca62480906389deb949df268f7adb679b81f5940facba0`, exactly as registered by the change INDEX.

All three source hashes in that aggregate match the reviewed files byte-for-byte:

```text
Hardness.psm1                   1ebdb251d5b10df1062558edbcd50fa9ade59d3aa1e1fab6f4d9cc9e3e5632e1
Test-Hardness.ps1               042697be046e54e93a058946c08b79fb136cd83d12a997a957ecf34f5e2f7801
Hardness.Performance.Tests.ps1  4c4a4e6677d694a8b239a0532a3ca5b381d26496937d34510852f8d0c282fec1
```

Both retained raw runs exist and their files match the registered hashes:

```text
PS5 Summary.json  03b4a6d80d070cf226d170248bde7d4d459c6e0e7bead90e8f87906689cf37e0
PS5 Samples.csv   336035e4384a7125289e66cb88480258d1f9967a80f3d8823b33e374249c0d8e
PS7 Summary.json  12915e721b3fcb958372a101ee697f59e7557a8df5b3d8999dbf15caebdc90c3
PS7 Samples.csv   0c7193a38381beb818ba8c2e1ea072913d7ff859e790ae9bcc0362365fa9e480
```

- The PS5 raw summary identifies Desktop `5.1.26100.8875` x64; the PS7 summary identifies Core `7.6.0` x64. Their RunIds match their unique raw directories.
- Each host retains 54 correct samples: three warmups plus fifteen measurements for each of FreshProcess, PersistentApi, and TaskStatus. There are zero incorrect samples and all six host/scenario budget results pass.
- Min, median, nearest-rank p95, and max were independently recomputed from each scenario's fifteen measurement rows. Every recomputed value matches the raw summary and trimmed aggregate.
- The aggregate contains no username, computer name, user-profile path, project absolute path, or raw per-sample array.
- The predecessor aggregate remains linked by its verified SHA-256 `7a59c05d964dc4e7f2732219d4245f587d81e636ffd8fe4bb517aff13e78efd5`.

The new TaskStatus values intentionally begin the `hermetic-task-status-v1` series. They are not directly comparable with the predecessor's active-dogfood-change TaskStatus values. FreshProcess and PersistentApi retain their definitions, while every host is still judged only against its own broad absolute budget; no cross-host ranking is performed.

## Archive and Closure Policy

- The complete original archive has tree object `e9844db969acc23a116a2e602a414047da4e75d3` at both the original archive commit and the reviewed commit. `git diff --quiet d0e7d12d 6deb443f -- openspec/archive/changes/hardness/2026-09-03-refactor-skill-system` returned success.
- The protocol gate now intentionally binds the exact immutable archive path for historical Review/Replan audit. It does not make archived tasks schedulable and does not add a competing active/archive resolver.
- The closure reference, archive entry, and delta specification agree on the new invariant: reusable gates use hermetic or stable inputs; accepted aggregate and raw hashes are registered before archive; strict archived validation and the smallest relevant non-destructive lifecycle gate run after the move; a newly exposed problem receives a follow-up record instead of rewriting the archive.
- The follow-up itself preserves the normal lifecycle. Tasks `2.1` and `2.2` remain incomplete at the reviewed commit, so the implementation commit does not manufacture review or archive completion.

## Package-history Audit

- `.agents/skills/openspec/bin/openspec.exe` remains version `0.8.1`, size 2,970,112 bytes, SHA-256 `0c19e657120075679e12db22e5ec6b1368c245021f089043008dfd318f43a658`.
- In `4129487f..6deb443f`, the executable path is touched exactly once, by the existing `408e26d7` release commit.
- `Tools/openspec` remains clean at gitlink `1930040ab18acba43d44fcd635d2a91a701f04ce`. Its path is likewise touched exactly once in that range, by `408e26d7`.
- The follow-up only copies the already accepted EXE into a system-temp fixture at test runtime; it neither rebuilds nor recommits the parent binary.

## Independent Validation

The fixed committed snapshot passed the full non-UE Quick profile in both supported hosts:

```text
Test-Hardness.ps1 -Profile Quick -PowerShellHosts Both -Json
10 passed, 0 failed
```

This includes Hardness, gate-contract, Protocol, Workspace, and OpenSpec package checks in Windows PowerShell 5.1 and PowerShell 7. No UE, Editor, Automation, Smoke, Standalone, complete All, or StaticJIT All command was run.

Strict OpenSpec checks also passed:

```text
openspec.exe validate hardness/fix-post-archive-gates --strict --json
1 passed, 0 failed, 0 issues

openspec.exe validate --archived --strict --json
1 passed, 0 failed, 0 issues
```

The full 3-warmup/15-measurement Performance profile was not repeated during review because the exact retained raw files, hashes, sample counts, statistics, behavior flags, and budgets were independently verified against the committed aggregate.

## Findings

No Critical, Required, or Advisory finding.

## Decision

**APPROVE.** This review is `closed`. Task `2.1` may be completed. Task `2.2` may proceed with durable-spec synchronization, completed closure metadata, CLI archive, strict archived validation, and the required post-move non-destructive gate. This approval does not authorize rewriting the original archive, scheduling archived tasks, changing or recommitting `openspec.exe`, moving the `Tools/openspec` gitlink, running excluded UE gates, pushing, or removing a worktree.
