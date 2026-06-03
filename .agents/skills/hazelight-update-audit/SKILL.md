---
name: hazelight-update-audit
description: Use when comparing recent Hazelight UnrealEngine-Angelscript updates against AngelscriptProject to decide whether plugin changes, OpenSpec proposals, or sync work are needed.
---

# Hazelight Update Audit

Use this skill for read-only review of recent updates in `Hazelight/UnrealEngine-Angelscript` before deciding whether AngelscriptProject should adopt, defer, or ignore them.

## Guardrails

- Treat this as audit work. Do not modify source, OpenSpec artifacts, reference docs, or generated files from this skill alone.
- The only files this skill may update during audit are its own state and log files, and only when the user explicitly asks to record the result.
- Never print GitHub tokens, SSH keys, credential helper contents, or secret environment variables.
- Use `gh` for GitHub access. If auth or repo access fails, report the exact missing prerequisite and stop.
- If the user asks to implement a sync, route the work through `openspec-work`.
- Prefer `gh api` over local clone state for freshness. Use the local clone only as an optional reference source.

## Quick Workflow

1. Verify access:
   ```powershell
   gh auth status
   gh repo view Hazelight/UnrealEngine-Angelscript --json nameWithOwner,visibility,defaultBranchRef,url,updatedAt
   ```
2. Run the helper script:
   ```powershell
   .\.agents\skills\hazelight-update-audit\scripts\Get-HazelightUpdateAudit.ps1 -Count 20
   ```
3. For older windows, page through commits:
   ```powershell
   .\.agents\skills\hazelight-update-audit\scripts\Get-HazelightUpdateAudit.ps1 -Count 20 -Page 2
   ```
4. To resume from the last recorded audit checkpoint, run without `-BaseSha`; the script reads `references/audit-state.json` when present.
5. For a known base range, use compare mode:
   ```powershell
   .\.agents\skills\hazelight-update-audit\scripts\Get-HazelightUpdateAudit.ps1 -BaseSha <base> -HeadSha <head> -Json
   ```
6. After finishing a human-reviewed audit, record the checkpoint only when requested:
   ```powershell
   .\.agents\skills\hazelight-update-audit\scripts\Get-HazelightUpdateAudit.ps1 -BaseSha <base> -HeadSha <head> -UpdateState
   ```
7. Record the human-readable audit result in `references/audit-log.md` when the user wants the review to be reusable.
8. Inspect the equivalent local files before recommending adoption. Path names alone are not enough.
9. Produce a short report with commit range, changed files by subsystem, authors, UE-following signals, classification, and next action.

## Audit Records

Use two files with separate purposes:

- `references/audit-state.json`: machine-readable checkpoint. This is the resume cursor.
- `references/audit-log.md`: human-readable audit history. This records what was reviewed and why each item was classified.

The checkpoint file is intentionally small and committed with the skill so the next audit can continue from the last reviewed upstream point. Track:

- `lastReviewedHeadSha`: upstream commit fully reviewed by humans.
- `lastReviewedAt`: UTC timestamp when the checkpoint was recorded.
- `lastAuditBaseSha` and `lastAuditHeadSha`: most recent compared range.
- `lastAuthors`: commit authors seen in the last audit range.
- `lastUnrealEngineFollowSignals`: commits that look like UE version/release merges or Epic release tracking.
- `notes`: short human-maintained context for deferred sync decisions.

The log file should record:

- audit date, upstream range, HEAD, and checkpoint status.
- how many commits were listed versus deeply patch-reviewed.
- authors and UE-following signals.
- `Adopt now`, `Already absorbed`, `Needs OpenSpec`, `Reference only`, and `Out of scope` sections.

Do not update either file just because the script ran. Update them only after the audit result has been reviewed and the user wants it recorded.

## Classification

Use these labels consistently:

- `Adopt now`: small, local, low-risk fixes with an equivalent local path, such as binding const correctness, missing includes, or commandlet/headless guards.
- `Needs OpenSpec`: module boundaries, public APIs, build structure, StaticJIT behavior, AngelScript library extraction, settings, replication semantics, or behavior visible to scripts/Blueprints.
- `Reference only`: Hazelight engine-fork behavior, changes already solved differently here, or code useful only as design input.
- `Out of scope`: GAS plugin work, Hazelight sample projects, external VSCode extensions, or non-Angelscript plugin content unless the user explicitly expands scope.

Flag UE-following commits separately. These are often not direct plugin feature work and may represent upstream engine refreshes:

- Messages containing `Merge remote-tracking branch 'epicgames/`.
- Messages containing `release`, `UE`, `Unreal Engine`, or version patterns such as `5.7.2`.
- Large compare ranges dominated by `Engine/Source/*` outside plugin paths.

## Path Mapping

Map upstream paths to local areas before judging relevance:

| Hazelight path | Local area |
| --- | --- |
| `Engine/Plugins/Angelscript/Source/AngelscriptCode/Private/Binds/*` | `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/*` |
| `Engine/Plugins/Angelscript/Source/AngelscriptCode/Private/ClassGenerator/*` | `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/*` |
| `Engine/Plugins/Angelscript/Source/AngelscriptCode/Private/StaticJIT/*` | `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/*` |
| `Engine/Plugins/Angelscript/Source/AngelscriptCode/Private/Testing/*` | `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/*` or `Plugins/Angelscript/Source/AngelscriptTest/*` |
| `Engine/Plugins/Angelscript/Source/AngelscriptCode/Public/*` | `Plugins/Angelscript/Source/AngelscriptRuntime/Public/*` or runtime public headers |
| `Engine/Plugins/Angelscript/Source/AngelscriptEditor/*` | `Plugins/Angelscript/Source/AngelscriptEditor/*` |
| `Engine/Plugins/AngelscriptGAS/*` | `Out of scope` by default |
| `Script-Examples/*` | `Script/Examples/*` or functional-test migration references |

## Report Shape

Keep reports compact:

- Repo, branch, audited range, and audit time.
- Local Hazelight clone status if available.
- Previous checkpoint and whether the audit resumed from it.
- Recent commits and changed files grouped by subsystem.
- Commit authors and UE-following signals.
- Recommended action for each candidate sync item.
- OpenSpec change suggestions when the item is architectural or behavior-affecting.
