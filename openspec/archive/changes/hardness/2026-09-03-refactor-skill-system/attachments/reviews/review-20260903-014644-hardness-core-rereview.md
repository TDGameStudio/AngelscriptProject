---
state: closed
review_result: approve
reviewed_at: 2026-09-03T01:59:20.6165181+08:00
closed_at: 2026-09-03T01:59:20.6165181+08:00
review_scope: Hardness routing, Goal/Current workspace authority, Workspace lifecycle boundary, Task Graph and Review/closure protocols, OpenSpec installation identity, and retained Hardness performance evidence
snapshot:
  parent_head: 4129487f63fab930800a896ae7f932d7bd4e6e70
  tools_openspec_commit: 1930040ab18acba43d44fcd635d2a91a701f04ce
  tools_openspec_tag: v0.8.1
  tools_openspec_tag_object: cd643b0bb1e12e09f32012bb2364f37e3f43db88
  scope_file_count: 93
  scope_manifest_sha256: 5e82b4ac75b546e635d651ddaf7a1f5df058ca44533d9fddcf58f4cafc6286a7
  scope_manifest_algorithm: "sorted ordinal UTF-8(relative-path + NUL + lowercase-file-sha256 + LF)"
  tasks_sha256: 413132d572fdfccaae66707e6737ade4fd27c5f3d08c082b3e87a3c97677c36c
  prior_core_review_sha256: 5a8f6d493ec91835d0f2a9cb30d576cd7630c883979050ae2d7423e52e048994
  repair_record_sha256: caf2fa2cf89af333e8817651f883a30fb0d82f0891bb326cb081911c63ffc05a
  hardness_module_sha256: 1ebdb251d5b10df1062558edbcd50fa9ade59d3aa1e1fab6f4d9cc9e3e5632e1
  workspace_module_sha256: 1c9c86a0a41975c63414825d931a19eedb7c9afc0f92d248b56e6e4752794db5
  protocol_tests_sha256: 7e24acb12899a3e8fc9031980b1d59ea9ec0c45fb7ffa9b914bbdfe672b60b1e
  performance_leaf_sha256: 7d342727cbe484f44ac210a6b5f387e6319fcc22ac131e26c2ab5f00be0a12b7
  performance_baseline_sha256: 7a59c05d964dc4e7f2732219d4245f587d81e636ffd8fe4bb517aff13e78efd5
  openspec_manifest_sha256: 87f5379473f6e34bece95e6774a559bc6c197d755354e611c9fac55cfe75788f
  openspec_exe_sha256: 0c19e657120075679e12db22e5ec6b1368c245021f089043008dfd318f43a658
verdict: APPROVE
---

# Hardness Core Fixed-Snapshot Re-review

The repaired Hardness core is approved for Task `2.4`. All four Required findings from `review-20260903-012643-hardness-core-fixed-snapshot.md` are resolved on the fixed snapshot, their focused regressions pass in Windows PowerShell 5.1 and PowerShell 7, and no new Critical, Required, or Advisory finding remains in the reviewed scope.

The repository currently disables Skill invocation while the Skill system is being refactored, so this independent review applied the same correctness, readability, architecture, security, performance, and verification dimensions directly rather than invoking a Skill workflow. The review created only this assigned file.

The deterministic 93-file manifest covers every regular file below `.agents/skills/hardness/**` and `.agents/skills/git-workflow/**`; the packaged OpenSpec EXE, release manifest, command-document tree, and package-safety verifier; and every pre-existing file in the current change record. It excludes this review output itself. It also excludes stash object `a5c22b287fff34e9af1bf07e1d28c73e97862a31`, `.agents/skills/unreal-engine-develop/**`, public UE wrappers and guides, and every UE, Editor, Automation, All, and StaticJIT execution path. The stash was not applied or inspected.

## Verification Story

- `Hardness.Tests.ps1` passed in Windows PowerShell 5.1 and PowerShell 7. The rerun covered canonical Goal selection, linked-worktree origin, traversal and arbitrary-root refusal, create-then-route agreement, registered-worktree enforcement before PowerShell/native leaf loading, Task Graph routing, package corruption fixtures, and persistent-session result behavior.
- `Protocol.Tests.ps1` passed in both hosts. The scanner accepted the actual mixed historical/current review formats, rejected the negative open-review and open-Required fixtures, and validated the current Task Graph/Replan records.
- `Test-Hardness.Tests.ps1` passed in both hosts. Its controlled hang-tree fixture failed within the bounded timeout, retained atomic failure evidence, confirmed direct-child and descendant termination, and left no owned process alive. Its two-pipe flood fixture completed successfully with concurrent stdout/stderr draining.
- The packaged executable reports `openspec 0.8.1`, exits zero, is 2,970,112 bytes, and hashes to `0c19e657120075679e12db22e5ec6b1368c245021f089043008dfd318f43a658`. The manifest binds source commit `1930040ab18acba43d44fcd635d2a91a701f04ce`, annotated tag object `cd643b0bb1e12e09f32012bb2364f37e3f43db88`, the same executable identity, and the release gates.
- The exact 32-file command-document set hashes to `85e8399a09ae013c365dd3b1652ae633ed127e983fd4e4466a5f7b143331a825`, matching the release manifest and Hardness final identity.
- The accepted formal `3/15` baseline is byte-bound to the current Hardness module, gate runner, and performance leaf. Both retained raw `Summary.json` files and both `Samples.csv` files match their aggregate hashes; every host/scenario has 3 warmups, 15 correct measurements, an identical recorded P95, and `BudgetStatus: Passed`. The aggregate contains no project absolute path, username, computer name, or user-profile path.
- The previously supplied exact Quick `10/10` and formal Performance `2/2` gates were not needlessly repeated. This re-review independently reran the focused boundaries above and revalidated the formal source/raw evidence instead.

