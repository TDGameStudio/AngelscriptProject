# UE CoreRedirects investigation for AS class rename

## Scope

This note records the investigation requested for AS generated `UCLASS` rename handling. It compares UE's official C++ class rename redirect path with the current Angelscript hot-reload path, using both knot search results and local source inspection.

## Evidence from knot

- UE5-main `FCoreRedirects` exposes the official API surface in `Engine/Source/Runtime/CoreUObject/Public/UObject/CoreRedirects.h`: `Initialize`, `GetRedirectedName`, `FindPreviousNames`, `ReadRedirectsFromIni`, `AddRedirectList`, and `RemoveRedirectList`.
- UE5-main `FCoreRedirects::ReadRedirectsFromIni` reads the `[CoreRedirects]` section, maps config keys such as `ClassRedirects` through `GetConfigKeyMap`, parses `OldName`, `NewName`, `OverrideClassName`, `InstanceOnly`, `Removed`, `MatchWildcard`, `Iterate`, and then registers the resulting `FCoreRedirect` list.
- UE5-main `InitUObject` initializes redirects early and loops over `GConfig->GetFilenames()`, calling `FCoreRedirects::ReadRedirectsFromIni(Filename)` before `FLinkerLoad::CreateActiveRedirectsMap(Filename)`.
- UE documentation for Core Redirects confirms the supported class redirect form:

```ini
[CoreRedirects]
+ClassRedirects=(OldName="/Script/MyModule.MyOldClass",NewName="/Script/MyModule.MyNewClass")
```

- UE-Angelscript reference search did not show a Hazelight-style name-level AS redirect system. The reference path mainly has pointer-level hot reload replacement of same-name generated classes.

## Evidence from local UE source

- `C:\Program Files\Epic Games\UE_5.8\Engine\Source\Runtime\CoreUObject\Private\UObject\Obj.cpp:5863` initializes the redirect map in `InitUObject`; lines `5866-5868` read CoreRedirects from every loaded config filename and then process legacy active redirects.
- `C:\Program Files\Epic Games\UE_5.8\Engine\Source\Runtime\CoreUObject\Private\UObject\CoreRedirects.cpp:2731` implements `FCoreRedirects::ReadRedirectsFromIni`.
  - It reads only the `CoreRedirects` section.
  - It uses the config entry key to choose redirect type, so class redirects are official `+ClassRedirects=(...)` entries, not `/Script/...` UPROPERTY settings.
  - It parses `OldName` and `NewName` into `FCoreRedirectObjectName`.
  - It removes the `CoreRedirects` section from the config branch after consuming it with `GConfig->RemoveSectionFromBranch`.
  - It registers redirects via `FCoreRedirects::AddRedirectList(NewRedirects, IniName)`.
- `C:\Program Files\Epic Games\UE_5.8\Engine\Source\Runtime\CoreUObject\Private\UObject\CoreRedirects.cpp:1973` implements `FindPreviousNames` by scanning redirects in reverse. This is the correct API for asking "which old names redirect to this new class name?"
- `C:\Program Files\Epic Games\UE_5.8\Engine\Source\Runtime\CoreUObject\Private\UObject\LinkerLoad.cpp:280` implements `CreateActiveRedirectsMap`. The comment explicitly marks `ActiveClassRedirects` as deprecated and replaced by `FCoreRedirects`.
- `C:\Program Files\Epic Games\UE_5.8\Engine\Source\Runtime\CoreUObject\Private\UObject\LinkerLoad.cpp:2884` applies class redirects while resolving saved export/import class names during load.
- `C:\Program Files\Epic Games\UE_5.8\Engine\Source\Runtime\CoreUObject\Private\UObject\LinkerLoad.cpp:7456` and nearby `FindNewPathNameForClass` helpers use `FCoreRedirects::GetRedirectedName(ECoreRedirectFlags::Type_Class, ...)` for class and instance class redirects.
- `C:\Program Files\Epic Games\UE_5.8\Engine\Config\BaseEngine.ini:368` documents the preferred section and states that redirects can live in any ini file, including plugin ini files.
- `C:\Program Files\Epic Games\UE_5.8\Engine\Config\BaseEngine.ini:375` shows both short-name and fully qualified class redirect forms, while recommending a full package path for `NewName`.
- `C:\Program Files\Epic Games\UE_5.8\Engine\Source\Editor\UnrealEd\Private\Factories\PackFactory.cpp:589` writes redirect-style config by loading `DefaultEngine` into a temporary `FConfigCacheIni`, adding `+...Redirects`, and calling `UpdateSections`. AS follows that file-write shape for generated project config entries and separately calls `FCoreRedirects::AddRedirectList` so the current editor session has the redirect immediately.

