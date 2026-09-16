## Why

The plugin already moved the dormant no-Unreal host from `Plugins/Angelscript/Standalone/` to `Plugins/Angelscript/AngelscriptLSP/`. Prior records keep this tree as dormant Standalone tooling: add-on packages are gone, and the host is not build-certified against the reconstructed SDK. `feature-frontend-diagnostics-tooling` already reserved JSON-RPC / a language-server process as later work; `Extensions/AngelscriptVSCode/` remains the TypeScript LSP.

CMake, README, SUPPORT_MATRIX, plugin contents, live Guides, and Tools still name `Standalone/` and still compile the fork from `ThirdParty/angelscript/source`. Agents and suite definitions will write to a deleted tree.

This Change retargets those live paths. The directory is `AngelscriptLSP`; the product remains dormant Standalone (`as-standalone`, CMake project `AngelscriptStandalone`, contract `ue-as-standalone-v1`).

## What Changes

- Set `ANGELSCRIPT_FORK_ROOT` to `${ANGELSCRIPT_RUNTIME_ROOT}/angelscript`.
- State the directory-versus-product identity in `AngelscriptLSP/README.md` and `SUPPORT_MATRIX.md`, and replace path examples that would not resolve.
- Point plugin README contents, live Guides, `Tools/RunStandaloneExternalSmoke.ps1`, and `Tools/Shared/TestSuiteDefinitions.ps1` at `AngelscriptLSP/`.
- Keep invoking `CheckRemovedAddons.py` at the new path as a source audit, not a binary certification.
- List other active Changes whose Files still name `Plugins/Angelscript/Standalone/`; those Changes replan themselves.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. Current specs do not mandate `Standalone/` as a filesystem path. Product name "Standalone" stays. No synthetic spec delta.

## Impact

Plugin submodule: `AngelscriptLSP/CMakeLists.txt`, `AngelscriptLSP/README.md`, `AngelscriptLSP/SUPPORT_MATRIX.md`, plugin `README.md`. Parent repository: this OpenSpec record, `Documents/Guides/Build.md`, `Documents/Guides/AngelscriptStandaloneOfflineBundle.md`, `Tools/RunStandaloneExternalSmoke.ps1`, `Tools/Shared/TestSuiteDefinitions.ps1`. `Source/AngelscriptProject` stays untouched.

Depends on `angelscript/refactor-runtime-owned-sdk-layout` for the canonical SDK path string. The folder already exists on disk.

Known consumer to replan (not edited here): `angelscript/refactor-sdk-drop-native-gc`.

## Boundaries

- Do not rename `as-standalone`, the CMake `project()`, test prefixes `AngelscriptStandalone.*`, or compiler contract `ue-as-standalone-v1`.
- Do not implement JSON-RPC, document sync, a language-server process, or move `Extensions/AngelscriptVSCode/`.
- Do not certify a working host binary or add an AngelscriptLSP module to `Angelscript.uplugin`.
- Do not search `Standalone/` and `AngelscriptLSP/` as dual live roots.
- Do not rewrite other Changes' `tasks.md`, archives, ZH dumps, or `TestCode/` / `TestFramework/`.

## Acceptance

After this Change:

1. Live path strings for the host tree use `Plugins/Angelscript/AngelscriptLSP/`; remaining `Plugins/Angelscript/Standalone` hits in live README/Guides/Tools are historical or archive.
2. CMake `ANGELSCRIPT_FORK_ROOT` equals `Source/AngelscriptRuntime/angelscript`.
3. `python Plugins/Angelscript/AngelscriptLSP/Tests/CheckRemovedAddons.py` still runs as a path-level source audit.
4. Product names stay Standalone. The consumer-replan attachment lists Changes that still Files `Standalone/` and does not rewrite their Task DAGs.
