---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": []
    "3.1": ["1.2", "2.1"]
    "3.2": ["3.1"]
    "4.1": ["3.2"]
---

## 1. Session-compatible build planning

- [x] 1.1 Add the build-only UBA guard with TDD — verify: `pwsh -NoProfile -File .agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag Build`
  > Files: `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/Operations.ps1`

  1. Add failing typed-build and generic-build plan assertions for one owned `-NoUBA`, while QueryTargets remains unchanged.
  2. Observe the focused RED failure against current planning.
  3. Add the smallest build-capability guard and rerun the same fixture GREEN.

  Evidence: the focused fixture first failed because the typed build plan had 16 arguments instead of the expected 17 and no `-NoUBA`. After the build-only guard was added, `UnrealEngineDevelop.Tests.ps1 -Tag Build` passed, proving typed and generic builds contain exactly one guard while QueryTargets contains none.

  Superseded output: UE 5.8 source inspection proved `-NoUBA` still constructs the fallback `UBAExecutor` with detouring disabled, so it cannot prevent Session-triggered trace initialization failure. Task `1.2` replaces the implementation; this completed RED/GREEN evidence remains the rejected-path record.

- [x] 1.2 Replace recursive Session correlation with contained run identity — verify: `pwsh -NoProfile -File .agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag ConcurrencyProgress`
  > Files: `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/Operations.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/Engine.ps1`

  1. Restore the rejected `NoUBA` implementation to the pre-task executor policy.
  2. Add failing plan and process-correlation fixtures requiring no top-level Session, an exact contained log run identity, matching native PID/request metadata, and rejection of forged log paths.
  3. Remove Session from UBT construction, implement fail-closed contained-log correlation, and rerun Build plus ConcurrencyProgress fixtures GREEN.

  Evidence: after restoring the rejected `NoUBA` change, the Build fixture failed because the current plan still appended one `-Session`, and ConcurrencyProgress failed because the old recognizer rejected an otherwise exact contained-log command line without Session. The final Build and ConcurrencyProgress fixtures both passed after all top-level UBT Session arguments were removed and correlation required the run ID from the exact contained UBT log together with mapped project, native PID, request/metadata identity, and path validation. External-log and wrong-PID cases remained unrecognized.

## 2. Truthful synchronous envelopes

- [x] 2.1 Propagate terminal UE execution failures with TDD — verify: `pwsh -NoProfile -File .agents/skills/harness/tests/Harness.Tests.ps1`
  > Files: `.agents/skills/harness/tests/Harness.Tests.ps1`, `.agents/skills/harness/scripts/Harness.psm1`

  1. Add a contained leaf fixture for synchronous terminal failure, asynchronous non-terminal dispatch, observation, cancellation, and success.
  2. Observe the failed-operation fixture RED against the current successful outer envelope.
  3. Add route-bounded terminal mapping and rerun the same fixture GREEN.

  Evidence: the contained leaf fixture first observed outer `Succeeded` for a returned `Failed` `ue.build`. After the dispatcher mapping was added, `Harness.Tests.ps1` passed for all five synchronous execution routes, terminal failure variants, preserved exit/data/artifacts, successful non-terminal dispatch, failed-run observation, cancellation-command success, and ordinary success.

## 3. Contract and real boundary verification

- [x] 3.1 Validate the shared dispatcher protocol — verify: `pwsh -NoProfile -File .agents/skills/harness/tests/Protocol.Tests.ps1`
  > Files: `.agents/skills/harness/tests/Protocol.Tests.ps1`, `openspec/changes/harness/fix-unreal-execution-reliability/**`, `openspec/archive/changes/angelscript/2026-09-04-refactor-legacy-runtime-tests-quarantine/attachments/INDEX.md`

  1. Repair the immediately preceding archive's missing script index entry exposed by the protocol fixture and retain the friction in this Change.
  2. Run the focused public-envelope protocol checks after both direct fixtures pass.
  3. Strictly validate the active Change and its Task DAG.

  Evidence: Protocol initially rejected the immediately preceding archive because its retained quarantine script was not indexed. Adding that exact missing navigation entry made `Protocol.Tests.ps1` pass without weakening archive rules. Strict active-Change validation run `16f517e3f518481a9cde7c48d16c2143` returned valid with zero issues.

- [x] 3.2 Prove a real low-action editor build without caller workaround — verify: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`
  > Files: `Saved/Harness/Unreal/Runs/<run-id>/**`, `openspec/changes/harness/fix-unreal-execution-reliability/tasks.md`

  1. Invoke the configured editor target without `Session`, `MaxParallelActions`, raw `NoUBA`, or other caller executor workarounds.
  2. Require a truthful outer envelope and managed terminal state, and inspect the contained UBT evidence for executor initialization.

  Evidence: ordinary managed build `aa0b22a50b554a76acfb289b1079cf71` ran without Session or executor/threshold overrides, was recognized live through contained-log correlation, selected XGE, and passed 32/32 actions in `105.64 s`. A temporary one-line host-source probe then produced low-action managed build `d9c2e144acc849d4aa327fcc41ba7d1a`; its queued dispatch and terminal status envelopes were truthful, it selected `Unreal Build Accelerator local executor`, executed 6/6 actions marked `[NoUba]`, and passed in `6.16 s` without the former trace error. The probe was removed and the source content hash again equals HEAD.

## 4. Durable completion

- [x] 4.1 Synchronize and verify the durable Harness contract — verify: `Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--specs', '--strict', '--json')`
  > Files: `openspec/specs/harness/unreal/spec.md`, `openspec/changes/harness/fix-unreal-execution-reliability/tasks.md`, `openspec/changes/harness/fix-unreal-execution-reliability/attachments/INDEX.md`, `openspec/changes/harness/fix-unreal-execution-reliability/attachments/data/workflow-evaluation.md`

  1. Re-run both direct fixtures, protocol coverage, strict active-Change validation, and the final real-build proof as needed for final content identity.
  2. Semantically merge the delta into `harness/unreal` and strictly validate current specs.
  3. Record exact results, intentionally omitted heavier tests, and final workflow evaluation before the terminal evolution gate.

  Evidence: final Harness dispatcher, Unreal Build, ConcurrencyProgress, direct Integration, Protocol, and HarnessEvolution fixtures all passed. Real managed builds `aa0b22a50b554a76acfb289b1079cf71` (XGE, 32/32) and `d9c2e144acc849d4aa327fcc41ba7d1a` (local UBA fallback with `[NoUba]`, 6/6) passed without Session or caller executor workarounds. Workflow validation `0f3ad6bb768042b49cbdb121cb3536fa`, doctor `62c8abe300f64f4bbb85b895cb15fa62`, strict current `harness/unreal` spec validation `0df260d5c73f4b678b76d0d7b2735bdd`, and strict all-spec validation `26ff6b861cbf4aaea56ad5e1a3350d81` passed. The delta is semantically synchronized into `openspec/specs/harness/unreal/spec.md`.

  Intentionally omitted: `Test-Harness.ps1 -Profile Quick`, `Performance`, and `Integration`; full UE Automation or suites; Unreal packaging; Standalone, plugin, and C++ product tests. The direct Harness/Unreal module fixtures, direct Integration tag, protocol/evolution tests, and two matching real builds prove the affected dispatcher, process-correlation, and UE executor boundary; no performance, release, Automation, or product-code behavior changed.
