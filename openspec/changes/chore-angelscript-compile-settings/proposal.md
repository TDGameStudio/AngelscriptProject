## Why

`AngelscriptTest` contains many C++ automation test files, and consumers of the plugin need a project-owned way to keep normal Angelscript editor builds focused on plugin/runtime usage rather than test registration and test-only code paths. The chosen direction is a lightweight compile-setting gate, modeled after UnrealCSharp's config-driven Build.cs pattern, while keeping the existing plugin/module layout intact.

## What Changes

- Add an Angelscript-specific compile options file named `Config/DefaultAngelscriptCompileOptions.ini`.
- Add a build-time boolean setting, `bCompileAngelscriptUnitTests`, under the `[/Script/AngelscriptRuntime.AngelscriptCompileOptions]` section.
- Read the setting from `AngelscriptTest.Build.cs` and expose it as a compile definition, `WITH_ANGELSCRIPT_UNITTESTS=0/1`.
- Register only `DefaultAngelscriptCompileOptions.ini` through `ExternalDependencies` from the test module rules so UBT invalidates the makefile when compile options change.
- Keep generic Angelscript editor preferences in a separate settings class/ini so unrelated editor setting changes do not invalidate C++ makefiles.
- Gate Angelscript test registration and test-only code paths behind the compile definition.
- Keep the current `AngelscriptTest` module and plugin descriptors in place for this change.

## Capabilities

### New Capabilities

- `angelscript-compile-settings`: Project-owned Angelscript compile options can influence test-module compile behavior.

### Modified Capabilities

- None.

## Impact

- Affects `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`.
- Affects Angelscript test registration code and shared test macro/adapter entry points under `Plugins/Angelscript/Source/AngelscriptTest/`.
- Adds `Config/DefaultAngelscriptCompileOptions.ini`.
- May require documentation updates in `Plugins/Angelscript/README.md`, `Documents/Guides/Build.md`, and test guide material.
- Does not remove `AngelscriptTest` from `Plugins/Angelscript/Angelscript.uplugin` and does not split tests into a separate plugin.