## Prior Finding Dispositions

### Prior item 1 — Goal authority before leaf loading

**Resolved and independently confirmed.** `New-HardnessContext` derives Goal candidates from the primary registered checkout's `.worktrees` container, validates the safe direct-child name/root relationship, and keeps creation candidates distinct from executable Goal contexts. `Invoke-Hardness` rechecks physical path safety, existing registration, and exact worktree top-level identity before importing a Workspace module or starting the native OpenSpec leaf. Only `workspace.new` may operate on a not-yet-created canonical candidate.

The two-host fixtures reject traversal, path separators, arbitrary explicit roots, missing candidates, and an unregistered directory containing both a malicious import sentinel and fake executable. They also start from a linked worktree, create through that context, and prove the later route resolves to the identical canonical root. This closes the prior correctness, security, and architecture boundary.

### Prior item 2 — Fail-closed OpenSpec installation identity

**Resolved and independently confirmed.** Installation health no longer treats file existence as validity. It first applies bounded physical-containment and reparse checks, parses an exact manifest schema, binds every final 0.8.1 release field and successful release gate, verifies executable size/hash, verifies the exact Markdown-only command-document count/digest, and only then executes the already hash-approved binary for the exact version response.

The two-host fixtures accept the real 0.8.1 package and reject corrupt EXE bytes, wrong manifest hash, wrong version, missing or malformed manifest, missing docs, changed docs, and wrong manifest doc digest. Static mismatch checks occur before unapproved bytes can execute. The independent OpenSpec fixed-snapshot approval remains bound by SHA-256 `0cfc4114fcf0611129b8e40ec4589bf88ba089b37a99af2b8eeaed4eca4a2155`.

### Prior item 3 — Review and closure state consistency

**Resolved and independently confirmed.** Before this assigned output, the actual review tree contained nine files: two `closed` and seven `superseded`. Across those files, all 44 Critical/Required findings have `resolved` status; none is `open` or `deferred`. Historical REQUEST_CHANGES verdicts remain intact, while their appended coordinator dispositions provide the later release, repaired core, or explicit scope-removal evidence.

The mixed UE review does not approve its stashed prototype. Its findings are resolved only for this delivery because every affected code/wrapper path is absent and the exact recovery object plus named follow-up are preserved. The closure scanner reads both fenced and historical indented finding metadata, enforces `closed | superseded`, rejects open/deferred Critical/Required findings, and requires a concrete follow-up for deferred Advisory findings. Positive and negative fixtures plus the actual-tree scan pass in both hosts.

### Prior item 4 — Bounded fresh-process performance gate

**Resolved and independently confirmed.** Fresh samples use a dedicated wall-clock timeout, start both asynchronous redirected readers before waiting, terminate the owned process tree through `Process.Kill(true)` or the bounded Windows `taskkill /T /F` fallback, wait for stream closure, record deterministic failure metadata, and dispose the process. The p95 budget remains a separate performance threshold rather than the process liveness mechanism.

The PS5/PS7 hang-tree fixtures prove bounded failure evidence, process-tree exit, completed output drains, and no orphan direct child or descendant. The flood fixtures prove both redirected pipes are consumed concurrently. The accepted formal baseline is rebound to the timeout-capable leaf and retains correct, under-budget results for both hosts without deleting or overwriting prior runs.

## Review Dimensions

- **Correctness:** Goal/Current selection, task routing, package identity, review state, and retained evidence agree across implementation, tests, tasks, INDEX, repair record, and delta spec.
- **Readability:** The repaired boundaries are named and localized: repository authority, Goal selection, Goal route authority, package schema/final identity, process-tree termination, and review closure scanning each have one focused implementation.
- **Architecture:** Hardness remains a static router; Workspace owns Git lifecycle; OpenSpec remains the deterministic parser/native leaf; Review and Replan remain record protocols. No UE placeholder route, daemon, scheduler database, duplicate Task DAG, or hidden merge/push/remove behavior entered this snapshot.
- **Security:** Unregistered Goal roots cannot load code, OpenSpec health validates static identity before execution, package paths reject links/reparse escapes, and timeout cleanup owns only its launched process tree.
- **Performance:** The persistent lookup remains O(1) through the route dictionary, the accepted two-host baseline is source/raw bound, and the fresh-process gate itself is now bounded under hangs and pipe pressure.
- **Verification:** Focused two-host regressions directly exercise every prior Required finding. The formal baseline and independent 0.8.1 approval remain byte-verifiable. No excluded UE test is needed to approve this core-only gate.

## Decision

**APPROVE.** Close this review. Task `2.4` may be marked complete and the coordinator may proceed to Task `3.2`. This approval does not authorize applying the deferred UE stash, publishing UE routes, merging/pushing/removing a worktree, or creating additional parent-history snapshots of `openspec.exe`. The current final validated 0.8.1 executable should enter parent history only once at the planned final package commit.
