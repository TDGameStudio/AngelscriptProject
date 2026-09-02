---
state: superseded
review_result: request_changes
reviewed_at: 2026-09-03T01:26:43.3645209+08:00
superseded_at: 2026-09-03T01:46:44.9970901+08:00
superseded_by: review-20260903-014644-hardness-core-rereview.md
review_scope: Hardness router, Goal/Current workspace authority, Workspace lifecycle, Task DAG, Review/Replan/closure protocols, and retained Hardness performance evidence; deferred Unreal WIP and UE validation are excluded
snapshot:
  parent_head: 4129487f63fab930800a896ae7f932d7bd4e6e70
  scope_file_count: 36
  scope_manifest_sha256: 82cb1dcbb2c0fe3f6f76b7ac9033cdf49264285b5c64b6bb7cd3976b62fc9c18
  tasks_sha256: 413132d572fdfccaae66707e6737ade4fd27c5f3d08c082b3e87a3c97677c36c
  hardness_module_sha256: 948e8095af5fd2a1afab9f8697d7aedfbd3221e10ea39d20ead0522e40b54604
  workspace_module_sha256: 1c9c86a0a41975c63414825d931a19eedb7c9afc0f92d248b56e6e4752794db5
  performance_baseline_bytes: 3683
  performance_baseline_source_bound: true
  performance_raw_artifacts_bound: true
verdict: REQUEST_CHANGES
---

# Hardness Core Fixed-Snapshot Review

The reviewed core has a coherent small-router architecture, a strong Workspace safety implementation, a single frontmatter Task DAG, and reproducibly bound two-host performance evidence. The supplied Quick `10/10` and Performance `2/2` evidence, the independent OpenSpec 0.8.1 `APPROVE`, and strict OpenSpec validation are credible for their tested paths. Four Required boundary defects remain, however, so this review cannot close Task 2.4 yet.

The review intentionally excludes stash object `a5c22b287fff34e9af1bf07e1d28c73e97862a31`, every path under `.agents/skills/unreal-engine-develop/**`, public UE wrappers, Unreal build/test scripts, and all Editor, Automation, Smoke, Standalone, complete All, and StaticJIT All execution. The stash was not applied or inspected.

## Snapshot and Method

- The fixed snapshot is parent HEAD `4129487f63fab930800a896ae7f932d7bd4e6e70` plus the current 36-file allowed scope. Its deterministic sorted path/file-hash manifest is `82cb1dcbb2c0fe3f6f76b7ac9033cdf49264285b5c64b6bb7cd3976b62fc9c18`.
- Tests were read before production scripts. The review covered correctness, readability, architecture, security, performance, and whether verification proves the promised boundaries.
- A lightweight rerun of `Test-Hardness.Tests.ps1` passed. Packaged `openspec.exe validate hardness/refactor-skill-system --strict --json` passed with `1/1` valid.
- The 3,683-byte retained baseline exactly matches all three current source hashes. Both PS5 and PS7 raw `Summary.json` and `Samples.csv` files exist and exactly match the four retained SHA-256 values. The trimmed baseline contains no username, computer name, user profile, or absolute Windows path.
- Parent history shows one prior checkpoint containing the packaged EXE and one current working-tree replacement; no candidate EXE commit series was found. This is consistent with the stated single-final-snapshot parent policy, provided the current replacement is committed only once after gates close.

## Findings

### Finding 1 — Goal context can escape the canonical workspace and select executable leaf code from an unverified root

```yaml
severity: Required
status: resolved
dimension: correctness/security/architecture
files:
  - .agents/skills/hardness/scripts/Hardness.psm1:199
  - .agents/skills/hardness/scripts/Hardness.psm1:212
  - .agents/skills/hardness/scripts/Hardness.psm1:291
  - .agents/skills/hardness/scripts/Hardness.psm1:297
  - .agents/skills/hardness/scripts/Hardness.psm1:304
```

