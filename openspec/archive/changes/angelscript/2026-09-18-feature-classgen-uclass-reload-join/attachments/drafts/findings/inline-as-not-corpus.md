# Do not use the Language database

Translated from draft `findings/inline-as-not-corpus.md`. Approval R15.

Do not read `AngelscriptTestCode` / `FAngelscriptTestCode`. Embed `.as` strings in the NativeEngine cases, following old HotReload. The Language corpus tests are not a landed execute path.

## Rejected

Compiling `Language/Casting/NullHandle.as`, `LanguageFixtureCorpus`, or 807 `@begin` pockets. Those files stay authors only.

Do not port `Legacy/AngelScriptSDK/Language/*`.

## Adopted

Old HotReload shape: inline source; if `UCLASS(` is present, preprocess fills descriptors; then `CompileModules`.

Phase 1 embeds two scripts (trimmed from `SoftReloadUpdatesMemberFunctionBody` / `SoftReloadKeepsBlueprintChildInstance`): `UCLASS` + `UPROPERTY Version` + `UFUNCTION GetVersion`, then SoftReload `return Version + 1`, plus `CreateBlueprint`.

Phase 2 embeds a FullReload add-`UPROPERTY` script and a broken script (from `FailureKeepsOldCode`).

New tests live under `NativeEngine/Compile/`. Do not revive Legacy `.cpp`.
