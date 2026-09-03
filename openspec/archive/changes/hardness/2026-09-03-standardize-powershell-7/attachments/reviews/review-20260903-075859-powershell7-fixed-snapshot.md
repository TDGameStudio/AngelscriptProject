---
state: closed
review_result: approve
reviewed_at: 2026-09-03T07:58:59.4474719+08:00
closed_at: 2026-09-03T07:58:59.4474719+08:00
review_scope: PowerShell 7-only Hardness policy, executable gate surface, retained acceptance evidence, historical archive immutability, and excluded package and Unreal boundaries
snapshot:
  parent_commit: 3867512b1dd7cd57c0d0b06f26d5d57de1949733
  reviewed_commit: c1a5876cff32c1c7b537033dfc9fea207f8a985f
  reviewed_tree: bb29698dc2b99ffae6fb7c6fa734be5335a3206f
  policy_baseline_commit: 4b2e1aa96dcbd7f351627f2ef0968ce36909d562
  policy_change_file_count: 19
  snapshot_commit_file_count: 3
  performance_aggregate_sha256: de720d6a0601a898761aed8ad0494d97e16ae97a348680987b39d10121d84333
  ps7_raw_summary_sha256: 5bc29931d79667b7ad6c66b91a3bb6c279b6a8a270cc53c6f02354b138fa2df5
  ps7_raw_samples_sha256: 9c706f406311cc10cdfaae6fc4d3241b92b6c5d490d795f7e6103ce6e21dffa5
  original_archive_tree: e9844db969acc23a116a2e602a414047da4e75d3
  repair_archive_tree: f531c46a8a70ae2f110c5f682ca2816bb3ae36a9
  unreal_engine_develop_tree: 6ea18a16d554bbbd75c8bbb982323e945911a62c
  openspec_exe_sha256: 0c19e657120075679e12db22e5ec6b1368c245021f089043008dfd318f43a658
  tools_openspec_commit: 1930040ab18acba43d44fcd635d2a91a701f04ce
verdict: APPROVE
---

# PowerShell 7-only Hardness Fixed-snapshot Review

Commit `c1a5876cff32c1c7b537033dfc9fea207f8a985f` is approved as the fixed review snapshot for the PowerShell 7-only Hardness change. The supported gate surface now has one host, one naming convention, and one performance series: `pwsh.exe`, `*.PS7`, and PowerShell `7.0` or later with the `Core` edition. No Critical, Required, or Advisory finding was identified.

The implementation is commit `3867512b1dd7cd57c0d0b06f26d5d57de1949733`; its child `c1a5876cff32c1c7b537033dfc9fea207f8a985f` adds only the accepted evidence and marks the evidence task complete. This review is bound to the committed tree above. The review file itself is the sole review output and is not part of the reviewed snapshot.

## Snapshot and Change Integrity

- The reviewed commit has the stated implementation commit as its direct parent and resolves to tree `bb29698dc2b99ffae6fb7c6fa734be5335a3206f`.
- The evidence commit changes exactly three paths: the attachment index, the accepted aggregate JSON, and `tasks.md`. The complete PowerShell 7 policy span from `4b2e1aa96dcbd7f351627f2ef0968ce36909d562` changes nineteen paths.
- `git diff --check 4b2e1aa9 c1a5876c` passed, and the worktree was clean before this review file was created.
- The current delta specification and durable `hardness/core` specification agree on the single-host performance profile, PowerShell `7.0`/`Core` minimum, and absence of a PS5 or multi-host gate selector.

## Supported PowerShell Surface