**Observation.** `New-HardnessContext` validates neither `GoalName` nor `WorkspaceRoot`. A Goal name is joined directly below the supplied root, and an explicit workspace root is accepted verbatim after `GetFullPath`. `Invoke-Hardness` then treats that path as authoritative for every Goal route except `workspace.new`, including importing its `Workspace.psd1` and executing its `openspec.exe`. The Workspace module itself has strong canonical/registered-worktree checks for destructive lifecycle operations, but the Hardness routing boundary runs before those checks and applies to native and status routes as well.

**Impact.** Goal/Current authority is not actually bound to `.worktrees/<goal>` or to a registered workspace. A malformed derived name can route to the wrong sibling; an explicit outside path can make Hardness load and execute leaf code outside the selected project. Starting from a linked worktree also derives a nested `<linked-worktree>/.worktrees/<goal>` context even though `workspace.new` canonicalizes creation to the primary checkout's `.worktrees`, so creation and subsequent routing can disagree.

**Reproduction/evidence.** On the fixed snapshot:

```powershell
Import-Module ./.agents/skills/hardness/scripts/Hardness.psd1 -Force
New-HardnessContext -Mode Goal -ProjectRoot $PWD -GoalName ok -WorkspaceRoot D:\outside-explicit
```

returns `WorkspaceRoot = D:\outside-explicit`. A traversal probe likewise returned a normalized sibling path rather than rejecting the name. Lines 291-305 then use that selected root to locate and import/execute the leaf.

**Resolution condition.** Validate `GoalName` with the same safe-name contract as workspace creation; derive the canonical primary `.worktrees` container even when the caller starts in a linked worktree; and distinguish a not-yet-created canonical candidate used only by `workspace.new` from an existing Goal context, which must be physically safe and a registered worktree before any other route loads a module or executable. Add PS5/PS7 regressions for traversal, arbitrary explicit roots, linked-worktree origin, create-then-route agreement, and refusal before leaf execution.

### Finding 2 — Installation health reports an unverified OpenSpec leaf as valid

```yaml
severity: Required
status: resolved
dimension: correctness/security/verification
files:
  - .agents/skills/hardness/scripts/Hardness.psm1:358
  - .agents/skills/hardness/scripts/Hardness.psm1:373
  - .agents/skills/hardness/tests/Hardness.Tests.ps1:238
  - openspec/changes/hardness/refactor-skill-system/specs/hardness/core/spec.md:79
```

**Observation.** `Test-HardnessInstallation` validates the Workspace module manifest but checks OpenSpec only with `Test-Path -PathType Leaf`. It does not bind the executable to `release-manifest.json`, verify its SHA-256/version, verify the command-document digest, or call the already available package verifier. The Hardness test proves only the missing-file case and a valid real package; it has no corrupt or mismatched leaf fixture.

**Impact.** A zero-byte, stale, substituted, or mismatched executable is reported as an installed required leaf and all OpenSpec/task routes remain advertised. This contradicts the fixed-snapshot rule that route/health expose only a verified leaf and weakens the deterministic-package scenario even though the separate package test correctly verifies the real 0.8.1 package.

**Reproduction/evidence.** In the production branch at lines 373-383, the sole OpenSpec leaf has `Module = $false`; therefore the only success predicate is that a file exists. No release-manifest path or OpenSpec invocation occurs anywhere in `Test-HardnessInstallation`. Replacing that file in an isolated installation fixture with arbitrary bytes would leave this health branch error-free.

**Resolution condition.** Make installation health verify the packaged release identity through one bounded canonical verifier: at minimum manifest schema, EXE SHA-256 and version, required command-doc set/digest, and expected final release identity. Fail closed without executing a mismatched binary. Add PS5/PS7 fixtures for corrupt bytes, wrong version/hash, missing/mismatched manifest/docs, and the valid 0.8.1 package; ensure routes are not reported healthy when the leaf is invalid.

### Finding 3 — Review state contradicts Task 1.3, INDEX, and the archive closure policy

