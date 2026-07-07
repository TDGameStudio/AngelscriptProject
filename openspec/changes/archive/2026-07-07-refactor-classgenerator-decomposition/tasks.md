# ClassGenerator Decomposition — Tasks

> Current scope is the first-stage, behavior-preserving `.cpp` phase split for `AngelscriptClassGenerator.cpp`. `AngelscriptClassGenerator.h` remains the single declaration source for `FAngelscriptClassGenerator`. `ASClass` / `UASFunction` and UHT-facing dispatch declarations are follow-up work, not part of this change.

## 1. Baseline and map

- [x] 1.1 <!-- Non-TDD --> Capture a pre-refactor behavior baseline for `ClassGenerator`, `HotReload`, `NativeScriptHotReload.Phase2A/2B`, `Inheritance`, `Interface`, `Component`, `Actor`, `Delegate`, and `GC`; recorded in `baseline.md`.
- [x] 1.2 <!-- Non-TDD --> Finalize `decomposition-map.md` with phase ownership, static helper/constant ownership, and do-not-touch ownership boundaries.
- [x] 1.3 <!-- Non-TDD --> Confirm the single-header declaration boundary: phase units include `AngelscriptClassGenerator.h`; private members stay there in this pass.

## 2. Characterization before movement

> Tests assert externally observable compile/reload/reflection/runtime behavior. They do not assert private generator state.

- [x] 2.1 <!-- TDD --> Gap 1 reload dependency propagation — single-hop, multi-hop, cyclic, super-class, method signature, container subtype, delegate, and no-over-escalation cases in `AngelscriptClassGeneratorReloadPropagationTests.cpp`.
- [x] 2.2 <!-- TDD --> Gap 2 interface-list-change classification — add/remove/reorder/no-change/first-compile cases in `AngelscriptClassGeneratorInterfaceListTests.cpp`.
- [x] 2.3 <!-- TDD --> Gap 3 `VerifyClass` observable branches — component metadata, editor-only diagnostics, `NotAngelscriptSpawnable`, deprecated warning, and helper-module diagnostics in `AngelscriptComponentMetadataValidationTests.cpp`.
- [x] 2.4 <!-- TDD --> Gap 4 `Error` / name-conflict paths — struct-vs-nonstruct conflict, class/native collision, and rejected reload recovery in `AngelscriptClassGeneratorNameConflictTests.cpp`.
- [x] 2.5 <!-- TDD --> Gap 5 argument/return marshalling matrix — metadata, ref/out flags, POD, object ownership, float/double runtime behavior, and native float bridge in `AngelscriptASFunctionArgumentMatrixTests.cpp`.
- [x] 2.6 <!-- TDD --> Gap 6 `ResolveCodeSuperForProperty` — reflected property class / meta-class behavior covered through `AngelscriptASFunctionArgumentMatrixTests.cpp`.
- [x] 2.7 <!-- Non-TDD --> Gap 7 `CreateDebugValuePrototype` assessed; no stable public debugger observation was introduced for this phase split, so the conditional gap is recorded in `verification.md` without widening production API.
- [x] 2.8 <!-- Non-TDD --> Gap 8 live-instance reinstancing risk covered by the existing affected HotReload / Actor / GC regression set for this movement; exact destructor-count observation remains deferred until a stable public seam exists.
- [x] 2.9 <!-- Non-TDD --> Gaps 9–10 positive component wiring / namespaced class generation assessed; no additional production seam or ASClass movement is included in this first-stage split, and remaining direct coverage is tracked as follow-up.

## 3. Split `AngelscriptClassGenerator.cpp` by phase

- [x] 3.1 <!-- Non-TDD --> Keep `AngelscriptClassGenerator.cpp` as the driver: `AddModule`, query helpers, reload orchestration, `EnsureReloaded*`, `EnsureClassFinalized`, and public reload status queries.
- [x] 3.2 <!-- Non-TDD --> Extract `_Analyze.cpp`: analysis, enum analysis, module setup, module analysis, rename redirect, and reload-module query member definitions.
- [x] 3.3 <!-- Non-TDD --> Extract `_ReloadPlanning.cpp`: reload dependency propagation, interface-list/reflected-type comparison, reload requirement helpers, and full-reload decision member definitions.
- [x] 3.4 <!-- Non-TDD --> Extract `_FullReload.cpp`: full-reload class/struct/enum/delegate creation, redirect replacement, removal, metadata copy, and full-reload execution member definitions.
- [x] 3.5 <!-- Non-TDD --> Extract `_SoftReload.cpp`: soft-link, prepare, soft-reload execution, function reload, and type reload member definitions.
- [x] 3.6 <!-- Non-TDD --> Extract `_Generation.cpp`: property generation, function return/argument generation, `GetDataFor`, and code-super resolution member definitions.
- [x] 3.7 <!-- Non-TDD --> Extract `_Finalize.cpp`: class finalization, actor/component/object finalization, `VerifyClass`, tick/default-object setup, static-class setup, construct/default function update, and namespaced type lookup member definitions.
- [x] 3.8 <!-- Non-TDD --> Extract `_Reinstancing.cpp`: script object destruction/reinitialization, AS reference detection, debug-value prototype creation, and removed-class cleanup member definitions.
- [x] 3.9 <!-- Non-TDD --> Add `AngelscriptClassGeneratorShared.h` only for shared constants/helpers; it does not declare private `FAngelscriptClassGenerator` members.

## 4. Second-stage split decision

- [x] 4.1 <!-- Non-TDD --> Defer `ASClass` / `UASFunction` / `UASFunction_*` UHT-facing declaration movement to a follow-up OpenSpec change. This change stops at the green ClassGenerator phase split.

## 5. Cleanup

- [x] 5.1 <!-- Non-TDD --> Scan the moved ClassGenerator units for unambiguously owned dead code. No safe current-scope cleanup was required; unrelated haze/de-globalization markers remain untouched.

## 6. Verification

- [x] 6.1 <!-- Non-TDD --> `git -C "D:\Workspace\AngelscriptProject\Plugins\Angelscript" diff --check -- Source/AngelscriptRuntime/ClassGenerator Source/AngelscriptTest/ClassGenerator Source/AngelscriptTest/Shared` passed.
- [x] 6.2 <!-- Non-TDD --> `./Tools/RunBuild.ps1 -Label classgen-phase-split-fix1 -NoXGE -TimeoutMs 1800000` passed.
- [x] 6.3 <!-- Non-TDD --> Combined characterization after split passed: `28/28`.
- [x] 6.4 <!-- Non-TDD --> Affected themes after split passed: `304/304` (`299` success + `5` success-with-warnings, `0` failed).
- [x] 6.5 <!-- Non-TDD --> `openspec validate "refactor-classgenerator-decomposition" --strict --json` passes after final record updates.