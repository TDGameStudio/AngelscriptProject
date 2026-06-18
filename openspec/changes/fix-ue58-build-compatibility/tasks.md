## 1. Build Entry

- [x] 1.1 Point `AgentConfig.ini` at the installed UE 5.8 engine root.
- [x] 1.2 Update project targets to UE 5.8 build settings and include order.
- [x] 1.3 Re-run `Tools\RunBuild.ps1 -Label ue58-adapt-check -TimeoutMs 180000` until UBT reaches C++ compile.

## 2. Runtime Compile Errors

- [x] 2.1 Fix UE 5.8 checked format string failures in runtime and GameplayTags tests.
- [x] 2.2 Fix `PLATFORM_64BITS` preprocessor usage in unversioned serialization.
- [x] 2.3 Update `UUserDefinedEnum::SetEnums` call sites for the UE 5.8 signature.
- [x] 2.4 Replace `TArray` bool shrinking arguments with `EAllowShrinking`.
- [x] 2.5 Adapt JSON object field access to UE 5.8 shared string field storage.
- [x] 2.6 Fix `FPaths` binding signature mismatch.

## 3. Test Compile Errors

- [x] 3.1 Update viewport test setup for UE 5.8 viewport type changes.
- [x] 3.2 Replace deprecated multicast delegate test invocation with the UE 5.8 API.

## 4. Verification

- [x] 4.1 Re-run the standard build after each error group is fixed.
- [x] 4.2 Record remaining deprecation warning families for follow-up cleanup.

## 5. UE 5.8 Deprecation Cleanup

- [x] 5.1 Remove deprecated `RF_Public` constructor arguments from runtime-created `FProperty` instances.
- [x] 5.2 Replace `FCoreDelegates::OnPostEngineInit` with `GetOnPostEngineInit()`.
- [x] 5.3 Replace deprecated `FProperty::ElementSize`, `FStringBuilderBase`, delegate UObject ref, collision bitfield, and retired touchpad-index API usages touched by the build.
- [x] 5.4 Verify editor build has no remaining C++ `warning C4996` diagnostics.
- [x] 5.5 Track `StructUtils` plugin deprecation as a separate runtime-boundary migration; do not remove it in this compile-only pass because `FInstancedStruct` is still public script/runtime surface.

## 6. Test Failure Handoff

- [x] 6.1 Record the UE 5.8 fast-suite failure summary in `test-failure-handoff.md`.
- [x] 6.2 Investigate why UHT generated function-table entries exist but are not fully populating `FAngelscriptBinds::GetClassFuncMaps()` in `Angelscript.TestModule.Engine.BindConfig`.
- [x] 6.3 Re-run and fix the failed binding-heavy shards: `Engine`, `Bindings`, `FunctionLibraries`, `Actor`, and `Functional`.
- [x] 6.4 Triage `Preprocessor.PreprocessIsSingleUse` duplicate ensure count under UE 5.8.
- [x] 6.5 Remove or update the stale `Angelscript.TestModule.Learning` suite prefix if those tests are intentionally absent.
- [x] 6.6 Stop tracking local UBT `.ubtplugin.csproj.props` output and ignore regenerated copies.
- [x] 6.7 Disable AssetRegistry cache writes for parallel fast automation launches.
