# Task 7.7 Platform Verification

## Outcome

Task 7.7 records and installs application, command-line, platform, path, file, parsing and process-mode global providers in a fresh Engine. The eleven providers contribute exactly 74 members and 7 explicit native recipes. Six tests cover read-only host state and one method-owned temporary file; no process or URL is launched and all mutable file state is removed by the fixture.

## RED and implementation

- Build `2b584598ad1a4b2aa0ee7b8e502f2237` found one fixture parenthesis error before execution; build `e5f763c8cc1b42d59c19de7881a9f170` then passed.
- Run `232fd999d36f4864b429497c243ec3a4` discovered all six tests and asserted because `CoreGlobals` inspected a target Engine while recording. The compatibility-only native descriptor now skips detached recording while remaining available in direct StaticJIT generation.
- Run `f3ecd713fe8d4c43972f09cbd1a26813` produced six behavioral failures: installation atomically rejected `FGenericPlatformMisc::RequestExit` because the declared one-argument binding pointed at a C++ function with an additional defaulted call-site parameter. The provider now uses an exact one-argument adapter.
- Run `9723fddc6226452993f7326e987831bb` exposed the same ABI defect for `FPaths::CollapseRelativeDirectories`, whose C++ target has an additional defaulted Boolean parameter. It now uses an exact adapter.
- Run `071b0487c2234b87b078d53b3f5b8a6e` passed four cases and corrected two fixture expectations to the public platform contracts: failed `LoadFileToString` clears its output, and joined `..` components require an explicit collapse operation. Run `253f8d1449ae41cf99148a6a00014a1d` passed five cases and established the exact 74-contribution/7-recipe surface.
- All platform namespaces now use the detached recording scope. Exit and launch declarations are accounted for but never invoked by tests.

## Exact GREEN

Command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Platform.'; Fast = $true; TimeoutMs = 600000 }
```

Harness run `a2036c43850b4c1fa7ac08242123039e` passed 6/6 with zero warnings and zero errors:

- `CommandLineMatchesCapturedHostString`
- `MissingFileReturnsFailureAndRetainsOutput`
- `ParseFindsKnownInteger`
- `PathsCombineAndNormalizeKnownComponents`
- `ProcessLaunchMetadataAndEveryProviderAreAccounted`
- `TemporaryUtfTextRoundTripsAndCleansUp`

Final build `f9099e10ee9243a7a1e2e2ec9f7d202c` succeeded. Relevant SHA-256 identities are:

- `Bind_CoreGlobals.cpp`: `2ac2546f09ff32179ff5c5aedec7dadb13289edc1bb296b7ca6b987fd06290d7`
- `Bind_FGenericPlatformMisc.cpp`: `0c36d354ec2b8573b18b7847f95f967acdb06ed00622028619b9f2dd2f900b2e`
- `Bind_FPaths.cpp`: `f7e3a9c80e508efd8d4521dff1f03e6d3284e3ce69329ed9ad849fd279c8b512`
- `RuntimeBindingPlatformTests.cpp`: `ad99c818d7bd0aa5d2de9f08b7192105be741294b9c2da0adb868daa61a4d634`
- `UnrealEditor-AngelscriptRuntime.dll`: `7242d670e8c86f263a16a90e4754dc589aed34fe54ad795b9842f475c0cc19f4`
- `UnrealEditor-AngelscriptTest.dll`: `85a5c7833b84e20ef0141afdbb70bc9b738397b4069b5dbf78bd6fdcd74033d8`

## Shared regression proof

Harness run `1cf0d876ff4647e0bedccca381ceb0bd` selected `Angelscript.UnitTest.RuntimeBindings.` and passed 290/290 with zero warnings, errors, skips or incomplete tests against the same binary identities. This is the affected recording, declaration, native-link and owner-lifetime regression scope. No broader suite was selected because the demonstrated impact remains inside RuntimeBindings.
