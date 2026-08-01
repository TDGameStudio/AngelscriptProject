# Phase 01 LanguageCore reconciliation

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


Status: passed for the V1 extracted/shared slice.

The final external-consumer, Release-package, regression, and path-scope
reconciliation is recorded in `v1-closeout-20260801.md`; that record is the
current authority for counts and hashes.

Implemented:

- standard-C++ platform, source, UTF-8 span/map, path/module identity, lexical
  range, condition/import session, declaration values, type oracle, rewrite
  plan, and structured diagnostic records;
- the same sources compile in UBT and CMake;
- `ANGELSCRIPT_LANGUAGE_STANDALONE` is confined to the platform header and
  CMake propagation;
- standalone source graph/compiler/class analysis consumes LanguageCore;
- the UE facade consumes the parity-proven module-name and range-for rewrite
  algorithms while preserving every public API, summary, callback, descriptor,
  and ClassGenerator owner.

Evidence:

```powershell
ctest --preset win64-msvc-debug -R AngelscriptStandalone.LanguageCore --output-on-failure
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor" -Label standalone-final-preprocessor-v7 -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler" -Label standalone-final-compiler-v7 -TimeoutMs 600000
```

- LanguageCore CTest: passed in the final `17/17` Standalone suite.
- Preprocessor: `60/60`, report
  `Saved/Tests/standalone-final-preprocessor-v7/20260731_092545_314_c7b68e77`.
- Compiler: `81/81`, report
  `Saved/Tests/standalone-final-compiler-v7/20260731_092712_484_15d46d2e`.

The complete UE facade/descriptor lowering and automated full frontend parity
corpus are not claimed by this release. Their explicit follow-up OpenSpec is
strictly valid and contains the characterization-first migration plan.
