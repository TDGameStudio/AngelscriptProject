# HotReload Pipeline Refactor Implementation Plan

> Plan-only map. Do not implement in this recording session. **Do not start production ClassGenerator rewrites before** `test-as-hotreload-script-corpus` Wave A goldens. Dual-repo later: code in `Plugins/Angelscript`.

**Goal:** Freeze HotReload stage ownership and sequence the real leftovers (test pairs, identity, Editor `FReloadState` / helper includes). Do not resplit ClassGenerator as the first move. Do not add HotReload to the DataDriven engine-profile harness.

**Architecture:** Seven-stage pipeline; Runtime compile/plan/apply; Editor watch + recover + BlueprintImpact; tests as evidence. Sibling test change owns pair files and `HotReload.Corpus` COMPLEX.

**Spec:** `specs/as-hotreload-pipeline-boundaries/spec.md`, `specs/as-hotreload-editor-recovery-isolation/spec.md`.

## Global Constraints

- Do not change `EReloadRequirement` lattice or planner `PropagateAll` policy.
- Do not merge ClassReloadHelper into Runtime.
- Do not add `hot-reload` as a DataDriven profile.
- Verify only via `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, `Tools\RunTestSuite.ps1`.
- Chinese-first docs at apply time.
- Re-count editor branches; do not trust 2026-06-30 line counts for `AngelscriptClassGenerator.cpp`.

---

## 1. Map freeze (this change’s docs, no behavior)

- [ ] 1.1 <!-- Non-TDD --> Point `Documents/Knowledges/ZH/RT_HotReload.md` (and EN pointer if present) at `openspec/changes/refactor-as-hotreload-pipeline/research/hotreload-refactor-map.md` and the seven-stage table in `design.md`.
- [ ] 1.2 <!-- Non-TDD --> Add a dated note on `Documents/Guides/RuntimeArchitectureAudit_20260630.md` §D: ClassGenerator is already split; remaining work is sequenced here; re-count `WITH_EDITOR` / `GIsEditor` / `bIsHotReload`.
- [ ] 1.3 <!-- Non-TDD --> Chinese-first: `AGENTS_ZH.md` or Test layering ZH — HotReload is not DataDriven `vm`; corpus is sibling `test-as-hotreload-script-corpus`.

## 2. Prerequisite test goldens (other change)

- [ ] 2.1 <!-- Non-TDD --> Block until `test-as-data-driven-engine-harness` task 2 (`FAngelscriptTestScriptCorpus`) is green.
- [ ] 2.2 <!-- Non-TDD --> Block until `test-as-hotreload-script-corpus` tasks 3.3–3.4 and 4.3 are green (`no-change`, `soft-requirement`, `function-removed`, classification dual-run).
- [ ] 2.3 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.Corpus" -Label hotreload-corpus-gate -TimeoutMs 600000` and `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Generator.ReloadPlanning" -Label hotreload-planner-gate -TimeoutMs 600000`. Require zero failures before any production slice.

## 3. Identity audit (behavior-neutral unless proven)

- [ ] 3.1 <!-- TDD --> Add `AngelscriptHotReloadIdentityTests.cpp` (or extend Corpus catalog tests) proving analyze goldens still use catalog `filename` (`ReloadNoChangeMod.as`) and record TestCorpus virtual path `/Angelscript/Memory/TestCorpus/HotReload/no-change.as` on the pair. Do not switch `CompileAnnotatedModuleFromMemory` Filename to the long path in this task.
- [ ] 3.2 <!-- Non-TDD --> Read `CompileAnnotatedModuleFromMemory` / preprocessor section names and `QueueScriptFileChanges` logical paths. Write `openspec/changes/refactor-as-hotreload-pipeline/research/identity-apply-notes.md` with the decision: keep short filename **or** switch with a follow-up TDD task. Do not switch in the same PR as the notes unless 3.1 is extended and green.
- [ ] 3.3 <!-- TDD --> `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.Corpus" -Label hotreload-identity -TimeoutMs 600000`.

## 4. ClassReloadHelper header hygiene (behavior-neutral)

- [ ] 4.1 <!-- TDD --> Snapshot `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label hotreload-helper-baseline -TimeoutMs 1200000` (Heavy). Record counts in `verification.md`.
- [ ] 4.2 <!-- TDD --> Move UnrealEd / BlueprintActionDatabase / ComponentTypeRegistry includes out of `ClassReloadHelper.h` into `.cpp` or a private header. Keep `WITH_DEV_AUTOMATION_TESTS` hooks. Failing compile of a test TU that only included the `.h` for UnrealEd types is expected — fix those TUs to include what they use.
- [ ] 4.3 <!-- TDD --> Re-run 4.1 prefix. Require same pass/fail/skip shape as baseline (zero new failures). `EReloadRequirement` unchanged.

## 5. FReloadState partition (only if 2.x and 4.x are green)

- [ ] 5.1 <!-- TDD --> Extend `AngelscriptHotReloadMultiEngineHooksTests` (or Corpus) with a failing case if two Editor engines overlapping reload would clobber static `FReloadState` — **or** assert the documented single-active-editor-engine invariant. Choose one; do not silently keep the static without a test.
- [ ] 5.2 <!-- TDD --> If overlapping engines are in scope: key `FReloadState` by engine (or equivalent) until 5.1 passes. If invariant is chosen: add the assert and skip partition.
- [ ] 5.3 <!-- TDD --> `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label hotreload-reloadstate -TimeoutMs 1200000`.

## 6. ClassGenerator editor-branch audit (optional, last)

- [ ] 6.1 <!-- Non-TDD --> Re-count `WITH_EDITOR` / `GIsEditor` / `bIsHotReload` / `WITH_DEV_AUTOMATION_TESTS` under `ClassGenerator/`. Write counts into `research/editor-branch-count.md`.
- [ ] 6.2 <!-- TDD --> Move **one** proven Editor-recovery leak from Runtime to Editor per PR, with a HotReload or Generator test that fails if the branch is deleted incorrectly. Do not bulk-move 47 sites.
- [ ] 6.3 <!-- TDD --> After each move: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label hotreload-branch-move -TimeoutMs 1200000` plus `Angelscript.TestModule.Generator`.

## 7. Closure

- [ ] 7.1 <!-- Non-TDD --> Update `Documents/UnitTest/UnitTest.md` HotReload row: pipeline change vs corpus sibling vs DataDriven harness.
- [ ] 7.2 <!-- Non-TDD --> Commit submodule then parent gitlink only if the user asks.
