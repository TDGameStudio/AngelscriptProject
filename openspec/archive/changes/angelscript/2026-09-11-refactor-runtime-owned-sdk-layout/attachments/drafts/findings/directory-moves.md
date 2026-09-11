# Findings: plugin directory moves

Inspected 2026-09-11 in `Plugins/Angelscript` (submodule dirty, ahead of origin/main by 76).

## Move 1 — owned SDK tree

```
Plugins/Angelscript/Source/AngelscriptRuntime/
├─ [was] ThirdParty/angelscript/source/          // git HEAD; now deleted
└─ [now] angelscript/                          // untracked; as_*.{h,cpp} + frontend/ sit here, no nested source/
```

Public headers still `#include "angelscript.h"` / `"frontend/as_*.h"`. The UE include root was `ThirdParty/angelscript/source`. `AngelscriptRuntime.Build.cs` still adds that dead path:

```csharp
var AngelscriptThirdPartyPath = Path.Combine(ModuleDirectory, "ThirdParty", "angelscript");
PublicIncludePaths.Add(Path.Combine(AngelscriptThirdPartyPath, "source"));
PublicIncludePaths.Add(AngelscriptThirdPartyPath);
```

The public C header remains `Source/AngelscriptRuntime/Core/angelscript.h`, not inside the moved tree.

Live specs still name the old organization: `openspec/specs/angelscript/language/ast/core/spec.md`, `language/frontend/reflection-dependencies/spec.md`, and several knowledges.

## Move 2 — Standalone → AngelscriptLSP

```
Plugins/Angelscript/
├─ [was] Standalone/                           // git HEAD; now deleted (CMake, CLI, Contracts, Tests, …)
└─ [now] AngelscriptLSP/                      // untracked; CMake project still AngelscriptStandalone
```

`AngelscriptLSP/README.md` still titles "Unreal AngelScript Standalone". `CMakeLists.txt` still sets `ANGELSCRIPT_FORK_ROOT` to `../Source/AngelscriptRuntime/ThirdParty/angelscript/source`. `.uplugin` has no LSP module; this is not a UE module.

Prior records (not the VS Code extension):

- Archived `refactor-language-surface-ue-focused`: keep Standalone, remove add-on packages; do not certify a working binary.
- Active `feature-frontend-diagnostics-tooling`: in-process `asCLanguageService`; JSON-RPC/LSP adapter is later work. TypeScript server stays at `Extensions/AngelscriptVSCode/`.
- Current specs: Standalone is not guaranteed to build against the reconstructed SDK.

`Extensions/AngelscriptVSCode/` is unchanged.

## Not these two moves

Untracked placeholders `Source/AngelscriptTest/TestCode/` and `TestFramework/` belong with existing `angelscript/refactor-testing-unified-framework`, not a third layout Change.

## Peripheral stale owners

Must retarget or the plugin will not compile / agents will write to deleted trees:

- `AngelscriptRuntime.Build.cs` include paths
- `AngelscriptLSP/CMakeLists.txt` fork root
- Plugin `README.md` contents list (`Standalone/`)
- Parent `README.md`, `Documents/Guides/Build.md`, `Documents/Guides/AngelscriptStandaloneOfflineBundle.md`, `Tools/RunStandaloneExternalSmoke.ps1`
- Active Change files that still list `ThirdParty/angelscript` or `Plugins/Angelscript/Standalone/` (notably `refactor-sdk-drop-native-gc` Standalone tests)

Do not rewrite immutable `openspec/archive/` or historical `Documents/Knowledges/ZH/` as a correctness gate.

## Conclusions / Open

Two layout Changes match the two moves. They should retarget live contracts, not implement JSON-RPC or restore a certified Standalone/LSP binary. Open: product identity of `AngelscriptLSP`, how far "周边" goes, and whether other active Changes are rewritten here or only listed for replan.
