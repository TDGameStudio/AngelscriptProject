---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": []
    "2.2": []
    "2.3": ["2.2"]
    "2.4": ["2.1", "2.3"]
    "3.1": ["2.2", "2.3"]
    "3.2": ["2.4", "3.1"]
    "3.3": ["3.2"]
    "4.1": ["3.2"]
    "4.2": ["4.1"]
    "5.1": ["2.2"]
    "5.2": ["3.3", "4.2"]
    "6.1": ["5.1", "5.2"]
    "6.2": ["6.1"]
    "7.1": ["1.1", "6.2"]
    "7.2": ["7.1"]
---

# Future implementation tasks

## Current authorization

**The user authorized creation of this Change only. Do not execute these nodes
in the planning delivery.** All checkboxes remain unchecked, including the Skill
cleanup. A derived `ready` value describes graph prerequisites, not permission
to implement. This file is the sole future Task DAG.

## Execution and verification conventions

Paths are relative to the selected workspace. Read `attachments/INDEX.md`,
`design.md` and the linked class contracts before an owning node. Existing
unrelated dirty files and the Builder Change are not owned by this work.

When later authorized, import Harness directly in the current PowerShell 7
process and establish the exact workspace context:

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
```

Each C++ task requires a fresh successful build after adding its failing test and
again after implementation changes, before running its exact test proof:

```powershell
Invoke-Harness -Command ue.build -Context $context -Parameters @{
    Target = 'AngelscriptProjectEditor'
    Platform = 'Win64'
    Configuration = 'Development'
    BuildConcurrency = 'Auto'
    ConcurrencyPolicy = 'Auto'
    TimeoutMs = 3600000
}
```

The task's exact `ue.test` command is the RED/GREEN behavioral proof, not a claim
that an old executable contains the newly written test. Build failures stay in
the owning task. Use one managed process for the focused prefix. Python task
commands refer to files created by that task or a prerequisite; they are not
claimed to exist in the present planning delivery.

Record exact commands, source/input identity, pass/fail counts and managed run
evidence in task-local text or indexed Change data after execution. Never claim
source inventory, export, unavailable backend or skipped execution as PASS.
Broader suites need actual shared impact. No automatic review or full-suite node
is part of normal progress.

## 1. Current authoring guidance

- [ ] 1.1 Consolidate currently applicable testing Skill rules and historical routing — verify: `python C:/Users/scottmei/.codex/skills/.system/skill-creator/scripts/quick_validate.py .agents/skills/angelscript-test-guide`
  > Files: `.agents/skills/angelscript-test-guide/SKILL.md`, `.agents/skills/angelscript-test-guide/SKILL_ZH.md`, `.agents/skills/angelscript-test-guide/cqtest-guide_EN.md`, `.agents/skills/angelscript-test-guide/cqtest-guide.md`, `.agents/skills/angelscript-test-guide/cqtest未整理版.md`, `.agents/skills/angelscript-test-guide/references/case-authoring.md`, `.agents/skills/angelscript-test-guide/references/legacy-authoring-notes.md`, `.agents/skills/angelscript-test-guide/references/legacy-source-isolation.md`

  1. Preserve the pre-existing replacement intro and user edits. Promote the no-single-class-anonymous-namespace rule, class-local narrow helpers, public hooks, visible scenario flow, checked return values and deterministic cleanup into current guidance.
  2. Use only existing CQTest and NativeEngine source APIs in current executable examples. Keep new macros/TestCode/data registration as explicitly planned links to this Change.
  3. Turn the Chinese copy into navigation, mark old CQTest notes historical, remove old Documents/Tools authority from active routes, and fix the archived quarantine script path recorded in provenance.
  4. Check actual links AND backticked path instructions, current symbols, gates and public-name composition. Exercise the authoring situations in `design.md` section 11; a format validator alone does not prove correct guidance.

## 2. Sources and tagged histories

- [ ] 2.1 Implement owned source values, inline macros, exact bytes and provenance — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Source'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSourceTypes.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSource.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSource.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/Source/**`, `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`
  > File scope: replacement-only include/dependency changes.

  1. Observe RED for normalization, exact text/bytes, owning lifetime and source-origin mapping using the class contracts.
  2. Add `FAngelscriptTestSource`, source refs, structured errors/results and the one-argument `AS_TEST_SOURCE`/`AS_TEST_SOURCE_EXACT` macros. Do not include the legacy macro header or acquire an engine. The catalog-aware source bundle lands in 3.2 after its dependencies.
  3. Prove one-envelope removal, preserved extra blank lines, exact tab/space common prefix, Unicode byte columns, CRLF/CR, NUL/BOM/bad UTF-8, empty source and view lifetime. Preserve host anchor versus logical range distinctions.
  4. Prove anonymous immutable construction and absence of global registration side effects. Preserve owned values across temporary input destruction; identity binding must not mutate a shared source value.

