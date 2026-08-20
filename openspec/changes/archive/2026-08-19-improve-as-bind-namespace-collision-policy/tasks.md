## 1. Sequence Against The FMath Change

- [ ] 1.1 <!-- Non-TDD --> Confirm `improve-as-library-namespace-canonicalization` plugin code is present in the checkout used for this work (`IsEquivalentScriptSignatureAlreadyBound` exists in `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintCallable.cpp`, and `CanonicalFunctionLibraryNamespaces` exists in `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h`). If the checkout is still pre-FMath `main`, implement in the existing `D:\as-lns` worktree (or a new worktree after that change merges). Do not patch the old `MathNamespace` bind path.
- [ ] 1.2 <!-- Non-TDD --> Diff any uncommitted observation logs already on `D:\as-lns` (`git -C D:\as-lns\Plugins\Angelscript diff -- Source/AngelscriptRuntime/Binds/Bind_BlueprintCallable.cpp Source/AngelscriptRuntime/Core/AngelscriptBinds.h Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`) and reuse or rewrite that draft instead of adding a third copy.

## 2. Observe Collision Counts

- [ ] 2.1 <!-- TDD --> Add `LibraryNamespaceExactDuplicateCount` and `LibraryNamespaceIncompatibleCollisionCount` on `FAngelscriptBindState` in `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.h`. Increment them in `IsEquivalentScriptSignatureAlreadyBound` (`Bind_BlueprintCallable.cpp`) for exact-duplicate versus incompatible branches. Log each exact duplicate at `Log` and each incompatible collision at `Warning`. After `ExecuteRegisteredBinds` in `FAngelscriptEngine::BindScriptTypes` (`AngelscriptEngine.cpp`), log `Library namespace collisions: exact-duplicate=%d incompatible=%d` at `Display` when either count is non-zero, otherwise `Verbose`.
- [ ] 2.2 <!-- TDD --> Extend `Plugins/Angelscript/Source/AngelscriptTest/FunctionLibraries/AngelscriptLibraryNamespaceCanonicalizationTests.cpp` so `MappedFixtureCollisionFailsBind` (or a sibling Engine method) asserts the isolated engine's incompatible counter is `>= 1` after the second `CollisionValue` bind. Keep using `BindReflectedBlueprintCallableForTesting` and the existing `UAngelscriptNamespaceMapLibraryA/B` fixtures.
- [ ] 2.3 <!-- Non-TDD --> Build and run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.FunctionLibraries.Namespace" -Label bind-collision-observe -TimeoutMs 900000`. Expected: tests pass and an isolated-engine summary includes `incompatible>=1`. Save the report path under this change directory (not `tasks.md`).
- [ ] 2.4 <!-- Non-TDD --> From a default-settings isolated or shared test engine init log, record the exact-duplicate and incompatible counts for default FMath aggregation in `openspec/changes/improve-as-bind-namespace-collision-policy/observation.md`. Do not treat the historical inventory (`Min`/`Max`/`FindNearestPointsOnLineSegments`) as a live allowlist.

## 3. First-Failure Diagnostic

- [ ] 3.1 <!-- TDD --> Add an Engine test that registers two incompatible incoming functions after one existing same-key binding and asserts `GetRegistrationFailureDiagnostic()` contains the **first** incoming owner path, not the second. File: `AngelscriptLibraryNamespaceCanonicalizationTests.cpp`.
- [ ] 3.2 <!-- TDD --> Change the incompatible branch in `IsEquivalentScriptSignatureAlreadyBound` so it matches `RecordRegistrationFailure`: if `bDirectBindFailed` is already true, keep the existing diagnostic, still increment the incompatible counter, still return without binding. Write the diagnostic only on the first failure.
- [ ] 3.3 <!-- TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.FunctionLibraries.Namespace" -Label bind-collision-first-failure -TimeoutMs 900000`. Expected: 0 failures. Default-engine exact duplicates must still not fail init.

## 4. Close The Observation

- [ ] 4.1 <!-- Non-TDD --> From `observation.md`, decide whether per-event exact-duplicate `Log` lines stay permanently or drop to summary-only. Record the decision in `design.md` Open Questions (do not leave it unanswered).
- [ ] 4.2 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.FunctionLibraries+Angelscript.TestModule.Bindings.Math" -Label bind-collision-focused -TimeoutMs 900000`. Expected: 0 failures, skips, and timeouts.
- [ ] 4.3 <!-- Non-TDD --> Run `openspec validate "improve-as-bind-namespace-collision-policy" --strict --json` and require `valid: true`.
