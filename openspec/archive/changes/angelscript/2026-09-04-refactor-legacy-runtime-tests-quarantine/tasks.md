---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
    "2.2": ["2.1"]
    "3.1": ["2.2"]
    "3.2": ["3.1"]
    "3.3": ["3.2"]
    "4.1": ["3.3"]
    "5.1": ["4.1"]
---

## 1. Replacement test boundary

- [x] 1.1 Add separate compile gates and a failing replacement baseline — verify: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`
  > Files: `Config/DefaultAngelscriptCompileOptions.ini`, `Config/DefaultEngine.ini`, `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptCompileOptions.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/NativeCalls/AngelscriptStaticJITNativeCallables.h`, `Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelscriptCQTest.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/AngelscriptIsolationBaselineTests.cpp`

  > Produces: Legacy tests compile with `WITH_ANGELSCRIPT_UNITTESTS=0`; replacement tests compile with `WITH_ANGELSCRIPT_TESTS=1`; the new baseline is registered beneath `Angelscript.UnitTest.Baseline`.

  1. Add the plain UE Automation baseline before changing runtime startup behavior.
  2. Build the exact editor target through Harness.
  3. Run `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Baseline'; TimeoutMs = 600000 }` and retain the expected RED showing the still-active legacy startup paths.
  4. Keep the test independent of CQTest, the legacy engine pool, and `NewVersion` in public identity.

  Evidence: build run `1d3dcb51cce44b1f8a1e503572098c52` succeeded. RED test run `dd21e097c1de406c9ee67f7910d8b1f8` discovered exactly three replacement baseline tests and failed all three for the intended active-runtime, registered-provider/extension/command, and legacy-prefix observations.

## 2. Dormant module startup

- [x] 2.1 Make the core runtime and editor settings-only by default — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Baseline.RuntimeDormantByDefault'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSubsystem.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp`, `Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.h`, `Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.cpp`, `Config/DefaultEngine.ini`

  1. Capture the restart-bound setting in the runtime module and reject compatibility initialization while disabled.
  2. Keep the engine subsystem created but empty and untickable.
  3. Register editor settings before the gate and start or stop all other core/editor services only when enabled.
  4. Rebuild through Harness before running the exact test prefix.

  Evidence: editor build run `95f9c56f781b4ef0b01f04ee36e0dade` succeeded. Harness `ue.test` Fast run `a278e783518343659e7bbb5373669402` discovered and passed the one exact Runtime dormant scenario; the managed native process duration was `26740 ms`.

- [x] 2.2 Lock legacy startup dormant and suppress JIT/GameplayTags registration — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Baseline.RuntimeDormantByDefault+Angelscript.UnitTest.Baseline.OptionalIntegrationsDormantByDefault'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Config/DefaultEngine.ini`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/AngelscriptIsolationBaselineTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTestJIT/AngelscriptTestJITModule.cpp`, `Source/AngelscriptJIT/AngelscriptJITModule.cpp`, `Plugins/AngelscriptGameplayTags/Source/AngelscriptGameplayTags/Private/AngelscriptGameplayTagsModule.cpp`, `Plugins/AngelscriptGameplayTags/Source/AngelscriptGameplayTagsEditor/Public/AngelscriptGameplayTagsEditorModule.h`, `Plugins/AngelscriptGameplayTags/Source/AngelscriptGameplayTagsEditor/Private/AngelscriptGameplayTagsEditorModule.cpp`

  1. Remove the newly introduced recovery setting and make the shared runtime decision a fixed dormant reconstruction gate.
  2. Gate both JIT provider registrations with that decision and unregister only registered providers.
  3. Gate GameplayTags extension/delegate registration and clean up only registrations that occurred.
  4. Leave the GAS runtime module and generated JIT sources unchanged.
  5. Rebuild through Harness before running the exact baseline prefix.

  Evidence: two ordinary Auto builds (`237c0c9ef9984fdfbd1ecb29ec49e91f`, `012f47764e614d8fb4dc243329e19eb2`) exposed the separately indexed UE 5.8 `-Session`/low-action UBA incompatibility before compilation. The bounded Auto/XGE-threshold retry `268038d31f8b4eb68d612852b4485685` built successfully without disabling UBA or XGE. Harness `ue.test` Fast run `ad12f23e5b29400fac9f419294d7c0e4` discovered and passed exactly the Runtime and Optional scenarios in `26785 ms`.

## 3. Legacy test quarantine

