---
record: harness-workflow-evaluation-v1
result: passed
change: angelscript/refactor-legacy-runtime-tests-quarantine
closure_kind: completed
input_sha256: 5f59d638ceda5a9a6cade773424f0b9fa3f027287016e5dabee5baeeb80eeb17
captured_at: 2026-09-04T18:02:28.5042464+08:00
---

# Workflow Evaluation

## Lifecycle

- Created one exact product Change from the accepted reconstruction plan, then revised its requirements and Task DAG only when user direction or build/UHT evidence invalidated the current boundary.
- Established separate old/new test gates, proved the original active baseline with three RED failures, hard-disabled legacy startup, and replaced invalid whole-file guards with five source-free parent `.ubtignore` boundaries.
- Preserved 1084 legacy test translation units and 78 headers as readable reference source, kept active module shells and passive generated-TestJIT ABI support outside the ignored trees, and added one three-scenario replacement baseline under `Angelscript.UnitTest.Baseline`.
- Synchronized the complete durable behavior into new current capabilities `angelscript/runtime/startup` and `angelscript/testing/baseline`.

## Verification

- Legacy quarantine audit: PASS; 1084 retained translation units, 78 retained headers, five ignored parents, one replacement source, and 74 generated exclusions.
- `angelscript-test-guide` system Skill validation: PASS.
- Fresh UBT source-discovery build `8cbf894039494de5ad132e5ab00ee870`: PASS, 15/15 actions, `Data.State: Succeeded`, exit 0.
- Ordinary incremental build `42c7a43a791f4a318ae879e1fe210c87`: PASS without `-NoUBTMakefiles`, `Data.State: Succeeded`, exit 0.
- Final Harness `ue.test` Fast run `98b9e708905d4ba7aa399ee1b712ba8e`: 3/3 passed, 0 failed, 0 errors, complete valid report. Global Automation enumeration attached 2436 unrelated MetaSound warnings to the legacy-prefix assertion; the timing evidence records that limitation.
- OpenSpec doctor `888b578447b541ff99d59e072c7dc4f9`: valid, zero errors.
- Strict current-spec validation `3dbf7022dbe044639c1b72d957749f44`: 7/7 valid.
- Final strict active-Change validation `7a5eee986ad04f3cae65456bd6ebd638`: valid with zero issues.

## Startup timing

The ordinary Harness `ue.test` run `a3b3d43df3aa4cb992b438d406871cf4` completed in 27.011 seconds; Fast run `427f9ed3a4ac4588a79c3e55adf9f00d` completed in 26.838 seconds for the same three tests. The 173 ms difference is environment-specific and shows that fresh UE startup dominates the approximately 0.13-second test body. The stable project entry is Harness `ue.test` with `Fast = $true`; the internal `fast-headless` profile name describes implementation characteristics only.

## Material friction and disposition

- UE 5.8 can select UBA for a low-action `-Session` build even though that session form suppresses the global UBA trace. Two failures established the root cause; a bounded `-MaxParallelActions=8` retry preserved Auto concurrency and succeeded through XGE. The general Harness/UE policy fix was rejected from this product Change and remains recorded in the indexed terminal issue.
- Synchronous UE route failures can be returned as failed managed operation data beneath a successful outer Harness dispatch envelope. All retained evidence was checked through `Data.State`, `Data.ExitCode`, and native artifacts. A public envelope redesign was rejected from scope and the interpretation rule was promoted to the focused test Skill reference.
- Complete-file macro guards broke reflected fixtures, and guarding reflected declarations caused UHT rejection. Direct `.ubtignore` markers beside source produced a split UBT/UHT graph. The evidence-driven parent-marker topology and one fresh-discovery build resolved the product isolation boundary.

## Scope boundary

Harness `Quick`, `Performance`, and `Integration`, full UE suites, packaging, Standalone, plugin-wide C++, and legacy test runs were intentionally omitted. The old suites are intentionally absent, no performance/release contract changed, and the exact editor build plus three replacement scenarios directly prove the affected runtime, optional-integration, source-discovery, and namespace behavior.

## Spec synchronization and provenance

The two added delta capabilities were semantically copied into their newly registered current specs with no delta-operation headings. Raw UE requests, logs, metadata, and Automation reports remain under ignored `Saved/Harness/Unreal/Runs/<RunId>/`; `attachments/data/test-startup-timing.md`, the task evidence, and this evaluation retain the compact durable measurements and provenance. No Review was requested. Both admitted Harness issues are terminal, evidence-backed rejected-from-scope records rather than unrecorded deferrals.