## Evidence from local Angelscript source

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp:139` defines the generated script package as `/Script/Angelscript`.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp:1025` creates that package and marks it as compiled-in.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp:2716` creates a full-reload generated `UASClass`.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp:2726` first checks same-name replacement by finding an existing generated class with the new Unreal name.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp:2730` falls back to `ResolveClassRedirectReplacedClass` if no same-name class exists.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp:2771` implements `ResolveClassRedirectReplacedClass`.
  - It skips structs, statics classes, and already-known old/new pairs.
  - It calls `FCoreRedirects::FindPreviousNames(ECoreRedirectFlags::Type_Class, ...)`.
  - It currently tries both the AS script class name and `/Script/Angelscript.<ClassName>`.
  - It resolves returned previous names only against `ModuleData.RemovedClasses` from the same reload, then returns the removed `UASClass`.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp:3797` links `ReplacedClass->NewerVersion = NewClass` after finalizing, which lets the existing editor hot-reload machinery treat the rename as a real replacement.
- `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadClassRenameTests.cpp` currently proves the runtime behavior using `FCoreRedirects::AddRedirectList`/`RemoveRedirectList`, not a physical `.ini` round trip.
- `Plugins/AngelscriptGAS/Config/BaseAngelscriptGAS.ini` already uses the official `[CoreRedirects] +ClassRedirects` pattern for plugin class moves. This is a local project example of the intended mechanism.

## Correct AS class redirect format

AS generated classes are in `/Script/Angelscript`, so the official project/plugin config form for a script class rename should be:

```ini
[CoreRedirects]
+ClassRedirects=(OldName="/Script/Angelscript.AOldScriptClass",NewName="/Script/Angelscript.ANewScriptClass")
```

Short old names can work in UE's matcher in some native-class cases, but full paths are the safer AS recommendation because generated script classes all share the synthetic `/Script/Angelscript` package. `NewName` should be fully qualified.

## Interpretation

UE's official C++ rename scheme has two separate responsibilities:

1. Config ingestion and asset load-time redirecting are owned by CoreUObject and LinkerLoad.
2. Live hot reload replacement of already-created class objects is owned by the system doing the reload.

For native C++, the class object lifecycle is native module reload/UHT compiled-in registration. For AS, the generated `UASClass` lifecycle is owned by `FAngelscriptClassGenerator`. Therefore AS should not add a custom `UAngelscriptSettings::ClassRedirects` array. It should use the official UE `FCoreRedirects` map and, when hot reload has an unambiguous single removed AS `UCLASS` plus single added AS `UCLASS`, emit the corresponding official `[CoreRedirects] +ClassRedirects` entry before resolving the replacement class.

The AS production code is aligned with this architecture at runtime: it calls `FCoreRedirects::FindPreviousNames` and links the removed `UASClass` as `ReplacedClass`. The additional AS-owned step is the rename detection and generated official redirect write, because AS source hot reload is the layer that can see the old generated class disappear and the new generated class appear in the same script module.

## Recommended next work

- Keep AS runtime integration on `FCoreRedirects`; do not add AS-specific redirect settings.
- Document the exact AS generated class format as `/Script/Angelscript.<ClassName>`.
- Keep coverage for UE's official `[CoreRedirects]` config ingestion path and direct `AddRedirectList` registry behavior.
- Generate official project config entries automatically only when the hot reload rename is unambiguous; ambiguous edits must still require user-authored redirect or manual Blueprint reparenting.
- In production, write generated entries to project `Config/DefaultEngine.ini`; in automation, override the target to `Saved/Automation/...` and delete it after the test.

## Verification status

- `Tools\RunBuild.ps1 -Label as-class-redirect-runtime-final-noreload -TimeoutMs 180000 -NoXGE "-Module=AngelscriptRuntime"` succeeded.
- `Tools\RunBuild.ps1 -Label as-class-redirect-test-singlefile-isolated -TimeoutMs 180000 -NoXGE "-SingleFile=D:\Workspace\AngelscriptProject\Plugins\Angelscript\Source\AngelscriptTest\HotReload\AngelscriptHotReloadClassRenameTests.cpp"` succeeded.
- `Tools\RunBuild.ps1 -Label as-class-redirect-test-module-after-coverage-fix -TimeoutMs 180000 -NoXGE "-Module=AngelscriptTest"` succeeded after clearing unrelated Coverage compile blockers.
  - `AngelscriptCoverageIntExpressionTests.cpp` no longer calls `ExecuteAndGet<T>` for complex struct returns; those cases use `ExecuteAndExtractStruct`.
  - `AngelscriptCoverageFStringExpressionTests.cpp` keeps scalar returns on `ExecuteAndGet<T>` and uses `ExecuteAndExtractStruct` for `FString`.
- `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.ClassRename" -Label "hotreload-class-rename-core-redirect-final" -TimeoutMs 300000` reported `8/8 passed`.
- After adding generated redirect target overrides to all redirect-writing class rename tests, `Tools\RunBuild.ps1 -Label as-class-redirect-test-module-isolated -TimeoutMs 180000 -NoXGE "-Module=AngelscriptTest"` succeeded.
- `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.ClassRename" -Label "hotreload-class-rename-core-redirect-isolated-linked" -TimeoutMs 300000` reported `8/8 passed`.
- Final local verification also succeeded:
  - `Tools\RunBuild.ps1 -Label as-class-redirect-test-module-final-check -TimeoutMs 180000 -NoXGE "-Module=AngelscriptTest"` returned `FinalExitCode: 0`.
  - `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.ClassRename" -Label "hotreload-class-rename-core-redirect-final-check" -TimeoutMs 300000` reported `total=8 passed=8 failed=0 skipped=0`.
- Test isolation was verified after cleanup:
  - `Config/DefaultEngine.ini` has no `HotReloadClassRename`, `AHotReloadClassRename`, or `+ClassRedirects` entries from automation.
  - `Saved/Automation/CoreRedirects` exists and contains zero files after the class rename suite.