- `Test-Hardness.ps1` has `#requires -Version 7.0`, exposes no `PowerShellHosts` parameter, resolves only `pwsh.exe`, and constructs only a `PS7` host entry.
- Listing the actual profiles returned five Quick checks, one Performance check, and ten Integration checks. Every Script or Performance entry resolves to `C:\Program Files\PowerShell\7\pwsh.exe`; every host-qualified name ends in `.PS7`.
- The Quick entries are `Hardness.PS7`, `HardnessGateContract.PS7`, `Protocol.PS7`, `Workspace.PS7`, and `OpenSpecSkill.PS7`. Performance contains only `HardnessPerformance.PS7`; Integration adds the four host-local Hardness/OpenSpec route checks.
- No executable `powershell.exe`, `.PS5` entry, `WindowsPowerShell` route, or public multi-host selector remains in the maintained Hardness or Workspace script surface. Remaining PS5 text is limited to negative assertions, unsupported-policy statements, and immutable historical evidence.
- Both public module manifests declare `PowerShellVersion = '7.0'` and `CompatiblePSEditions = @('Core')`. `Test-ModuleManifest` accepted both manifests in PowerShell Core `7.6.0`.
- The private performance leaf also has `#requires -Version 7.0` and launches fresh samples through the current process executable, so a supported invocation remains within the same PowerShell 7 host instead of rediscovering Windows PowerShell.

## Correctness, Architecture, Safety, and Readability

- Removing the selector is an intentional support-boundary break: callers cannot silently request `Both` or `WindowsPowerShell`; unsupported arguments fail parameter binding instead of partially running an obsolete matrix.
- The runner retains one common check/result envelope and changes only host expansion. Route checks continue in the already-supported Core session, while Script and Performance checks use explicit child `pwsh.exe` processes.
- The performance implementation still validates behavior for every timed sample, keeps setup outside the TaskStatus stopwatch, uses the hermetic Task Graph by default, and forwards an explicit TaskChange only when supplied.
- Process timeout, concurrent stdout/stderr draining, owned-tree termination, atomic evidence writes, duplicate-run refusal, and verified temporary-fixture cleanup remain intact. The PS7-only change removes only Desktop-specific `-ExecutionPolicy Bypass` branches; generic Windows `taskkill /T` fallback safety remains.
- The targeted contract test left no recent `hardness-performance-contract-*` or `hardness-performance-task-*` directory in the system temporary directory.
- Documentation, examples, Task DAG verification text, capability knowledge, and the active change all use the same `pwsh.exe` and PowerShell 7/Core vocabulary. Historical PS5 data is explicitly described as evidence rather than current support.

## Retained Evidence Audit

The accepted aggregate
`attachments/data/hardness-performance-powershell7-20260903-075347.json` independently hashes to:

```text
de720d6a0601a898761aed8ad0494d97e16ae97a348680987b39d10121d84333
```

Both ignored raw artifacts exist and match the aggregate byte-for-byte:

```text
Summary.json  5bc29931d79667b7ad6c66b91a3bb6c279b6a8a270cc53c6f02354b138fa2df5
Samples.csv   9c706f406311cc10cdfaae6fc4d3241b92b6c5d490d795f7e6103ce6e21dffa5
```

All six registered source hashes also match the reviewed files:

```text
Hardness.psm1                    1ebdb251d5b10df1062558edbcd50fa9ade59d3aa1e1fab6f4d9cc9e3e5632e1
Hardness.psd1                    bc5e7444f071ed65db5b281c1d76063d1e44cfbade389b3e1ab9a166ba6a7b20
Workspace.psd1                   bc886fe7f1d00e7c677f4dc9a3fee6ed2a3775b85d01d30848a0ac732b3a301a
Test-Hardness.ps1                f24ee7c0ab13d305720102d10c1dd9439125d1a14975fb60974e2e28ef063822
Hardness.Performance.Tests.ps1   97ff3cf520b42f131f55b0ecc2ea2fa72e6b4076b9ed2879caa073f12f8783ba
Test-Hardness.Tests.ps1          f0dfd7e41e925eb6ac8656020cc1cf14acde9c77781d5c4cc48992067ec9ccb0
```

The aggregate contains none of the current username, machine name, user-profile path, or absolute project path. It retains scenario aggregates and source/raw hashes without embedding the per-sample table.

