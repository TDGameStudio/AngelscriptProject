---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

# Record replaced UClass tombstone lifetime

## Goal

Record that FullReload `_REPLACED_N` `UASClass` objects are intentional tombstones and list the owners a later lifetime-policy Change must replan.

## Architecture

Replacement keeps RootSet and `RF_Standalone` so stale `UClass*` can walk `NewerVersion`. Script-deleted classes unroot. See `design.md`. This Change writes those facts into attachments; it does not change ClassGenerator.

## Global constraints

- Do not edit `Plugins/Angelscript` source or tests.
- Do not add a current-spec delta for linger or collect.
- Do not edit other Changes' `tasks.md`.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
+openspec/changes/angelscript/docs-class-reload-replaced-tombstone-lifetime/attachments/knowledges/replaced-uclass-tombstone.md  # · 1.1
+openspec/changes/angelscript/docs-class-reload-replaced-tombstone-lifetime/attachments/data/related-replan.md  # · 1.1
 openspec/changes/angelscript/docs-class-reload-replaced-tombstone-lifetime/attachments/INDEX.md  # · 1.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Record replacement tombstones vs script-deleted unroot | 1.1 |
| Inventory related replan owners | 1.1 |
| No plugin lifetime mutation | 1.1 |
| Acceptance: knowledge and related-replan attachments contain the named evidence strings | 1.1 |

Self-review 2026-09-11: coverage complete; no placeholder phrases; symbols match `design.md`. Record: `attachments/data/planning-validation.md`.

## [x] 1.1 Record tombstone lifetime and related replan inventory

Write a change-local knowledge candidate for the inspected `_REPLACED_N` lifetime and a related-replan list of code, tests, historical knowledge, specs, and active Changes. Update INDEX to point at both files. Plugin source stays unchanged.

**Outcome**

`attachments/knowledges/replaced-uclass-tombstone.md` states that replacement `_REPLACED_N` objects are expired `UASClass` objects, not immediate `BeginDestroy`; they are out of lookup and spawn; they exist so stale pointers can walk `NewerVersion`; after live objects move they usually remain until editor shutdown. `attachments/data/related-replan.md` lists ClassGenerator, ClassReloadHelper, engine teardown unroot, FullReload tests, ZH knowledge dumps, current specs that omit this lifetime, and the three active Changes named in `proposal.md`. Excluded: ClassGenerator edits, current-spec SHALL, sibling `tasks.md` edits.

**Files**

```diff
+openspec/changes/angelscript/docs-class-reload-replaced-tombstone-lifetime/attachments/knowledges/replaced-uclass-tombstone.md
+openspec/changes/angelscript/docs-class-reload-replaced-tombstone-lifetime/attachments/data/related-replan.md
 openspec/changes/angelscript/docs-class-reload-replaced-tombstone-lifetime/attachments/INDEX.md
```

**Verification**

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
$changeRoot = 'openspec/changes/angelscript/docs-class-reload-replaced-tombstone-lifetime'
$knowledge = Get-Content -Raw (Join-Path $changeRoot 'attachments/knowledges/replaced-uclass-tombstone.md')
$replan = Get-Content -Raw (Join-Path $changeRoot 'attachments/data/related-replan.md')
$index = Get-Content -Raw (Join-Path $changeRoot 'attachments/INDEX.md')
foreach ($needle in @('_REPLACED_N', 'BeginDestroy', 'NewerVersion', 'RF_Standalone', 'CleanupRemovedClass', 'GetMostUpToDateClass')) {
	if ($knowledge -notmatch [regex]::Escape($needle)) { throw "knowledge missing $needle" }
}
foreach ($needle in @('refactor-sdk-drop-native-gc', 'feature-memory-gc-observability', 'refactor-defaults-constructor-unification', 'ClassReloadHelper', 'Type_ClassGeneration.md', 'CreateFullReloadClass', 'ForceGarbageCollection')) {
	if ($replan -notmatch [regex]::Escape($needle)) { throw "related-replan missing $needle" }
}
if ($index -notmatch 'replaced-uclass-tombstone.md') { throw 'INDEX missing knowledge' }
if ($index -notmatch 'related-replan.md') { throw 'INDEX missing related-replan' }
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @(
	'angelscript/docs-class-reload-replaced-tombstone-lifetime',
	'--type', 'change',
	'--strict',
	'--json'
)
```

Working directory: repository root. Completion: the string checks pass and Harness `openspec.validate` status is `Succeeded` with exit code 0. Intentionally omit Automation, Quick, Performance, Integration, and Editor builds: no runtime behavior changed.

**Notes**

A later lifetime-policy Change uses these two attachments as intake. It does not continue this Task DAG.

**Evidence**

2026-09-11 Harness `openspec.validate` runId `4468f89067654153966984ab425fa2c5`, status Succeeded, exit 0. Knowledge and related-replan string checks passed. Intentionally omitted Automation, Quick, Performance, Integration, and Editor builds: no runtime behavior changed.
