# AngelscriptLSP is the dormant Standalone host directory

disposition: candidate

## Reusable Insight

`Plugins/Angelscript/AngelscriptLSP/` is the filesystem location of the dormant no-Unreal host. The product remains Standalone (`as-standalone`, CMake `AngelscriptStandalone`, contract `ue-as-standalone-v1`). It is not the TypeScript language server (`Extensions/AngelscriptVSCode/`) and not the in-process SDK facade (`asCLanguageService`). JSON-RPC remains a later adapter.

```
Plugins/Angelscript/AngelscriptLSP/     // dormant host directory (this layout)
Extensions/AngelscriptVSCode/          // TypeScript LSP client + server
asCLanguageService                      // in-process SDK; no JSON-RPC
```

## Evidence

- Working tree move from `Standalone/` to `AngelscriptLSP/`.
- `AngelscriptLSP/CMakeLists.txt` still `project(AngelscriptStandalone)`.
- Diagnostics tooling Change: JSON-RPC out of scope.

## Boundaries

- Does not certify a working host binary.
- Does not add an AngelscriptLSP UE module.
- SDK compile root is `Source/AngelscriptRuntime/angelscript/`.

## Application

Use `AngelscriptLSP/` in live path instructions. Keep saying Standalone when the subject is the CLI, CMake project, tests prefixed `AngelscriptStandalone.*`, or the dormant support matrix.

## Sources

- `attachments/drafts/findings/directory-moves.md`
- `attachments/drafts/design.md`
