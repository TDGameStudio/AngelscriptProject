# Verification Plan and Creation-Pass Evidence

## Plan-only scope

The current pass is complete only when:

- every changed path is beneath `openspec/changes/test-as-source-generation-rules`;
- the 614/271/45,760/90/1,022 baselines reproduce from authoritative current inputs, including the explicit support-only Coverage file;
- every current `ASTEST_AS*` invocation is inventoried;
- all catalogs have unique identities and required fields;
- every task body has all required metadata and no placeholder text;
- all three delta specs pass strict OpenSpec validation;
- no product implementation or current-test replacement is claimed.

## Regeneration commands

```powershell
powershell -NoProfile -File openspec/changes/test-as-source-generation-rules/scripts/ExportCoverageMethodInventory.ps1
powershell -NoProfile -File openspec/changes/test-as-source-generation-rules/scripts/ExportCurrentInlineAsInventory.ps1
powershell -NoProfile -File openspec/changes/test-as-source-generation-rules/scripts/BuildGenerationTaskCatalogs.ps1
powershell -NoProfile -File openspec/changes/test-as-source-generation-rules/scripts/ValidateGenerationRulePlan.ps1
```

The scripts resolve the repository from their own OpenSpec path, write only beneath this change, and fail if the recorded exact baselines drift.

## OpenSpec commands

```powershell
openspec validate test-as-source-generation-rules --strict --no-interactive
openspec status --change test-as-source-generation-rules --json
```

Expected status is a complete proposal/design/specs/tasks artifact set with implementation checkboxes intentionally unchecked.

## Scope audit

Use both repository status and explicit path filtering because the main workspace already contains unrelated user changes:

```powershell
git status --short
git diff --name-only
git ls-files --others --exclude-standard
```

The handoff must list only files in this change as this turn's work and must not imply that unrelated dirty `TestSource`, knowledge documents, typed-semantic files, other OpenSpecs, or the old `script-corpus` worktree were modified.

## Future implementation verification layers

### Portable schema/algorithm/rule tests

```powershell
python -m pytest Tools/AngelscriptCodeGen/tests -q
powershell -NoProfile -File Tools/AngelscriptCodeGen/RunParityTests.ps1
```

These prove schema errors, canonical serialization, CaseKeys/hashes, SplitMix vectors, bounded selection, shuffles, recipe cardinality, typed oracles, negative mutation, comments, source emission, output policy, release emission, repeatability, and Python/C++ byte parity.

### Catalog-wide tests

```powershell
python -m pytest Tools/AngelscriptCodeGen/tests/rules/authored -q
python -m pytest Tools/AngelscriptCodeGen/tests/rules/native_sdk -q
python -m pytest Tools/AngelscriptCodeGen/tests/rules/coverage -q
python -m pytest Tools/AngelscriptCodeGen/tests/rules/inline -q
```

Every authored fixture and SDK product has an individual test-first task; candidates receive tests only after disposition review confirms their axes and oracle.

### Plugin release build/tests

```powershell
Tools/RunBuild.ps1 -Target AngelscriptProjectEditor
Tools/RunTests.ps1 -Test Angelscript.TestModule.Generated.TestCodeRelease
```

These are future commands. They are not run in the OpenSpec creation pass because the user explicitly requested planning/rules first and no compilation concern at this stage.

### No-replacement proof

Before this change can be considered implemented, compare the final diff against the initial baseline and prove:

- legacy SDK generator methods and current Coverage/inline/manual tests remain present and unchanged unless a later adoption OpenSpec is explicitly in the same reviewed diff;
- no current automation test name or runner silently switches source ownership;
- generated plugin artifacts contain only approved C++ release output;
- Python and C++ release output file sets and hashes are identical;
- all seeds in reports are explicit and every explicit matrix retains its exact cardinality.
