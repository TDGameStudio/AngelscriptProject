# Phase 06 release evidence

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


Status: passed and archive-ready. The real UE 5.8 `AngelscriptProject` default,
Debug and Release Standalone suites, final package, external content-only
consumer, installed CLI, UE regressions, documentation, and strict validation
all pass. Exact closeout evidence is in `v1-closeout-20260801.md`.

## Current UE 5.8 packaged default

The packaged contract is generated from the checked-in
`AngelscriptProject.uproject` and normally enabled plugin set:

- Unreal version: `5.8.0-55116800+++UE5+Release-5.8`;
- producer project: `AngelscriptProject`;
- symbols/assets: `130068` / `9`, both scopes complete;
- bundle identity:
  `f40af33a32752146226f0ed92eaaed7c6e35de4c14caa27c969527237c80ae1c`;
- source archive:
  `Standalone/Contracts/UE5.8/default-engine.zip`;
- source archive size/hash: 20,377,909 bytes,
  `1af0373bba10bcf50ce12a36ea7b7238570f7414a9b04a8404d0dd74d4813dd8`.

The source archive is only a repository storage representation. CMake
extracts it, verifies the declared hashes of all three contract files, and
ships only `contracts/default-engine/{manifest.json,symbols.jsonl,assets.jsonl}`.

## Official final suites

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite StandaloneRelease -TimeoutMs 1200000
```

- Debug report:
  `Saved/StandaloneTests/Standalone_01_Standalone/20260801_182124_764_76aa6eeb`;
- Release report:
  `Saved/StandaloneTests/StandaloneRelease_01_StandaloneRelease/20260801_183516_217_a0079028`;
- CMake configure/build/package target: passed;
- Debug and Release CTest: `19/19` each, zero failures;
- includes smoke, semantic observer, LanguageCore, add-ons, CLI and both E2E
  profiles, runtime, contract, UE analysis, adapters, resources, architecture,
  package, corpus/differential contract, soak, and benchmarks.

Final active Native SDK authority:

- `691/691`, zero failures/skips,
  `Saved/Tests/standalone-v1-final-sdk/20260801_182826_656_d2f425ac`.

Fresh UE focused authority:

| Prefix | Result | Report |
| --- | --- | --- |
| OfflineContract runtime | `11/11` | `Saved/Tests/standalone-v1-final-offline-runtime/20260801_182653_807_46878a02` |
| OfflineContract editor | `9/9` | `Saved/Tests/standalone-v1-final-offline-editor/20260801_182750_180_014f7dfd` |
| Preprocessor | `60/60` | `Saved/Tests/standalone-v1-final-preprocessor/20260801_183118_325_8cd5acf3` |
| Compiler | `81/81` | `Saved/Tests/standalone-v1-final-compiler/20260801_183038_118_c03b22df` |
| Bindings | `244/244` | `Saved/Tests/standalone-v1-final-bindings/20260801_183218_303_1041cde5` |

UE Development build:
`Saved/Build/standalone-v1-final/20260801_182640_789_41f08aab`,
success.

## Current Release package

Commands:

```powershell
cmake --build --preset win64-msvc-release --target AngelscriptStandalonePackage
ctest --preset win64-msvc-release -R AngelscriptStandalone.Package --output-on-failure
```

Result:

- package inspection: `1/1`, passed;
- archive:
  `Plugins/Angelscript/Standalone/out/build/win64-msvc/package/Release/as-standalone-win64.zip`;
- archive size: 22,069,867 bytes;
- archive SHA-256:
  `a8767c92445eb6268474e02edd455aea4d4753bcbbae1c965a3b10fc2b0f30d3`;
- package manifest SHA-256:
  `5916c075a13af766424d16bb941f8c40e059cff4df7ffd49153f039e02969b37`;
- exact manifest count: 17 files;
- separate project-kind bundles: absent;
- embedded source ZIPs: absent;
- installed help/version, native example, real UE 5.8 packaged-default UE
  example, external Project bundle export, and explicit Project compile: passed;
- symbol, asset, manifest, result, differential-result, and corpus schemas:
  included and JSON-parse valid.

Version validation:
`Unreal AngelScript 1.0.0`, encoded `10000`, passed.

Final verification for V1:

- UE Development build:
  `Saved/Build/standalone-v1-final/20260801_182640_789_41f08aab`;
- Runtime OfflineContract: `11/11`,
  `Saved/Tests/standalone-v1-final-offline-runtime/20260801_182653_807_46878a02`;
- Editor OfflineContract: `9/9`,
  `Saved/Tests/standalone-v1-final-offline-editor/20260801_182750_180_014f7dfd`;
- Standalone Debug and Release: `19/19` each;
- external content-only consumer:
  `Saved/StandaloneExternalSmoke/20260801_183731_228_ddb2b2d7/Summary.json`,
  passed with byte-identical exports and installed-CLI identity agreement;
- strict validation: both
  `feature-ue-angelscript-standalone-compiler` and
  `refactor-as-language-core-ue-facade-parity` passed.

## Claim boundary

Corpus: 13 reviewed entries, 11 supported, one ue-required, one unsupported;
eight supported entries use complete-project evidence. Test-count scopes
remain separate. No blanket Unreal parity, UE execution, UE-loadable artifact,
or OS-sandbox claim is made.
