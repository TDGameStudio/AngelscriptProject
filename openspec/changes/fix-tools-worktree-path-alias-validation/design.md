# Design

## Reproduction (verified 2026-08-24)

Both directions were confirmed against the live worktree by dot-sourcing the worktree's own `Tools\Shared\UnrealCommandUtils.ps1`:

```powershell
$wt = 'D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler'
. "$wt\Tools\Shared\UnrealCommandUtils.ps1"
Resolve-AgentConfiguration -ProjectRoot $wt          # FAIL
Resolve-AgentConfiguration -ProjectRoot 'D:\as-cta'  # OK
```

Result:

```
从 .worktrees 长路径进入  → FAIL: ProjectFile does not belong to project root ...
从 D:\as-cta 进入         → OK   ProjectFile=D:\as-cta\AngelscriptProject.uproject
```

The two paths are the same file — identical content hash — but different strings:

```
A = D:\as-cta\AngelscriptProject.uproject
B = D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler\AngelscriptProject.uproject
字符串相等: False
是同一文件: True
```

## Where it happens

`Tools\Shared\UnrealCommandUtils.ps1`

- `Normalize-PathValue` (line 8) — `[System.IO.Path]::GetFullPath` + separator/trailing-slash cleanup. Lexical only: no reparse-point or DOS-device resolution. This is correct for its other callers; it is not the thing to change.
- `Resolve-AgentConfiguration` (line 905) — builds `$resolvedProjectFileCandidates` from `Get-ChildItem $resolvedProjectRoot -Filter *.uproject` (line 932), then `-notcontains` against the configured value (line 940) and throws (line 941).

`Tools\Bootstrap\powershell\BootstrapWorktree.ps1`

- `Resolve-ProjectFileForBootstrap` (line 102) — always derives from the passed `WorktreeRoot`.
- `Get-BootstrapConfigTemplate` (line 140) — `ProjectFile = $resolvedProjectFile` (line 143), assigned directly. `EngineRoot` and every `Build` key use `Get-PreferredConfigValue`; `ProjectFile` does not.

`Tools\Bootstrap\NewWorktree.ps1` — no junction/subst logic at all. Aliases are always created by hand after the fact, which is why config and entry point drift apart.

## Canonicalization: which API

Two candidates were tested on this machine (PowerShell 7.6.0).