```yaml
severity: Required
status: resolved
dimension: correctness/process-state/verification
files:
  - openspec/changes/hardness/refactor-skill-system/tasks.md:44
  - openspec/changes/hardness/refactor-skill-system/attachments/INDEX.md:5
  - openspec/changes/hardness/refactor-skill-system/attachments/reviews/review-20260902-194012-openspec-07-package.md:2
  - openspec/changes/hardness/refactor-skill-system/attachments/reviews/review-20260902-openspec-072-rereview.md:2
  - openspec/changes/hardness/refactor-skill-system/attachments/reviews/review-20260902-233151-openspec-080.md:2
  - openspec/changes/hardness/refactor-skill-system/attachments/reviews/review-20260902-harness-ue-final.md:2
  - openspec/changes/hardness/refactor-skill-system/specs/hardness/core/spec.md:73
```

**Observation.** Task 1.3 is checked complete and its fourth step says all OpenSpec release reviews are closed or superseded. INDEX calls the 0.8.0 REQUEST_CHANGES evidence superseded. The actual 0.7.0, 0.7.2, and 0.8.0 review frontmatter still says `state: open`; the 0.8.0 findings also remain `status: open`. Separately, the mixed UE review is `state: superseded` but retains open Critical/Required findings by design. The current spec and closure reference state that every review must be closed/superseded and no Critical/Required finding may remain open or deferred, without exempting findings inside a superseded, scope-extracted review.

**Impact.** `tasks.md`, INDEX, review files, and the normative closure rule describe different states. Task 1.3's completion evidence is false on disk, and Task 4.2 cannot satisfy the literal completed-archive rule while preserving the intentionally unresolved UE findings for the future change. Strict OpenSpec validation passed because it does not validate this review-state contract, so that pass does not close the gap.

**Reproduction/evidence.** This read-only query returns three open OpenSpec review files and open findings in the superseded mixed review:

```powershell
rg -n -g '*.md' '^(state|status|verdict|review_result):' `
  openspec/changes/hardness/refactor-skill-system/attachments/reviews
```

The 0.8.1 fixed-snapshot review is independently closed/APPROVE; the defect is the unresolved historical-state disposition, not the 0.8.1 technical result.

**Resolution condition.** Reconcile the state model without rewriting finding history: append evidence-backed dispositions and update historical review frontmatter to `closed` or `superseded` where the review protocol permits it; make INDEX/task claims match the actual files; and explicitly define whether findings in a superseded scope are excluded from current closure or must receive a non-gating transferred disposition with a named follow-up. Add a protocol/closure test that scans every review file and enforces the chosen rule before completed archive.

### Finding 4 — The performance gate has no timeout, so its catastrophe budget cannot catch a hung fresh process

```yaml
severity: Required
status: resolved
dimension: performance/reliability
files:
  - .agents/skills/hardness/tests/Hardness.Performance.Tests.ps1:108
  - .agents/skills/hardness/tests/Hardness.Performance.Tests.ps1:136
  - .agents/skills/hardness/tests/Hardness.Performance.Tests.ps1:141
  - .agents/skills/hardness/tests/Hardness.Performance.Tests.ps1:143
  - .agents/skills/hardness/tests/Test-Hardness.Tests.ps1:68
  - openspec/changes/hardness/refactor-skill-system/design.md:86