- [ ] 2.2 Establish the plugin-owned catalog tool and explicit admission schemas — verify: `python -B -m pytest Plugins/Angelscript/Tests/Tools/TestCode/tests/test_catalog.py -q -p no:cacheprovider`
  > Files: `Plugins/Angelscript/Tests/Tools/TestCode/test_code.py`, `Plugins/Angelscript/Tests/Tools/TestCode/pyproject.toml`, `Plugins/Angelscript/Tests/Tools/TestCode/angelscript_test_code/__init__.py`, `Plugins/Angelscript/Tests/Tools/TestCode/angelscript_test_code/catalog.py`, `Plugins/Angelscript/Tests/Tools/TestCode/angelscript_test_code/model.py`, `Plugins/Angelscript/Tests/Tools/TestCode/schemas/**`, `Plugins/Angelscript/Tests/Tools/TestCode/tests/test_catalog.py`, `Plugins/Angelscript/Tests/Tools/TestCode/tests/conftest.py`, `TestSource/Catalog/sources/**`, `TestSource/Catalog/cases/**`, `TestSource/Catalog/selections/**`
  > File scope: small framework fixtures only.

  1. Add failing admission/identity/schema tests before implementing the model and audit/validate CLI paths.
  2. Define per-source and per-case records plus explicit selection manifests as in design section 8. Keep schema-backed data and generated indexes separate; do not mirror all legacy files.
  3. Prove duplicate IDs/aliases, unknown source/tag references, invalid paths, unknown adapter/schema, deterministic ordering and selected-domain isolation. Inventory outside the selection remains unverified.
  4. Keep generic case source refs optional and row input/expected decoding owned by a named fixture schema. Check in each admitted adapter/schema's versioned JSON schema and valid/invalid vectors for the later C++ codec; Python does not infer C++ types. Reject pointers and out-of-range typed values.

- [ ] 2.3 Port and complete public SourceHistory parsing and diff validation — verify: `python -B -m pytest Plugins/Angelscript/Tests/Tools/TestCode/tests/test_source_history.py -q -p no:cacheprovider`
  > Files: `Plugins/Angelscript/Tests/Tools/TestCode/angelscript_test_code/source_history.py`, `Plugins/Angelscript/Tests/Tools/TestCode/angelscript_test_code/diff.py`, `Plugins/Angelscript/Tests/Tools/TestCode/angelscript_test_code/catalog.py`, `Plugins/Angelscript/Tests/Tools/TestCode/tests/test_source_history.py`, `TestSource/Generation/python/angelscript_generation/reload_history.py`, `TestSource/Generation/python/angelscript_generation/audit_v2.py`, `TestSource/Generation/python/validate_testsource.py`, `TestSource/Generation/python/tests/test_reload_history.py`
  > File scope: SourceHistory compatibility delegation only; preserve unmigrated ordinary Contract V2 CLI and audit/strict behavior.

  1. Capture RED for histories silently skipped by the public validator, duplicate/root-parent/cycle/unknown markers, branch order and corrupt diff behavior.
  2. Port useful existing pure parser/diff functions with provenance. Route admitted histories into the public validator and delegate old SourceHistory parsing to the shared implementation. Preserve ordinary Contract V2 callers, arguments and audit/strict results; this task does not migrate the entire old validator or corpus. Exercise both admitted histories and preserved ordinary V2 behavior in the same focused proof.
  3. Implement topological parent resolution, checked root/child snapshots, reversible generated diffs, stable LF materialization and authoring mappings. Reject redundant identical child snapshots and ambiguous comment/marker delimiters explicitly.
  4. Test empty edited source separately from deletion, legacy marker import without executable oracle interpretation, and source ancestry through a compile-invalid child without runtime activation assumptions.

- [ ] 2.4 Implement C++ history materialization and local history construction — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.History'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/History/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/History/**`

  1. Create failing C++ tests from deterministic Python history fixtures, including chain, branch and failed-source-parent shapes.
  2. Implement checked history descriptors, `FAngelscriptTestSourceHistoryBuilder`, root/diff and local-full-snapshot storage forms with the same Resolve contract.
  3. Verify each parent/child hash and forward materialization against authored golden bytes. Resolve a sibling from its declared ancestry, never from an ambient currently used source.
  4. Prove invalid references, cycles, stale hash and corrupt hunk errors publish no source, and that materialized source owners survive temporary builder destruction.

