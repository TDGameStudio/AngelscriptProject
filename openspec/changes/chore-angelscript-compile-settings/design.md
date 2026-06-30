## Context

The current `Angelscript` plugin declares `AngelscriptTest` as an Editor module in `Plugins/Angelscript/Angelscript.uplugin`, and the host project also declares `AngelscriptProjectTest` in `AngelscriptProject.uproject`. UBT includes plugin and project modules before a module's own `Build.cs` can decide what its source files mean, so this change intentionally does not attempt to remove `AngelscriptTest` from the build graph.

The requested direction is the UnrealCSharp-style pattern: read an ini file from the project `Config` directory in module rules, add the ini to `ExternalDependencies`, and derive compile definitions from the setting. The ini file is named for Angelscript compile options and must stay separate from broader editor preferences so ordinary editor setting changes do not invalidate C++ makefiles.

## Goals / Non-Goals

**Goals:**

- Provide a clear Angelscript-owned compile options file, `Config/DefaultAngelscriptCompileOptions.ini`.
- Provide one boolean setting, `bCompileAngelscriptUnitTests`, that controls whether Angelscript unit test registration and test-only code paths are compiled in.
- Ensure changing `DefaultAngelscriptCompileOptions.ini` invalidates UBT makefiles for targets that build `AngelscriptTest`.
- Keep compile-affecting settings isolated from generic `AngelscriptEditorSettings` so unrelated editor preferences do not trigger C++ project rebuilds.
- Keep the implementation centralized enough that future test files use existing macros/helpers instead of hand-written per-file gates.

**Non-Goals:**

- Do not split `AngelscriptTest` into a separate optional plugin in this change.
- Do not remove or conditionally omit `AngelscriptTest` from `Angelscript.uplugin`.
- Do not guarantee that no `AngelscriptTest` `.cpp` is scanned or compiled by UBT; that requires a target/plugin-level module gate, not a module-local Build.cs switch.
- Do not add compile-affecting settings to `DefaultEditor.ini`, `DefaultEngine.ini`, `DefaultGame.ini`, or a broad `DefaultAngelscriptEditorSettings.ini`.
- Do not change runtime/editor module behavior outside test-related compile definitions.

## Decisions

### Config file name

Use `Config/DefaultAngelscriptCompileOptions.ini`.

Rationale: the setting belongs to Angelscript compile policy rather than generic project settings or UnrealCSharp compatibility. The name leaves room for future compile settings without making the file test-specific, and it follows UE's `UCLASS(config = AngelscriptCompileOptions, defaultconfig)` default filename convention.

Suggested initial content:

```ini
[/Script/AngelscriptRuntime.AngelscriptCompileOptions]
bCompileAngelscriptUnitTests=false
```

The settings UObject should be distinct from any general `UAngelscriptEditorSettings` class:

```cpp
UCLASS(config = AngelscriptCompileOptions, defaultconfig, meta = (DisplayName = "Angelscript Compile Options"))
class UAngelscriptCompileOptions : public UObject
{
	GENERATED_BODY()

	UPROPERTY(Config, EditAnywhere, Category = "Tests")
	bool bCompileAngelscriptUnitTests = false;
};
```

If a separate `UAngelscriptEditorSettings` class is introduced later, it should use a separate config such as `AngelscriptEditorSettings` and must not be read by `Build.cs` unless the specific setting affects compilation.

### Settings UObject placement

Add the settings UObject in the runtime module, because this file is a broader Angelscript compile-policy surface rather than an editor-only preference. The first setting controls editor/unit test compilation, but future compile options may affect runtime-facing build behavior. Runtime ownership keeps the config section stable as `[/Script/AngelscriptRuntime.AngelscriptCompileOptions]`.

Recommended file layout:

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptCompileOptions.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptCompileOptions.cpp`

The class should be exported by `ANGELSCRIPTRUNTIME_API` so generated code, editor registration, and future runtime-facing code can reference it cleanly:

```cpp
UCLASS(config = AngelscriptCompileOptions, defaultconfig, meta = (DisplayName = "Angelscript Compile Options"))
class ANGELSCRIPTRUNTIME_API UAngelscriptCompileOptions : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY(Config, EditAnywhere, Category = "Tests", meta = (ConfigRestartRequired = true))
	bool bCompileAngelscriptUnitTests = false;
};
```

The editor module should still register it in Project Settings beside the existing Angelscript project settings in `Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.cpp`, but use a separate section key so it is visible and independently unregisterable:

```cpp
SettingsModule->RegisterSettings(
	"Project",
	"Plugins",
	"AngelscriptCompileOptions",
	NSLOCTEXT("Angelscript", "AngelscriptCompileOptionsTitle", "Angelscript Compile Options"),
	NSLOCTEXT("Angelscript", "AngelscriptCompileOptionsDescription", "Compile-affecting Angelscript options."),
	GetMutableDefault<UAngelscriptCompileOptions>());