- [x] 3.1 Inventory the complete legacy test corpus and prove the initial guard boundary — verify: `& ./openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/attachments/scripts/Test-LegacyTestQuarantine.ps1`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/**`, `Plugins/Angelscript/Source/AngelscriptEditor/Legacy/**`, `Plugins/Angelscript/Source/AngelscriptTestJIT/AngelscriptTestJITProbes.cpp`, `Plugins/AngelscriptGameplayTags/Source/AngelscriptGameplayTagsTest/Private/Legacy/**`, `Plugins/AngelscriptGAS/Source/AngelscriptGASTest/Private/Legacy/**`, `Source/AngelscriptProjectTest/Legacy/**`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/attachments/scripts/Test-LegacyTestQuarantine.ps1`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/attachments/INDEX.md`

  > Constraints: Exclude `AngelscriptTestModule.cpp`, `AngelscriptGameplayTagsTestModule.cpp`, `AngelscriptGASTestModule.cpp`, `AngelscriptTest/NewVersion/**`, and every generated JIT artifact from the old-corpus inventory.

  1. Enumerate every owned legacy test translation unit separately from module shells, replacement tests, and generated JIT artifacts.
  2. Use the initial complete-file guard attempt as RED design evidence, then preserve the inventory when Task `3.2` replaces that invalid mechanism.
  3. Keep the audit scoped to the declared legacy corpus and explicit exclusions.

  Evidence: the audit first failed because no legacy file had the required byte-zero guard, then passed after inventorying exactly `1085` translation units: AngelscriptTest `1016`, AngelscriptEditor `35`, AngelscriptTestJIT `1`, GameplayTagsTest `6`, GASTest `25`, and host project tests `2`. It also verified `1` replacement source, all `3` module exclusions, and `74` generated JIT exclusions. Task `3.2` later superseded the guard implementation after link and UHT evidence proved a complete-file custom macro was not a valid final boundary; the inventory remains the preserved output of this completed task.

- [x] 3.2 Isolate the old test-module framework and prove the replacement baseline — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Baseline'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`, `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTestModule.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/AngelscriptIsolationBaselineTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/Legacy/**`, `Plugins/Angelscript/Source/AngelscriptEditor/Legacy/**`, `Plugins/Angelscript/Source/AngelscriptTestJIT/AngelscriptTestJITProbes.cpp`, `Plugins/AngelscriptGameplayTags/Source/AngelscriptGameplayTagsTest/Private/Legacy/**`, `Plugins/AngelscriptGAS/Source/AngelscriptGASTest/Private/Legacy/**`, `Source/AngelscriptProjectTest/Legacy/**`, `.agents/skills/angelscript-test-guide/SKILL.md`, `.agents/skills/angelscript-test-guide/references/legacy-source-isolation.md`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/attachments/scripts/Test-LegacyTestQuarantine.ps1`

  1. Keep the TestJIT probe implementation compiled as passive ABI support after the generated-object link failure proves it is not an independently removable legacy test.
  2. Retain complete old test trees beneath source-free `.ubtignore`-marked `Legacy/` parents while keeping the module shell and `NewVersion` outside that boundary.
  3. Keep legacy test-module headers, CQTest force include, engine-pool startup, and legacy-only dependencies behind `WITH_ANGELSCRIPT_UNITTESTS`, and record the verified directory-isolation rule in the project test Skill.
  4. Re-run the structural audit, then rebuild `AngelscriptProjectEditor Win64 Development` through Harness with fresh UBT source discovery for the topology transition.
  5. Run the full replacement baseline prefix and require every scenario to pass.
  6. Record the exact Harness run IDs and report paths in completion evidence.

  Evidence: the final quarantine audit passed with `1084` retained legacy translation units (`1016` AngelscriptTest, `35` AngelscriptEditor, `6` GameplayTags, `25` GAS, `2` host), `78` headers, five source-free ignored parents, one replacement source, and 74 generated exclusions. The focused test Skill passed `quick_validate.py`. Fresh-discovery managed build `8cbf894039494de5ad132e5ab00ee870` completed 15/15 actions with `Data.State: Succeeded` and `Data.ExitCode: 0`. Harness Fast run `427f9ed3a4ac4588a79c3e55adf9f00d` discovered the exact three-test baseline and completed with 3 passed, 0 failed, and a valid report at `Saved/Harness/Unreal/Runs/427f9ed3a4ac4588a79c3e55adf9f00d/AutomationReport/index.json`.

- [x] 3.3 Measure and adopt the fastest supported focused test launch — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Baseline'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/design.md`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/specs/angelscript/testing/baseline/spec.md`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/tasks.md`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/attachments/data/test-startup-timing.md`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/attachments/INDEX.md`

  1. Run the same passing near-zero-work baseline once with the ordinary Harness `ue.test` profile and once with `Fast = $true` in fresh Harness-managed processes.
  2. Record the full process durations, launch arguments, test count, test-body duration when observable, and environmental limitations.
  3. Adopt exact-prefix Harness `ue.test` Fast runs for focused replacement tests; do not add a custom commandlet or persistent process in this isolation Change.

  Evidence: ordinary Harness run `a3b3d43df3aa4cb992b438d406871cf4` passed 3/3 in `27011 ms` with `0.135000 s` of test-body time. Harness Fast run `427f9ed3a4ac4588a79c3e55adf9f00d` passed the same 3/3 in `26838 ms` with `0.129320 s` of test-body time. The observed 173 ms (0.64 percent) saving and exact launch differences are recorded in `attachments/data/test-startup-timing.md`; the measurement is explicitly environment-specific and the Fast profile is adopted through the stable `ue.test -Fast` interface.

## 4. Project routing and durable contract

- [x] 4.1 Add the minimal project routing invariant and validate the active record — verify: `Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-legacy-runtime-tests-quarantine','--type','change','--strict','--json')`
  > Files: `AGENTS.md`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/proposal.md`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/design.md`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/specs/**/*.md`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/tasks.md`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/attachments/INDEX.md`

  1. Keep `AGENTS.md` thin and route the temporary legacy/new boundary to the current durable specs.
  2. Keep the project test Skill update limited to the focused legacy-source isolation reference; do not modify `Documents/`, `Wiki/`, or `openspec-old/`.
  3. Strictly validate the Change and its Task DAG.

  Evidence: root `AGENTS.md` remains a 36-line project router and now names only the reconstruction baseline, macro ownership, replacement namespace, and authoritative spec/Skill destinations. The test Skill change is limited to its entry routing and focused `legacy-source-isolation.md` reference, which passed the Skill quick validator. Harness strict Change validation run `085839792557483aa6c0ba9cd1a434f0` returned `valid: true`, and TaskPlan run `c985b26aec924adea46f4dc5eb6b7dea` parsed all eight DAG nodes with Task `5.1` as the next Ready node.

## 5. Completion and synchronization

- [x] 5.1 Re-run scoped proofs and synchronize the durable specifications — verify: `Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--specs','--strict','--json')`
  > Files: `openspec/specs/angelscript/runtime/startup/spec.md`, `openspec/specs/angelscript/testing/baseline/spec.md`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/tasks.md`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/attachments/INDEX.md`, `openspec/changes/angelscript/refactor-legacy-runtime-tests-quarantine/attachments/data/workflow-evaluation.md`

  1. Re-run the quarantine audit, exact editor build, full `Angelscript.UnitTest.Baseline` prefix, strict Change validation, and OpenSpec doctor.
  2. Record actual run IDs, results, omitted heavier tests, and reasons in the Change evidence.
  3. Semantically merge both delta specs into current specs and validate all current specs strictly.
  4. Complete the Task DAG, capture a fresh terminal workflow evaluation, and pass the Harness terminal evolution gate before archive.

  Evidence: the final quarantine audit passed with 1084 retained legacy translation units and all five ignored-parent boundaries intact. Ordinary incremental managed build `42c7a43a791f4a318ae879e1fe210c87` completed with `Data.State: Succeeded`, `Data.ExitCode: 0`, and no `-NoUBTMakefiles`, proving the cached source-discovery path remains valid. Final Harness Fast test run `98b9e708905d4ba7aa399ee1b712ba8e` passed the exact three-test baseline with 0 failures, 0 errors, and a valid Automation report; 2436 unrelated MetaSound tag-registration warnings emitted by global registry enumeration are explained in the timing attachment. OpenSpec doctor run `888b578447b541ff99d59e072c7dc4f9`, strict current-spec validation run `3dbf7022dbe044639c1b72d957749f44`, and strict Change validation run `de8bf43d127d4b1680c9dab87b781048` all passed. Delta capabilities were semantically synchronized into `angelscript/runtime/startup` and `angelscript/testing/baseline`.

  Intentionally omitted: Harness `Quick`, `Performance`, and `Integration`; full UE suites or Automation prefixes; Unreal packaging; Standalone, plugin, and C++ legacy tests. Those scopes do not directly prove this reconstruction boundary, the legacy suites are intentionally excluded, no performance or release contract changed, and the exact target build plus replacement baseline provide the affected product evidence.
