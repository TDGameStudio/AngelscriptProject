## 1. Inventory And Classification

- [x] 1.1 <!-- Non-TDD --> Generate a fresh list of `Plugins/Angelscript/Source/AngelscriptTest/**/*.cpp` files and record the count.
- [x] 1.2 <!-- Non-TDD --> Generate a fresh list of `.cpp` files containing `TEST_CLASS_WITH_FLAGS`, `TEST_METHOD`, `IMPLEMENT_SIMPLE_AUTOMATION_TEST`, `IMPLEMENT_COMPLEX_AUTOMATION_TEST`, `DEFINE_SPEC`, or `BEGIN_DEFINE_SPEC`.
- [x] 1.3 <!-- Non-TDD --> Generate the complement list of `.cpp` files without registration macros and classify each as support, generated/AOT, commandlet, mixed, or needs-gate.
- [x] 1.4 <!-- Non-TDD --> Record the classification results under `openspec/changes/refactor-angelscript-test-compile-macro/impact-inventory.md`.

## 2. Macro Guard Preparation

- [x] 2.1 <!-- Non-TDD --> Confirm `chore-angelscript-compile-settings` defines `WITH_ANGELSCRIPT_UNITTESTS` in `AngelscriptTest.Build.cs`.
- [x] 2.2 <!-- Non-TDD --> Add a defensive default for `WITH_ANGELSCRIPT_UNITTESTS` in the narrowest shared `AngelscriptTest` header if needed for tooling or non-UBT parsing.
- [x] 2.3 <!-- Non-TDD --> Add or update a compile-time validation test/source check proving the macro is visible in `AngelscriptTest` code.

## 3. Registration Source Wrapping

- [x] 3.1 <!-- Non-TDD --> Apply whole-file gates after includes for straightforward CQTest registration `.cpp` files.
- [x] 3.2 <!-- Non-TDD --> Inspect mixed files with file-scope native bind registration, helper classes, or generated includes and gate only unit-test-only sections where whole-file wrapping would break references.
- [x] 3.3 <!-- Non-TDD --> Gate any direct Unreal automation registration macros if future scans find them.
- [x] 3.4 <!-- Non-TDD --> Re-run the registration macro scan and verify every registration source contains `WITH_ANGELSCRIPT_UNITTESTS`.
- [x] 3.5 <!-- Non-TDD --> Re-run an old-name scan and verify no new gate uses `WITH_ANGELSCRIPT_TESTS`.

## 4. Support File Decisions

- [x] 4.1 <!-- Non-TDD --> Review AOT generated and commandlet files under `StaticJIT/AOT` and decide whether they remain exempt or become gated.
- [x] 4.2 <!-- Non-TDD --> Review shared helper `.cpp` files under `Shared/` and keep them compiled unless they register tests.
- [x] 4.3 <!-- Non-TDD --> Review test type implementation files under `Performance`, `Core`, `AngelScriptSDK`, `Coverage`, `Bindings`, and `Compiler` that lack registration macros.
- [x] 4.4 <!-- Non-TDD --> Update `impact-inventory.md` with every intentional exemption and reason.

## 5. Verification

- [x] 5.1 <!-- Non-TDD --> Update `Documents/UnitTest/UnitTest.md` with the `WITH_ANGELSCRIPT_UNITTESTS` wrapping rule, preferred snippet, and exemption guidance.
- [x] 5.2 <!-- Non-TDD --> Build with `bCompileAngelscriptUnitTests=false` using `Tools\RunBuild.ps1 -ExtraArgs -NoHotReloadFromIDE -TimeoutMs 1800000`; expected result: editor build succeeds.
- [x] 5.3 <!-- Non-TDD --> Confirm test discovery omits AngelscriptTest prefixes when `WITH_ANGELSCRIPT_UNITTESTS=0`.
- [x] 5.4 <!-- Non-TDD --> Build with `bCompileAngelscriptUnitTests=true`; expected result: editor build succeeds with unit-test registration compiled.
- [x] 5.5 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -TimeoutMs 600000`; expected result: representative unit tests are discoverable and pass.
- [x] 5.6 <!-- Non-TDD --> Restore the intended checked-in `bCompileAngelscriptUnitTests` value and record verification notes in the OpenSpec change.