```

Shutdown should unregister the same section:

```cpp
SettingsModule->UnregisterSettings("Project", "Plugins", "AngelscriptCompileOptions");
```

This keeps the existing `Angelscript` settings section unchanged and creates a second Project Settings entry for compile policy. The downside is one extra settings row under Plugins, but the separation is intentional because these values affect C++ build products.

### Build.cs ownership

Read the config from `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs` and publish `WITH_ANGELSCRIPT_UNITTESTS=0/1`.

Rationale: this matches the requested scheme and limits immediate scope to the test module. The `DefaultAngelscriptCompileOptions.ini` path should be added to `ExternalDependencies` in the same rules file so UBT reports makefile invalidation when the file changes while the test module is part of the target.

Only this compile-options ini should be added to `ExternalDependencies`. This intentionally makes invalidation file-level for the small compile-options file while keeping broad editor settings out of the C++ makefile dependency surface.

`Build.cs` should not depend on the editor UObject at build time. It should read the generated ini file and section name directly:

```csharp
var SettingSection = "/Script/AngelscriptRuntime.AngelscriptCompileOptions";
```

This mirrors UnrealCSharp's pattern: editor settings writes the ini, UBT module rules read the same file as plain config data, and the compile macro is derived from that file.

### Compile impact boundary

`ExternalDependencies` is a whole-file timestamp dependency. Any save to `DefaultAngelscriptCompileOptions.ini` can invalidate makefiles for targets that include `AngelscriptTest`, even if the changed key is not currently read by `Build.cs`. To control blast radius:

- Keep `DefaultAngelscriptCompileOptions.ini` small and dedicated to compile-affecting options only.
- Keep ordinary editor UX preferences in a different settings class and ini file.
- Do not place this option in `DefaultEditor.ini`, because UBT tracks Editor config hierarchy for editor targets.
- Do not read broad settings files from `AngelscriptTest.Build.cs`.
- If more compile options are added later, only add options where a makefile invalidation is the expected behavior.

### Gate placement

Prefer centralized gates at test registration/helper entry points before touching hundreds of individual test files.

Likely places to inspect first:

- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestMacros.h`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptTestAdapter.h`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTestModule.cpp`
- CQTest registration macros (`TEST_CLASS_WITH_FLAGS`, `TEST_METHOD`) used throughout `AngelscriptTest`.
- Any direct `IMPLEMENT_SIMPLE_AUTOMATION_TEST`, `IMPLEMENT_COMPLEX_AUTOMATION_TEST`, or `DEFINE_SPEC` patterns that bypass local wrappers.

Rationale: per-file `#if WITH_ANGELSCRIPT_UNITTESTS` edits across hundreds of files are noisy and fragile. The first implementation should prove whether existing macro/adapter layers can disable registration centrally. Only bypassing files should receive local gates.

### Default behavior

Default `bCompileAngelscriptUnitTests=false` for consumer-friendly builds, unless the implementation finds that the repository's own CI/build scripts require a transitional default of `true`.

Rationale: the user-facing goal is to avoid exposing test behavior to normal users. The risk is that this repository's current validation assumes tests are available by default, so the implementation must update docs/scripts or choose a temporary default deliberately.

## Risks / Trade-offs

- **Risk: This does not remove the module from UBT's build graph.** -> Mitigation: document the boundary clearly. If true source-file exclusion becomes required, follow up with a separate optional test plugin or target-level module gating change.
- **Risk: CQTest macros may not be centrally overridable.** -> Mitigation: inspect macro expansion first, then gate the smallest set of shared adapters or direct registration sites.
- **Risk: Disabled test registration hides validation unexpectedly.** -> Mitigation: update test runner/build docs to say `bCompileAngelscriptUnitTests=true` is required before running Angelscript C++ automation tests.
- **Risk: File-level invalidation is broader than the single boolean key.** -> Mitigation: keep the compile-options ini dedicated to compile-affecting options and keep generic editor settings in a separate ini.
- **Risk: Changing the ini may not invalidate makefiles when the test module is not part of the target.** -> Mitigation: this is acceptable for scheme C; if module-level omission is introduced later, the dependency must move to a module that is always built, such as `AngelscriptRuntime`.

## Migration Plan

1. Add `UAngelscriptCompileOptions` in `AngelscriptRuntime/Core`.
2. Register and unregister a dedicated Project Settings section in `AngelscriptEditorModule.cpp`.
3. Add `Config/DefaultAngelscriptCompileOptions.ini` with `bCompileAngelscriptUnitTests=false`.
4. Add robust config reading and `ExternalDependencies` registration to `AngelscriptTest.Build.cs`.
5. Add `WITH_ANGELSCRIPT_UNITTESTS` compile definition.
6. Gate centralized test registration paths.
7. Build with `bCompileAngelscriptUnitTests=false` to confirm normal editor builds still pass.
8. Flip `bCompileAngelscriptUnitTests=true`, rebuild, and run a narrow Angelscript test prefix to confirm test registration remains available.

## Open Questions

- Should repository CI default to `bCompileAngelscriptUnitTests=true` via checked-in config, or should CI patch/override the setting before running tests?
- Can CQTest registration be disabled centrally without changing upstream CQTest headers, or do Angelscript test files need local wrapper macros?
- Should optional extension test modules (`AngelscriptGameplayTagsTest`, `AngelscriptGASTest`) adopt the same `WITH_ANGELSCRIPT_UNITTESTS` setting in this change or a follow-up?