## 3. Embedded release and TestCode

- [ ] 3.1 Implement deterministic staged C++ release generation and comparison — verify: `python -B -m pytest Plugins/Angelscript/Tests/Tools/TestCode/tests/test_cpp_export.py -q -p no:cacheprovider`
  > Files: `Plugins/Angelscript/Tests/Tools/TestCode/angelscript_test_code/cpp_export.py`, `Plugins/Angelscript/Tests/Tools/TestCode/angelscript_test_code/release.py`, `Plugins/Angelscript/Tests/Tools/TestCode/test_code.py`, `Plugins/Angelscript/Tests/Tools/TestCode/tests/test_cpp_export.py`

  1. Observe RED for double-export identity, byte-array payload escaping, hash drift, removed shards and failed staging publication.
  2. Implement emit-cpp and check-embedded using explicit lengths, root/diff tables, canonical metadata, deterministic shard groups and one aggregate entry.
  3. Test arbitrary payload bytes and C++ delimiter-like text; exclude workspace paths/timestamps/parent commits from generated identity. Failed generation preserves every existing release file.
  4. Verify source/data/schema/tool edits invalidate comparison and unchanged inputs do not rewrite files. Do not add UBT-time mutation or per-source static registration.

- [ ] 3.2 Implement TestCode facade, immutable source store and explicit module registration — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Catalog'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestCode.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/Private/AngelscriptTestSourceStore.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Source/AngelscriptTestSourceBundle.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/Catalog/**`, `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTestModule.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Generated/TestCode/**`
  > File scope: framework fixture release.

  1. Add failing source lookup/query/history/snapshot tests while the legacy runtime remains dormant.
  2. Implement the class-contract entry points and immutable release lease. Wire one generated aggregate reference in the replacement module; preserve the existing shell and legacy gates.
  3. Prove explicit SourceId/VersionTag resolution, missing-reference errors, deterministic query/sample, duplicate/alias rejection, independent source use without a data case, and source lifetime across snapshot replacement.
  4. Prove there is no public ScriptCorpus/Snippet parallel registry, implicit latest lookup, source-file disk fallback or source-center execution/expectation helper.
  5. Integrate the catalog-aware source bundle: case/row/logical-path identity binding, empty AS-free bundle, duplicate slots, local/public collision errors, external references and local tagged histories. Verify frozen bundle ownership and immutable source sharing under the same Catalog prefix.

- [ ] 3.3 Admit and verify a small external-source release in the parent/plugin boundary — verify: `python Plugins/Angelscript/Tests/Tools/TestCode/test_code.py check-embedded --root TestSource --selection TestSource/Catalog/selections/framework-pilot.json --embedded Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Generated/TestCode`
  > Files: `TestSource/Catalog/sources/**`, `TestSource/Catalog/cases/**`, `TestSource/Catalog/selections/framework-pilot.json`, `TestSource/Framework/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Generated/TestCode/**`

  1. Select a normal AS source, a branched SourceHistory and exact-byte fixture metadata; add only dedicated framework fixtures, preserving existing unconverted corpus.
  2. Use emit-cpp into staging and publish the complete small release. Store source provenance and logical identities in the manifests.
  3. Require regeneration equality; neither source inventory nor a matched release is marked compile/runtime-verified. Keep plugin commit/gitlink operations outside this task's authority.

## 4. Typed rows, fixtures and evidence

- [ ] 4.1 Implement typed case descriptors, codec admission and independent row registration — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Automation'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestCaseCatalog.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestRow*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestDataSchema*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/Codecs/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Automation/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Fixtures/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Reporting/AngelscriptTestRunResult.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/Automation/**`

  1. Observe RED for reordered stable rows, exact single-row execution, empty/duplicate provider and unknown/stale selection.
  2. Implement the five-argument AS_REGISTER_DATA_TEST macro and member-Run fixture contract, including the basic in-memory run-result types needed for executable rows. Providers take a RowBuildContext for structured schema/decoding errors and return owned typed rows. Full lifecycle fault coverage and artifact writing follow in 4.2; this node cannot rely on their not-yet-implemented functions.
  3. Expose `.Rows.<RowId>` items through public Automation APIs, binding FNoDiscardAsserter to the current item. Do not modify engine CQTest or register ordinary methods twice.
  4. Cover AS-free C++ rows, inline and external source rows, malformed file-backed data, JSON-schema/C++-codec agreement using 2.2's vectors, and required versus optional capability decisions. Discovery performs no engine/World work.
  5. Prove optional exclusion before GetTests with inspectable reasons, required-unavailable diagnostic failure, explicit excluded-token rejection and no fixture for either path. Preserve zero-execution Incomplete behavior; do not use all-skipped native items or a true return as substitute coverage.