```

**Observation.** The fresh-process sample synchronously drains stdout, then stderr, then calls unbounded `WaitForExit()`. There is no wall-clock timeout, cancellation, or child termination path. The p95 budget is evaluated only after every sample returns. The runner contract test exercises one successful minimal sample but has no deliberately hung child fixture.

**Impact.** The stated broad catastrophe budget cannot detect the most important catastrophe: an import/API process that never exits. One hung sample blocks the Performance and Integration profiles indefinitely and prevents atomic evidence completion. Sequential stdout/stderr draining also retains the standard redirected-pipe deadlock risk if a failing child emits enough data on the pipe not being read.

**Reproduction/evidence.** Lines 141-143 perform blocking `ReadToEnd()` calls and `WaitForExit()` with no timeout overload. A child that sleeps indefinitely or fills stderr before closing stdout never reaches the p95 calculation at lines 264-269.

**Resolution condition.** Add a bounded per-sample process timeout derived independently from the p95 measurement budget, drain both redirected streams without the sequential deadlock pattern, kill the owned child tree on timeout where supported, dispose it, and report a deterministic failed correctness sample without deleting prior runs. Add PS5/PS7 tests with a controlled hung/flooding child proving bounded failure and no orphan process, while retaining the successful 3/15 two-host baseline behavior.

## Review Dimensions

- **Correctness:** Task Graph parsing/Ready derivation and the normal Current/Goal fixture paths are well tested. The unchecked Goal root and contradictory review state remain correctness blockers.
- **Readability:** The short entry Skills and focused references are substantially clearer than the previous overlapping system. Route ownership and finish facts are described consistently; the historical review-state exception is not.
- **Architecture:** Hardness remains a static router, OpenSpec remains the deterministic parser, and Workspace owns Git lifecycle. The unverified root at the routing boundary bypasses that otherwise good separation.
- **Security:** Workspace destructive operations have strong traversal, reparse, registration, exact-gitlink, dirty-data, and ignored-data defenses. Hardness must apply equivalent provenance before importing a leaf from a Goal root, and health must not trust mere EXE existence.
- **Performance:** The retained per-host statistics, source/raw hashes, privacy trimming, unique run IDs, individual atomic writes, and non-overwrite checks are sound. The missing process timeout makes the gate itself unbounded.
- **Verification:** Quick `10/10`, Performance `2/2`, strict validation, the 3,683-byte baseline, and independent OpenSpec approval are useful evidence but do not exercise the four failing boundaries above. No UE test is relevant or requested for these repairs.

## Decision

**REQUEST CHANGES.** Keep this review `open`. Findings 1 through 4 are Required and need focused PS5/PS7 regressions plus a new fixed-snapshot re-review before Task 2.4 can close. These are Hardness/record-layer repairs only; they do not justify applying the deferred UE stash or running UE, All, or StaticJIT validation. This review does not decide whether any finding requires Replan; the coordinator owns that triage under the Review/Replan protocol.

## Coordinator Resolution — 2026-09-03

This REQUEST_CHANGES verdict remains historical and is not converted to APPROVE. The four findings were triaged as implementation/record defects within the existing Task `2.4` gate; no requirement, design boundary, task ownership, dependency edge, or artifact contract changed, so no Replan was triggered.

- Finding 1 is resolved by canonical primary-worktree selection, strict Goal-name/direct-child matching, registered and physical workspace checks before leaf loading, and PS5/PS7 traversal, external-root, linked-origin, create-then-route, and pre-import sentinel regressions. `Hardness.psm1` is bound at `1ebdb251d5b10df1062558edbcd50fa9ade59d3aa1e1fab6f4d9cc9e3e5632e1`.
- Finding 2 is resolved by fail-closed 0.8.1 package identity verification: bounded manifest/schema checks, approved source/tag/EXE identity, executable size/hash, exact command-doc set/digest, and only then `--version`. Corrupt, wrong-version/hash, missing/malformed manifest, and missing/mutated docs fixtures pass in PS5/PS7.
- Finding 3 is resolved by superseding the historical release reviews with evidence-backed finding dispositions, resolving extracted-scope findings for this delivery without approving the stash, correcting the recovery-record/change-manifest states, and adding a mixed-format Review/closure scanner with positive and negative fixtures.
- Finding 4 is resolved by a separate fresh-process timeout, concurrent stdout/stderr drain, owned process-tree termination and disposal, atomic failure evidence, and PS5/PS7 hang-tree/flood regressions. The accepted formal `3/15` rerun is `gate-20260902T174450411Z-f11306fb-{PS5,PS7}` and the source-bound aggregate is `attachments/data/hardness-performance-baseline-20260903-014536.json`.

The assigned independent successor is `review-20260903-014644-hardness-core-rereview.md`. It must verify the repaired fixed snapshot before Task `2.4` can close.
