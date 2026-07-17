# Verification

## Generated artifact baseline

- `5835` generated entries: `3358` direct, `2477` stubs, `0` cross-module.
- `29` generated shards across `11` modules.
- Cross-module generation remains disabled by default.
- Layout token remains `0xA5C0DE02`.

## Passing checks

- `Tools\RunBuild.ps1 -Label refactor-uht-binding-registry-compile2 -NoXGE`: `83/83` actions succeeded; Runtime, Editor, Test, GameplayTags, and GAS modules linked.
- `Angelscript.TestModule.Engine.FunctionCallers`: `1/1` passed.
- `Angelscript.TestModule.Engine.BindConfig`: `22/22` passed.
- `Angelscript.TestModule.Engine.GeneratedFunctionTable`: `11/11` passed.
- `Angelscript.CppTests.UHTToolResolver`: `21/21` passed.
- Source scan found no legacy registry or cross-module protocol names in active plugin source, active specifications, or maintained documentation.

## Existing full-suite failures

`Tools\RunTestSuite.ps1 -Suite RuntimeCpp` reached `Angelscript.TestModule.Engine` and reported `90/101` passed, `11` failed. The failures are existing shared-engine/type-database lifecycle assumptions and the generated-table checks after that state contamination:

- `GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton`
- `PrepareContextLogsCrossEngineMismatch`
- `FullDestroyAllowsAnnotatedRecreate`
- `FullDestroyAllowsAnnotatedSameNameRecreate`
- `FullDestroyAllowsCleanRecreate`
- `LastFullDestroyClearsTypeState`
- `MinimalApiFunctionLevelExports`
- `PopulatesClassFunctionBindings`
- `ReflectiveFallbackStats`
- `RepresentativeCoverage`
- `AliasAndTypeFindersResetCleanly`

The same generated-table tests pass in their isolated `11/11` run, and the complete UHT resolver parent prefix passes `21/21`; no refactor-specific failure was reproduced. These unrelated baseline failures remain outside this change's scope.

## ModuleLocal compile gate verification (2026-07-17)

- `Tools\RunBuild.ps1 -ExtraArgs -NoHotReloadFromIDE -TimeoutMs 1800000` passed with the default `bCompileAngelscriptModuleLocalBindings=false`; UHT reported `enabled=False`, `5835` ordinary entries, `29` ordinary shards, and `0` cross-module entries.
- `Angelscript.CppTests.UHTToolResolver.ModuleLocalCompileGate`: `1/1` passed.
- `Angelscript.Editor.Module.FAngelscriptEditorModuleSettingsTests`: `2/2` passed, including `OnModified` validator registration.
- `Angelscript.CppTests.UHTToolResolver.CrossModuleGenerationProfiles`: `2/2` passed.
- `Angelscript.CppTests.UHTToolResolver.CrossModuleDefaultOff`: `2/2` passed.
- Temporarily setting the ini option to `true` made UBT fail before compilation with `Angelscript ModuleLocal binding compilation requires a source engine` for `C:\Program Files\Epic Games\UE_5.8\Engine`; the ini was restored to `false`.
- `Tools\RunTestSuite.ps1 -Suite RuntimeCpp` reproduced the existing `90/101` result with the same 11 shared Engine/TypeDatabase lifecycle failures and no new ModuleLocal-related failure.