- [ ] 4.2 Complete per-row cleanup and content-bound result artifacts — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Reporting'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Fixtures/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Reporting/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Automation/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/Reporting/**`
  > File scope: result/lifecycle handoff only.

  1. Add failing tests for partial setup, assertion early return, cancellation/timeout observation and final cleanup publication; use controlled fixture faults rather than crashing an ordinary suite.
  2. Implement explicit lifecycle/results and artifact sink below the existing UE ReportExportPath, correlated through actual Harness metadata. Prove safe unique paths, write-error reporting and an explicitly uncorrelated interactive fallback; add no new Harness argument or guessed RunId. Keep process-crash outcome correlation distinct from a claim of in-process teardown.
  3. Prove CaseId/RowId/source hashes/catalog/schema/build/seed identity, typed diagnostic field differences, complete failure source and exact reproduction selection. A content edit makes previous evidence historical.
  4. Require non-PASS reporting for missing required capability, stale or empty selection, failure and unexecuted coverage. No mutable PASS field is written into authoring metadata.

## 5. Generators and frontend adoption

- [ ] 5.1 Adopt bounded deterministic recipes and regression-candidate output — verify: `python -B -m pytest Plugins/Angelscript/Tests/Tools/TestCode/tests/test_generation.py -q -p no:cacheprovider`
  > Files: `Plugins/Angelscript/Tests/Tools/TestCode/angelscript_test_code/generation.py`, `Plugins/Angelscript/Tests/Tools/TestCode/angelscript_test_code/random_source.py`, `Plugins/Angelscript/Tests/Tools/TestCode/test_code.py`, `Plugins/Angelscript/Tests/Tools/TestCode/tests/test_generation.py`, `TestSource/Catalog/recipes/**`
  > File scope: small admitted recipes only.

  1. Add RED tests against adopted SplitMix64-v1 golden vectors, stable named axes/seed identity and bounded count.
  2. Implement generate for a source-free integer data matrix and a controlled AS literal recipe using an independent known oracle. Record original generation-rule provenance.
  3. Prove identical requests produce identical source/data and that altered recipe/version/axes/seed changes identity appropriately. Emit complete regression candidates without automatically admitting them.

- [ ] 5.2 Consolidate replacement frontend input and diagnostic fixture setup — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Frontend'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Frontend/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/Frontend/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/NativeEngineTestSupport.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Preprocessor/NativePreprocessorTestSupport.h`
  > File scope: owned common-input adapter only.

  1. Before editing, inspect the concurrent Builder task/INDEX and settled public source/diagnostic interfaces; do not modify its implementation, task state or in-flight files. Schedule overlapping support edits after its owner finishes them.
  2. Add failing tests for source-bundle snapshot ownership, multi-file logical mapping, stage-local observations and typed diagnostic comparison through the real frontend interfaces.
  3. Implement a small test fixture over public snapshot/source-manager/diagnostic consumers; keep concrete language assertions in test bodies and no ambient AS engine. Adapt only common preparation that has a verified replacement.
  4. Prove inline/embedded byte equivalence, history-tag diagnostic mapping, malformed bytes and stable observations under source ordering. Do not create another parser or string-only diagnostic authority.

## 6. Representative acceptance and isolation

- [ ] 6.1 Exercise three authoring entrances and tagged-source consumption end to end — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Adoption'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/Adoption/**`, `TestSource/Framework/**`, `TestSource/Catalog/sources/**`, `TestSource/Catalog/cases/**`, `TestSource/Catalog/selections/framework-pilot.json`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Generated/TestCode/**`
  > File scope: pilot additions only.

  1. Add independent named data rows for pure C++, local normalized/exact AS, shared external AS and a deterministic generated input. Preserve ordinary baseline tests.
  2. Add actual frontend compile/diagnostic observations for root and a deliberately invalid tag; assert source materialization alone does not prove compilation or runtime reload.
  3. Verify multiple cases reuse the same source/tag, row reorder and isolated selection, complete failure reproduction and source/expectation field diagnostics.
  4. Keep fixture-only helper code inside its owning test class; no anonymous namespace solely for one class. Retain these actual examples as the later Skill source of truth.