| Approach | junction (`D:\as-cta`) | subst (`V:\...`) | Verdict |
|---|---|---|---|
| `(Get-Item -Force).ResolveLinkTarget($true)` | resolves | **returns `$null`** (not a link); on the bare root `V:\` it throws | Covers 2 of 5 aliases. Not enough. |
| `GetFinalPathNameByHandle` (kernel32) | resolves | resolves | Covers all 5. Idempotent on already-canonical paths. |

Measured output of the Win32 approach:

```
D:\as-cta                        -> D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler
V:\                              -> D:\Workspace\AngelscriptProject\.worktree\feature-as-typed-semantic-aot
V:\AngelscriptProject.uproject   -> D:\Workspace\AngelscriptProject\.worktree\feature-as-typed-semantic-aot\AngelscriptProject.uproject
D:\as-cta\AngelscriptProject.uproject -> ...\refactor-as-canonical-typed-ast-compiler\AngelscriptProject.uproject
<long path>\AngelscriptProject.uproject -> ...\refactor-as-canonical-typed-ast-compiler\AngelscriptProject.uproject   # unchanged
```

Decision: **`GetFinalPathNameByHandle`**, added as a new `Get-CanonicalPathValue` helper. `ResolveLinkTarget` is rejected because `subst` is a DOS device mapping rather than a reparse point, and three worktrees rely on `subst`.

Constraints on the helper:

- Requires an open handle, so the path must exist. Both compared paths do exist at this point (`Get-ChildItem` just enumerated one; the other is validated for existence by the caller chain).
- Open with `FILE_FLAG_BACKUP_SEMANTICS` (`0x02000000`) and zero desired access so directories can be opened without read rights.
- Strip the returned `\\?\` prefix.
- **Fall back to `Normalize-PathValue` on any failure** and let the existing lexical comparison decide. A hard dependency on a P/Invoke would turn an unusual filesystem into a total tooling outage.
- `Add-Type` cost is paid once per session; cache the compiled type.

## Decisions

**Canonicalize for comparison, never for execution.** The alias exists because the long path breaks the build: `attachments/worktree-max-path-build-failure.md` in `refactor-as-canonical-typed-ast-compiler` records 2026-08-21 with `ProjectFile` set to the long path — UBT `Failed (OtherCompilationError)`, ProcessExitCode 6 / FinalExitCode 1, 15.08 s, no `cl.exe` diagnostic. Canonicalizing the value that is *used* would recreate that failure for every aliased worktree.

This is already safe on the build path: `-Project=` is built from the config's `ProjectFile` (line 1019-1024), not from the entry path. So the returned `ProjectFile` must stay exactly as configured.

**The config is authoritative for paths; the entry path only locates the config.** Whichever name a session enters by, work should proceed through the configured short path. Concretely, `ProjectRoot` in the returned object should become the parent of the configured `ProjectFile` rather than the entry path, so `Saved/` output and working directories also stay short. Without this, entering by the long path passes validation and then still emits long paths for everything derived from `ProjectRoot`.

This is the one behavioral change beyond pure validation, and it is what makes the fix actually useful rather than merely permissive. It is separated into its own task so it can be dropped if it turns out some caller depends on `ProjectRoot` matching the script location.

**`BootstrapWorktree` must preserve an existing alias `ProjectFile`.** Route it through `Get-PreferredConfigValue` like its siblings, recomputing only when absent or when it no longer resolves to the same directory. This makes re-bootstrapping idempotent for aliased worktrees instead of destructive.

**Error message states the mismatch.** Distinguish two cases: identity differs (a genuine misconfiguration — keep pointing at `BootstrapWorktree`), versus identity matches but strings differ (impossible after this fix, but keep a distinct message in case canonicalization fell back). Never recommend `BootstrapWorktree` for the alias case.

## Rejected / deferred

**Normalize the config to long paths and drop the aliases.** Reintroduces the verified MAX_PATH build failure. Rejected.

**Compare by file identity (volume serial + file index) instead of canonical path.** Strictly more correct than path comparison and would also catch hardlinks, but needs `GetFileInformationByHandle` marshalling for a case that does not occur here, and produces no human-readable value for error messages. Not worth it.

**Make the alias a first-class concept** — `[Paths] ProjectRootAlias` in `AgentConfig.ini`, `NewWorktree.ps1` creating the junction and recording it, all scripts resolving through it. This is the better end state: it removes the manual alias step that causes the drift in the first place, and it would let tooling *prefer* the short path rather than merely tolerate it. Deferred because it changes the worktree creation workflow and `SubmoduleWorktreeWorkflow.md`, and because the validation fix is independently useful and much smaller. Revisit after this lands.

**Only reword the error message.** Cheapest, and it would stop the recurring misdiagnosis, but every session would still have to enter by the right name. Rejected as insufficient on its own — though the message rewording is retained as part of this change.

## Risk

| Risk | Mitigation |
|---|---|
| P/Invoke fails on an unusual filesystem or under a restricted token | Fall back to lexical comparison; behavior is then exactly today's |
| A caller depends on `ProjectRoot` equalling the script's own location | Separate task; self-tests cover both entry names. Revert that task alone if it breaks |
| Canonicalization masks a genuinely wrong `ProjectFile` | Identity comparison is strictly narrower than string equality plus alias tolerance — a path pointing at a *different* directory still throws |
| `Add-Type` compilation cost on every script start | Compile once per session and cache the type |
