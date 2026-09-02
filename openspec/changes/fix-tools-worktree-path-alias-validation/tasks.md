# Tasks

Workspace: main checkout `D:\Workspace\AngelscriptProject`, branch `main`. Single repo — `Tools/` is not a submodule, so this is not a dual-repo change.

Verification entry points: `Tools\Diagnostics\tests\RunBuildSelfTests.ps1`, `Tools\Diagnostics\tests\RunTestSuiteSelfTests.ps1`, then one real `Tools\RunBuild.ps1` from each of the two entry names.

## 1. Canonical path helper

- [ ] 1.1 Add `Get-CanonicalPathValue` to `Tools\Shared\UnrealCommandUtils.ps1` <!-- TDD -->
  - Files: `Tools\Shared\UnrealCommandUtils.ps1` (new function next to `Normalize-PathValue`, line ~26)
  - Impact: new helper only; no existing caller changes yet
  - Behavior: `GetFinalPathNameByHandle` via cached `Add-Type`; open with desired access 0 and `FILE_FLAG_BACKUP_SEMANTICS` (`0x02000000`); strip `\\?\`; on any failure return `Normalize-PathValue -Path $Path`
  - Tests: new `Tools\Diagnostics\tests\CanonicalPathSelfTests.ps1` — junction resolves to target; `subst` drive resolves to target; already-canonical path returns unchanged; nonexistent path falls back without throwing
  - Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Diagnostics\tests\CanonicalPathSelfTests.ps1`
  - Requirement: agent-config-worktree-alias / canonical identity

## 2. Accept any name of the same worktree

- [ ] 2.1 Compare project-file identity in `Resolve-AgentConfiguration` <!-- TDD -->
  - Files: `Tools\Shared\UnrealCommandUtils.ps1` lines 932-942
  - Impact: build `$resolvedProjectFileCandidates` and the configured value through `Get-CanonicalPathValue` for the `-notcontains` test only. The returned `ProjectFile` stays the configured string, unchanged
  - Tests: extend `CanonicalPathSelfTests.ps1` — `Resolve-AgentConfiguration` succeeds for both `D:\as-cta` and the matching `.worktrees\...` path and returns the configured short `ProjectFile` in both cases; still throws when `ProjectFile` names a genuinely different directory
  - Verify: same self-test script; expect RED first on the long-path case
  - Requirement: agent-config-worktree-alias / accept aliased entry

- [ ] 2.2 Rewrite the rejection message
  - Files: `Tools\Shared\UnrealCommandUtils.ps1` line 941
  - Impact: state configured value, entry root, and both canonical forms. Recommend `BootstrapWorktree` only when the canonical identities genuinely differ; for a canonicalization fallback mismatch say so explicitly instead
  - Tests: assert the genuine-mismatch message names both canonical paths
  - Verify: same self-test script
  - Requirement: agent-config-worktree-alias / actionable diagnosis

## 3. Make the configured path authoritative

- [ ] 3.1 Derive `ProjectRoot` from the configured `ProjectFile`
  - Files: `Tools\Shared\UnrealCommandUtils.ps1` line 945
  - Impact: `ProjectRoot = Split-Path -Parent $resolvedProjectFile` instead of the entry path, so `Saved/` output and working directories stay on the short path even when entered by the long name. **Independently revertable** if a caller depends on `ProjectRoot` matching the script location
  - Tests: entering by the long path yields a short `ProjectRoot`; entering by the alias is unchanged
  - Verify: `Tools\Diagnostics\tests\RunBuildSelfTests.ps1` and `RunTestSuiteSelfTests.ps1`
  - Requirement: agent-config-worktree-alias / short path for execution

- [ ] 3.2 Audit `ProjectRoot` consumers before keeping 3.1
  - Files: read-only sweep of `Tools\**\*.ps1` for `ProjectRoot`
  - Impact: none; produces the list that justifies or reverts 3.1
  - Verify: record findings in `attachments/implementation/progress.md`; if any consumer needs the script location, split it into a separate `EntryRoot` field rather than reverting silently

## 4. Stop bootstrap from destroying the alias

- [ ] 4.1 Preserve an existing alias `ProjectFile` <!-- TDD -->
  - Files: `Tools\Bootstrap\powershell\BootstrapWorktree.ps1` lines 102-114 and 140-144
  - Impact: route `ProjectFile` through `Get-PreferredConfigValue` like `EngineRoot`; recompute only when absent, or when the existing value no longer canonicalizes to the same directory as `WorktreeRoot`
  - Tests: new case in `Tools\Diagnostics\tests\CanonicalPathSelfTests.ps1` (or a bootstrap-specific self-test) — re-bootstrapping a worktree whose config points at `D:\as-cta` from the long path leaves `ProjectFile` untouched; a config pointing at an unrelated directory is replaced
  - Verify: run the self-test, then re-run `BootstrapWorktree` against a scratch copy and diff `AgentConfig.ini`
  - Requirement: agent-config-worktree-alias / idempotent bootstrap

## 5. End-to-end

- [ ] 5.1 Real build from both entry names
  - Files: none
  - Verify: from `D:\as-cta` and from `.worktrees\refactor-as-canonical-typed-ast-compiler`, run
    `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Target AngelscriptProjectEditor -Label worktree-alias-validation -TimeoutMs 1800000 -NoXGE`
  - Expect: both start (no config rejection) and both emit short paths in `UBT.log`. Record both run IDs and exit codes
  - Note: this is the gate that proves MAX_PATH was not reintroduced — a long path in `UBT.log` is a failure even if the build passes

- [ ] 5.2 Existing tooling self-tests still pass
  - Verify: `Tools\Diagnostics\tests\RunBuildSelfTests.ps1`, `RunTestSuiteSelfTests.ps1`, `RunCommandletSelfTests.ps1`, `RunTestSuiteParallelSelfTests.ps1`
  - Expect: no regression versus a pre-change baseline captured before task 1.1

- [ ] 5.3 Spot-check the other four aliased worktrees
  - Verify: `Resolve-AgentConfiguration` succeeds from both names for `D:\as-lns`, `R:`, `T:`, `V:` (config resolution only, no build)
  - Expect: 8/8 succeed; records which are junction versus `subst`