- [ ] 6.2 Prove integrated framework discovery, release consumption and legacy isolation — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/**`, `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`, `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTestModule.cpp`, `openspec/changes/angelscript/refactor-testing-unified-framework/attachments/data/**`
  > File scope: boundary checks only; necessary boundary corrections only.

  1. Rebuild the final framework content and inspect actual Automation paths for ordinary/data registration ownership, exact row suffixes and absent legacy prefixes.
  2. Test the embedded resolver with authoring access unavailable in its test environment; no source-filesystem dependency or Python startup is allowed. Inspect generated include/dependency inputs to confirm no parent authoring build dependency.
  3. Record exact integrated counts and report identity, plus source-tool fixture results. This full Framework prefix is justified by the shared registration/source/result contract; omit legacy, full NativeEngine, World, VM/cache/JIT and Harness aggregate suites unless separate evidence expands scope.
  4. Keep runtime/reload adapters deferred and unverified. No worktree creation or destructive removal of TestSource is needed to simulate resource-only consumption.

## 7. Verified guidance and durable closure preparation

- [ ] 7.1 Promote implemented source/data examples into the maintained testing Skill — verify: `python C:/Users/scottmei/.codex/skills/.system/skill-creator/scripts/quick_validate.py .agents/skills/angelscript-test-guide`
  > Files: `.agents/skills/angelscript-test-guide/SKILL.md`, `.agents/skills/angelscript-test-guide/SKILL_ZH.md`, `.agents/skills/angelscript-test-guide/references/case-authoring.md`, `.agents/skills/angelscript-test-guide/references/inline-source.md`, `.agents/skills/angelscript-test-guide/references/test-code.md`, `.agents/skills/angelscript-test-guide/references/source-history.md`, `.agents/skills/angelscript-test-guide/references/legacy-authoring-notes.md`

  1. Promote only APIs proved by completed framework/adoption nodes. Source each runnable example from actual verified code and preserve correct CQTest class-name composition.
  2. Cover ordinary C++, independent data rows, local AS, exact bytes, shared SourceId/VersionTag, child diagnostic mapping and owned source lifetime without making every test create a manifest.
  3. Keep future live reload/World/backend examples visibly unavailable. Validate both current routes and realistic user requests: one-class helper placement, pure C++ data, malformed input, shared source and focused test execution.
  4. Preserve unrelated existing Skill edits and use one English authority with Chinese navigation.

- [ ] 7.2 Synchronize verified first-slice contracts and prepare completion evidence — verify: `& { $c = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-testing-unified-framework','--type','change','--strict','--json'); if ($c.status -ne 'Succeeded') { throw 'Change validation failed' }; $s = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--specs','--strict','--json'); if ($s.status -ne 'Succeeded') { throw 'Specification validation failed' }; $s }`
  > Files: `openspec/changes/angelscript/refactor-testing-unified-framework/**`, `openspec/specs/angelscript/testing/baseline/**`, `openspec/specs/angelscript/testing/test-code/**`, `openspec/specs/angelscript/testing/source-history/**`, `openspec/specs/angelscript/testing/data-driven/**`, `openspec/specs/angelscript/testing/authoring/**`, `openspec/domains/angelscript/testing/**`
  > File scope: CLI-owned records when required.

  1. Map every first-slice requirement to actual evidence and semantically synchronize only verified deltas. Do not claim deferred runtime behavior or copy this delta over the current baseline.
  2. Record tests actually run, omitted heavier checks with reasons, exact content provenance and completion disposition. Close material issues if any were created; do not manufacture a Review.
  3. Use the matching lifecycle Skill for any later authorized archive. The present planning delivery never selects this node or changes current specs.

## Requirement-to-task mapping

| Contract | Owning nodes |
|---|---|
| TestCode public authority, stable identity, owned bytes, local bundles | 2.1, 2.2, 3.2 |
| Embedded release, admission and plugin consumption | 3.1, 3.3, 6.2 |
| Tagged tree validation, materialization and provenance | 2.3, 2.4, 5.2 |
| Typed source-free/source-backed rows and independent discovery | 4.1, 6.1 |
| Fixture lifetime, capability outcomes, evidence and diagnostics | 4.2, 5.2, 6.2 |
| Reproducible generators | 5.1, 6.1 |
| Class-local authoring and truthful current guidance | 1.1, 6.1, 7.1 |
| Replacement gates, names and legacy isolation | 3.2, 4.1, 6.2 |
| Verified contract synchronization | 7.2 |

The future runtime/reload/backend acceptance described in design is not an
untracked implementation remainder of this first slice. It is the explicit
follow-on boundary and must receive its own product-capability-ready Change.
