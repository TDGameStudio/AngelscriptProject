# Task 4.6 colors and Slate layout verification

## Scope

Task 4.6 records and installs the fixed native value surfaces owned by `FColor`, `FLinearColor`, `FAnchors`, `FMargin`, and `FGeometry`. UObject and widget customization remains assigned to task 7.4. The selected providers contribute exactly 101 members and namespace globals.

## RED and implementation

Initial exact run `db85c23e6d7f4fedbede9ac52c9a5c68` exited 3 before Automation could write a report. The crash stack identified `Bind_FColor.cpp:122`: its namespace scope dereferenced a null target Engine during detached recording. The same Engine-only construction existed in `FLinearColor.Functions`.

Both providers now construct `FAngelscriptBinds::FNamespace` from the recording-aware binds facade. The callbacks therefore retain their namespace functions and global variables without requiring an Engine. The first report-producing run `feaad671809b4f928febd0d53b13f55b` ran all six cases: five passed and the anchor case exposed an overly strict test comparison between float storage and double literals. The assertion now uses an explicit `1.e-6` tolerance matching the stored representation; no production behavior was changed for that test correction.

## Exact GREEN

Final build run `8e68ac465a9c4195bb4b4e573f0de985` succeeded. Exact run `69a2ed52e4cd4eae83219cffaf9bd48f` passed 6/6 with zero warnings and errors, exit 0. Summary SHA-256: `dfa40c03854407d488e9c466656a6a3e95bc2e4ef36f809aa62f05d9867f0c2a`.

Complete case paths:

1. `Angelscript.UnitTest.RuntimeBindings.Values.ColorsLayout.ColorsLayout.AnchorsRangePreservesMinimumAndMaximum`
2. `Angelscript.UnitTest.RuntimeBindings.Values.ColorsLayout.ColorsLayout.ColorConstructorPreservesOneTwoThreeFourChannels`
3. `Angelscript.UnitTest.RuntimeBindings.Values.ColorsLayout.ColorsLayout.CompleteProviderSurfaceAndPropertiesAreRecorded`
4. `Angelscript.UnitTest.RuntimeBindings.Values.ColorsLayout.ColorsLayout.IdentityGeometryLocalToAbsolutePreservesPoint`
5. `Angelscript.UnitTest.RuntimeBindings.Values.ColorsLayout.ColorsLayout.LinearBlackAndWhiteConvertToPackedEndpoints`
6. `Angelscript.UnitTest.RuntimeBindings.Values.ColorsLayout.ColorsLayout.MarginOneTwoThreeFourSumsToTen`

The cases prove byte channel round-trip, packed black/white endpoints, the four margin sides totaling ten, stored anchor endpoints, identity Slate coordinate conversion, required properties, and the exact 101-contribution provider inventory.

## Shared verification

Shared run `9d803b9c9ca040aba6995d88663642ac` passed 179/179 RuntimeBindings cases with zero warnings and errors, exit 0. Summary SHA-256: `8b819b0c12c756e3ac7edca1afd61cf062a5c3a6d2a08ecd03912ba99919829b`.

No Quick, Integration, Performance, legacy suite, or broader build was selected because the exact provider behaviors and the complete shared RuntimeBindings contract cover the demonstrated impact.

## Final identity

| Path | SHA-256 | Bytes |
|---|---|---:|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FColor.cpp` | `ad3052012a60a26f568f0bb7865d2f1ea415c1a357b7e12cdb84340359360a68` | 20366 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FLinearColor.cpp` | `94ce9302dcc2237f687bbc12d1dd244bb17afd6365eb68ea140c8a6dfd4ea64b` | 32418 |
| `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingColorsLayoutTests.cpp` | `ca60ac843eac61822e36883025ddedecfff4818abff93fec2bd814a74db15dc3` | 8182 |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` | `f683ce66bf16b9ccbfb2f66fb0c2e58cf9a4386067f8232948714b5df63d86bc` | 16536576 |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` | `ef6a6cd8fc7ce542155d93a6c636408ba7a8172f326455780bf19b715f6e4a50` | 8843264 |

