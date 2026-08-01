# Standalone-private frontend correction verification — 2026-08-01

## Outcome

The shared Runtime `Language/` direction was removed. UE keeps the original
`FAngelscriptPreprocessor` implementation and descriptor/ClassGenerator
ownership. Standalone owns its standard-C++ frontend privately beneath
`Standalone/Source/Compiler/Frontend` in
`AngelscriptStandalone::Frontend`, compiled directly into
`AngelscriptStandaloneHost`.

There is no Runtime `Language/` directory, `AngelscriptLanguageCore` CMake
target, `ANGELSCRIPT_LANGUAGE_STANDALONE` definition, or
`UEAngelscript::Language` namespace in active source. The generated solution
contains `AngelscriptStandaloneHost` and
`AngelscriptStandaloneFrontendTests`, and contains no LanguageCore target.

## TDD and characterization evidence

- The initial architecture inversion failed as intended at `18/19`; the five
  reported boundary violations were the Runtime Language directory, missing
  Standalone frontend root, UE preprocessor delegation, LanguageCore
  CMake/macro surface, and generated target:
  `Saved/StandaloneTests/standalone-private-frontend-red_01_Standalone/20260801_220552_543_b9b72148`.
- The UE characterization build succeeded before ownership changes:
  `Saved/Build/standalone-private-frontend-characterization/20260801_220840_825_9964b2d8`.
- Preprocessor characterization passed `61/61` and Runtime OfflineContract
  characterization passed `12/12` before the final switch:
  `Saved/Tests/standalone-private-frontend-characterization-preprocessor/20260801_220919_400_b56380ac`
  and
  `Saved/Tests/standalone-private-frontend-characterization-offline-runtime/20260801_221047_924_41ed6e70`.
- The external-smoke utility self-test was observed failing under Windows
  PowerShell 5.1 for `Path.GetRelativePath`, then passing after the URI-based
  relative-path helper. A second red/green cycle covered the .NET SHA-256
  helper used when `Get-FileHash` disappeared after the Commandlet runs.

## Final verification

### Standalone Debug and Release

Commands:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix standalone-private-frontend-green-v4 -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite StandaloneRelease -LabelPrefix standalone-private-frontend-release -TimeoutMs 1200000
```

Results:

- Debug: `19/19 PASS`, including
  `AngelscriptStandalone.Frontend` and Architecture:
  `Saved/StandaloneTests/standalone-private-frontend-green-v4_01_Standalone/20260801_222144_517_048e2c5e`.
- Release: `19/19 PASS` and package target success:
  `Saved/StandaloneTests/standalone-private-frontend-release_01_StandaloneRelease/20260801_222435_874_7f6b3ec8`.
- Release archive:
  `Plugins/Angelscript/Standalone/out/build/win64-msvc/package/Release/as-standalone-win64.zip`,
  22,067,251 bytes, SHA-256
  `99eae2a099c69b35f71da0ebae9e630779afbcfeb20983d3c0c79d661248e290`.

### UE build and focused Automation

Commands:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label standalone-private-frontend-ue-sha-fix -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor" -Label standalone-private-frontend-final-preprocessor-v2 -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.OfflineContract" -Label standalone-private-frontend-final-offline-runtime-v2 -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.Editor.OfflineContract" -Label standalone-private-frontend-final-offline-editor -TimeoutMs 600000
```

Results:

- UE 5.8 Development build: exit `0`, `Result: Succeeded`:
  `Saved/Build/standalone-private-frontend-ue-sha-fix/20260801_224007_007_f068d924`.
- Preprocessor: `61/61 PASS`:
  `Saved/Tests/standalone-private-frontend-final-preprocessor-v2/20260801_223622_195_894e35a8`.
- Runtime OfflineContract: `12/12 PASS`:
  `Saved/Tests/standalone-private-frontend-final-offline-runtime-v2/20260801_224037_534_f37a9eeb`.
- Editor OfflineContract: `9/9 PASS`:
  `Saved/Tests/standalone-private-frontend-final-offline-editor/20260801_224151_359_186e2291`.

### External installed-package boundary

Command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunStandaloneExternalSmoke.ps1 -TimeoutMs 1200000
```

The final run used the rebuilt UE Runtime, exported the content-only external
project twice, compared the complete Project Bundle byte-for-byte, extracted
the Release ZIP, and completed `ue-validation` with the installed executable.
Result: `Passed`, bundle identity
`4cca84f065cc09cc08d8ca4f9ef37b4f82ae4b8186eb9088505e64d4ea9322ab`:
`Saved/StandaloneExternalSmoke/20260801_224231_175_aa478080/Summary.json`.

### Static and OpenSpec gates

- `openspec validate feature-ue-angelscript-standalone-compiler --type change --strict --no-interactive`: valid.
- `openspec validate refactor-as-language-core-ue-facade-parity --type change --strict --no-interactive`: valid.
- Parent and plugin `git diff --check`: exit `0`.
- Task-file trailing-whitespace scan: no matches.
- Runtime `Language/` existence check: `False`.
- Active implementation scan: no Runtime Language path, old namespace/macro,
  LanguageCore target, or `FPlatformMisc::GetSHA256Signature` use.
- UE preprocessor content diff against the plugin index: empty (`git diff
  --quiet` exit `0`).

## Corrections discovered during verification

1. A stale `AngelscriptLanguageCore.vcxproj` can remain in an incremental
   Visual Studio build directory after CMake removes a target. Architecture
   verification now inspects the generated solution target graph; the current
   solution has no LanguageCore target.
2. The first final range-for test expected whitespace emitted by the temporary
   shared implementation. The restored UE implementation intentionally
   preserves whitespace around the range expression. The test now freezes
   iterator lowering, type markers, and string/comment/classic-for behavior
   without canonicalizing UE-owned formatting.
3. UE 5.8 declares `FPlatformMisc::GetSHA256Signature`, but its generic
   implementation asserts and Windows provides no implementation. The offline
   producer therefore keeps a bounded one-shot SHA-256 implementation private
   to its new Dump identity translation unit; Standalone retains its separate
   streaming implementation. Canonical empty, ASCII, and non-ASCII vectors
   pass.
4. The external-smoke runner used APIs that were not reliable in the required
   Windows PowerShell 5.1 invocation. Relative-path and SHA-256 operations now
   use base .NET APIs, covered by the runner self-test, without changing plugin
   runtime behavior.

No commit, push, or OpenSpec archive was performed.
