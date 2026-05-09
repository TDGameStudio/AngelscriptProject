---
name: openspec-archive-change
description: Use when the user wants to finalize and archive a completed OpenSpec change in AngelscriptProject, including /opsx:archive or /openspec:archive.
---

# OpenSpec Archive With Completion Guardrails

Archive a completed OpenSpec change. Archiving is a lifecycle action, not implementation.

## Steps

1. **Select the change**

   If the user names a change, use it. Otherwise run `openspec list --json` and ask the user to choose when there is more than one active change. Do not guess between multiple active changes.

2. **Check OpenSpec status**

   Run:

```powershell
openspec status --change "<name>" --json
```

   Warn about incomplete artifacts and ask before proceeding.

<!-- SUPERPOWER-BEGIN: archive-completion-check -->
Before archiving, verify completion evidence:
- Read the task artifact reported by OpenSpec and count incomplete `- [ ]` checkboxes.
- Warn and ask before archiving with incomplete tasks.
- Check `git status --short` for uncommitted implementation changes.
- If there are uncommitted changes, stop and ask whether to keep, commit, or archive anyway; do not silently include or discard them.
- If specs need syncing, show the delta summary and ask whether to sync before archive.
<!-- SUPERPOWER-END: archive-completion-check -->

3. **Archive via CLI**

   Run:

```powershell
openspec archive "<name>"
```

   The CLI handles directory moves, spec updates, and validation automatically. Add `-y` to skip interactive confirmation if the user has already confirmed in step 2. Add `--skip-specs` for infrastructure, tooling, or doc-only changes that have no spec impact.

   If the CLI reports a validation error or conflict, stop and report to the user.

4. **Summarize**

   Report the change name, schema, CLI output (archive result and any spec updates performed), and any warnings accepted by the user.

## Guardrails

- Do not archive a change without telling the user about incomplete artifacts or tasks.
- Do not delete or rewrite OpenSpec history outside the selected change.