## Sample and Duration Verification

- The raw run identifies Core PowerShell `7.6.0` x64, RunId `powershell7-20260903T075200-PS7`, three warmups, and fifteen measurements per scenario.
- The CSV has exactly 54 rows: nine warmups plus forty-five measurements across FreshProcess, PersistentApi, and TaskStatus. All 54 behavior flags are correct.
- Min, median, nearest-rank p95, and max were independently recomputed from each scenario's fifteen measurement rows. Every value matches both the raw summary and the trimmed aggregate:

```text
FreshProcess  391.4106 / 404.5099 / 448.3612 / 448.3612 ms
PersistentApi 56.6210  / 60.4555  / 66.6766  / 66.6766  us/op
TaskStatus    39.6890  / 44.0945  / 55.4976  / 55.4976  ms
```

- All three p95 catastrophe budgets pass. The numbers are retained observations rather than portable regression thresholds; the TaskStatus series remains `hermetic-task-status-v1`.
- The ten recorded Integration check durations sum exactly to `77,992 ms` (`77.992 s`). The five Quick scripts sum to `66,949 ms` (`66.949 s`), including `40,770 ms` for Workspace; Performance contributes `10,373 ms`, and the four route checks contribute `670 ms`.
- These are the sum of runner-reported per-check stopwatches, not an external wall-clock duration. The arithmetic and labeling are correct; the review does not reinterpret them as deterministic performance guarantees.

## Historical and Excluded Boundaries

- The original delivery archive tree is `e9844db969acc23a116a2e602a414047da4e75d3` both before and after this change.
- The post-archive repair tree is `f531c46a8a70ae2f110c5f682ca2816bb3ae36a9` both before and after this change. No archived path appears in the nineteen-file policy diff.
- `.agents/skills/unreal-engine-develop` remains the identical tree `6ea18a16d554bbbd75c8bbb982323e945911a62c`; no UE implementation or test command was included.
- `.agents/skills/openspec/bin/openspec.exe` remains 2,970,112 bytes with SHA-256 `0c19e657120075679e12db22e5ec6b1368c245021f089043008dfd318f43a658`.
- `Tools/openspec` remains gitlink `1930040ab18acba43d44fcd635d2a91a701f04ce`. Neither the executable path nor the gitlink has a commit in `4b2e1aa9..c1a5876c`.

## Independent Validation

The permitted PowerShell 7 contract test passed:

```text
pwsh.exe -NoProfile -File .agents/skills/hardness/tests/Test-Hardness.Tests.ps1
Test-Hardness.Tests.ps1: PASS
```

This targeted test checks the profile matrix, executable identity, manifest contract, hermetic performance fixture, atomic evidence behavior, timeout/process-tree cleanup, and flooded-pipe handling. It is not the full Quick, Integration, or Performance profile.

Strict OpenSpec validation also passed:

```text
openspec.exe validate hardness/standardize-powershell-7 --strict --json
1 passed, 0 failed, 0 issues

openspec.exe validate --specs --strict --json
2 passed, 0 failed, 0 issues
```

No Windows PowerShell 5.1, full Quick, full Integration, full Performance, Unreal Engine, Automation, Standalone, or StaticJIT gate was run during this review.

## Findings and Resolutions

- Critical findings: none.
- Required findings: none.
- Advisory findings: none.
- Resolutions required before closure: none.

## Decision

**APPROVE.** This independent review is `closed`. The fixed snapshot correctly makes PowerShell 7/Core the only supported Hardness/Workspace host, preserves the immutable historical records and package boundaries, and retains internally consistent, source-bound PS7 evidence. Closure may now index this review, synchronize the already-valid durable specification state, archive through the OpenSpec CLI, and run the prescribed PS7-only post-move gate. This approval does not authorize modifying either historical archive, recommitting the OpenSpec executable or gitlink, running excluded UE gates, pushing, or removing a worktree.
