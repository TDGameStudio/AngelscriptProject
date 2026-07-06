# AS Generator Artifact Boundaries — Tasks

## 1. Boundary map

- [ ] 1.1 <!-- Non-TDD --> Inventory `ASClass.h/.cpp` symbols and classify each under `UASClass`, `UASFunction`, `UASFunction_*` dispatch variants, or out-of-scope support.
- [ ] 1.2 <!-- Non-TDD --> Record the final movement map with UHT declaration ownership and include-boundary risks.
- [ ] 1.3 <!-- Non-TDD --> Confirm this change does not rename `ClassGenerator` directories or automation prefixes.

## 2. Test hygiene before movement

- [x] 2.1 <!-- Non-TDD --> Audit `AngelscriptTest/ClassGenerator` for `UnitTest.md` violations: method-level `ASTEST_CREATE_ENGINE`, method-level `ASTEST_RESET_ENGINE`, raw `TEXT(R"AS")` fixtures, missing public hook visibility, and class-external main-flow wrappers.
- [x] 2.2 <!-- Non-TDD --> Normalize `AngelscriptDefaultStatementSafetyTests.cpp` to class-level engine lifecycle and `ASTEST_AS` inline fixtures without changing diagnostics coverage.
- [x] 2.3 <!-- Non-TDD --> Batch remaining non-compliant files by risk in `test-hygiene-audit.md`: simple lifecycle/raw-AS files first, large ASFunction/ASClass matrix files later.
- [x] 2.4 <!-- Non-TDD --> Normalize the first small artifact/lifecycle batch: `AngelscriptASClassTickSettingsTests.cpp`, `AngelscriptASStructDiscardTests.cpp`, `AngelscriptASGeneratedTypeIdentityTests.cpp`, `AngelscriptASClassReplicationTests.cpp`, `AngelscriptASFunctionWorldContextTests.cpp`, and `AngelscriptInterfaceDispatchBridgeTests.cpp`.
- [x] 2.5 <!-- Non-TDD --> Normalize script class/struct lifecycle and hot-reload files from `test-hygiene-audit.md`, preserving clean-engine isolation for script class creation/shape cases.
- [x] 2.6 <!-- Non-TDD --> For each normalized batch, run the narrowest affected `Angelscript.TestModule.ClassGenerator.*` or adjacent `Angelscript.TestModule.ScriptClass` prefix before using the tests as movement guards.
- [x] 2.7 <!-- Non-TDD --> Normalize remaining ASFunction behavior matrix files from `test-hygiene-audit.md`.
- [x] 2.8 <!-- Non-TDD --> Normalize the first ASClass behavior matrix batch from `test-hygiene-audit.md`: helper, reference-schema, metadata, and construction-context tests.
- [x] 2.9 <!-- Non-TDD --> Normalize remaining ASClass construction/component behavior files from `test-hygiene-audit.md`.
- [x] 2.10 <!-- Non-TDD --> Normalize the root `ClassGeneratorTests.cpp` entrypoint to CQTest class-level engine lifecycle and record the residual high-risk files as movement guards rather than hard hygiene violations.
- [x] 2.11 <!-- Non-TDD --> Remove residual method-local namespace imports across ClassGenerator tests and correct generated-artifact shared helper ownership before artifact movement.
- [x] 2.12 <!-- Non-TDD --> Close high-priority generated-artifact test structure issues: `AngelscriptASFunctionOptimizedCallTests.cpp`, `AngelscriptASFunctionDispatchTests.cpp`, `AngelscriptASFunctionProcessEventTests.cpp`, `AngelscriptASGeneratedTypeIdentityTests.cpp`, `AngelscriptASClassReferenceSchemaTests.cpp`, and `AngelscriptLiteralAssetPostInitTests.cpp`.
- [x] 2.13 <!-- Non-TDD --> Close residual namespace/helper externalization in script class and metadata tests: `AngelscriptASClassMetadataTests.cpp`, `AngelscriptScriptClassStructureTests.cpp`, `AngelscriptScriptClassShapeTests.cpp`, `AngelscriptScriptClassCreationTests.cpp`, `AngelscriptComposeOntoClassTests.cpp`, and `AngelscriptScriptStructHotReloadTests.cpp`.
- [x] 2.14 <!-- Non-TDD --> Close ASClass construction-family structure issues: `AngelscriptASClassActorConstructionTests.cpp`, `AngelscriptASClassComponentConstructionTests.cpp`, `AngelscriptASClassObjectConstructionTests.cpp`, `AngelscriptASClassConstructionContextTests.cpp`, and `AngelscriptASClassHelperTests.cpp`.
- [x] 2.15 <!-- Non-TDD --> Close light residual structure issues in `AngelscriptASStructDiscardTests.cpp`, `AngelscriptASClassReplicationTests.cpp`, and `AngelscriptInterfaceDispatchBridgeTests.cpp`.
- [x] 2.16 <!-- Non-TDD --> Re-run the ClassGenerator hard-pattern and structure scans after structural cohesion cleanup, then keep only documented isolation exceptions in `test-hygiene-audit.md`.

## 3. Characterization before movement

- [x] 3.1 <!-- TDD --> Add namespaced-UCLASS positive generation coverage through public generated `UClass`/reflection behavior.
- [ ] 3.2 <!-- TDD --> Add narrow positive coverage for default/override component wiring details not already covered by `ASClassComponentMetadata` tests.
- [ ] 3.3 <!-- Non-TDD --> Assess debugger prototype observability; add a test only if a stable public seam exists without widening production API.
- [x] 3.4 <!-- Non-TDD --> Run focused baseline tests for `Angelscript.TestModule.ClassGenerator.ASClass`, `ASFunction`, and affected `ClassGenerator` cases.

## 4. Split generated artifact units

- [ ] 4.1 <!-- Non-TDD --> Move `UASFunction` base implementation into an `ASFunction` unit while preserving public declarations and behavior.
- [ ] 4.2 <!-- Non-TDD --> Move explicit `UASFunction_*` dispatch declarations/implementations into a dispatch-variant unit without macro-only UHT declarations.
- [ ] 4.3 <!-- Non-TDD --> Leave `ASClass.cpp` focused on `UASClass` lifecycle, construction/defaults, tick, replication, GC/reference schema, and class metadata helpers.
- [ ] 4.4 <!-- Non-TDD --> Keep `ASStruct` and redirects out of scope unless a compile boundary forces a minimal include adjustment.

## 5. Verification

- [x] 5.1 <!-- Non-TDD --> `git -C "D:\Workspace\AngelscriptProject\Plugins\Angelscript" diff --check -- Source/AngelscriptRuntime/ClassGenerator Source/AngelscriptTest/ClassGenerator` passes.
- [x] 5.2 <!-- Non-TDD --> `& "D:\Workspace\AngelscriptProject\Tools\RunBuild.ps1" -Label as-generator-artifact-boundaries -NoXGE -TimeoutMs 1800000` passes.
- [x] 5.3 <!-- Non-TDD --> Focused `ClassGenerator.ASClass` / `ASFunction` characterization tests pass.
- [ ] 5.4 <!-- Non-TDD --> Affected `ClassGenerator` and `HotReload` regression subset passes.
- [x] 5.5 <!-- Non-TDD --> `openspec validate "refactor-as-generator-artifact-boundaries" --strict --json` passes.