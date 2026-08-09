# Verification Evidence

## Static ownership audit — 2026-08-09

- All 55 providers in `candidate-inventory.md` no longer have a `Bind_<Name>_Functions.cpp` file.
- All 42 provider-private headers were removed after a repository include search found no external consumer.
- All 13 headers used by a sibling `Bind_<Name>_Type.cpp` remain present.
- Every selected main bind cpp still contains its named `FAngelscript<Name>Binds` owner declaration or a retained family header and contains the moved owner definitions.
- The 15 designated high-complexity geometry companion files remain untouched.
- `git -C Plugins/Angelscript diff --check` completed with no whitespace errors.

## Build attempt — blocked

Command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label compact-bind-functions -TimeoutMs 1800000 -NoHotReloadFromIDE
```

Report: `Saved/Build/compact-bind-functions/20260809_132512_878_6f053849/RunMetadata.json`.

The build stopped in unmodified `Bind_Primitives.h` and `Bind_Primitives_Type.cpp` before reporting an error in any selected compact provider. The exact errors are undefined `AS_CAN_GENERATE_JIT` preprocessor checks in `Bind_Primitives.h`, followed by missing `GetCppForm` declarations for `FFloatType`, `FDoubleType`, and `FUnrealFloatParamExtendedToDoubleType` in `Bind_Primitives_Type.cpp`.

The full `Bindings` and `StaticJIT.AOT` runs remain pending because they would execute stale binaries until this independent compilation baseline is repaired.
