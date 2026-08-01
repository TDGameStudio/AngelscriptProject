# Phase 00 feasibility and contract freeze

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


Status: passed for the reconciled V1 boundary.

The final external-consumer, Release-package, regression, and path-scope
reconciliation is recorded in `v1-closeout-20260801.md`; that record is the
current authority for counts and hashes.

## Workspace

- Parent baseline: `c99d47b50726bcea3f3713317d513ed27613f744`
- `Plugins/Angelscript` baseline:
  `dc99986febf1f0911a3ebfdc6d987cc3c0594907`
- Working tree: intentionally dirty with this implementation and unrelated
  pre-existing user changes; no unrelated file was reverted.
- Host: Win64, MSVC 17.14, CMake 3.25+, local Unreal Engine 5.8.

## Feasibility result

- CMake builds the authoritative maintained fork sources directly from
  `Source/AngelscriptRuntime/ThirdParty/angelscript/source`.
- CMake and UBT build the same `AngelscriptLanguageCore` sources.
- Standalone links no Unreal library/header/generated code and compiles no
  `Bind_*.cpp` or ClassGenerator source.
- The architecture gate rejects a copied fork/preprocessor, broad fake Unreal
  header, Unreal dependency, unapproved standalone macro, bind/ClassGenerator
  branch, unsafe native API, address/code-bearing bundle, profile mixing, or
  UE execution claim.
- Native same-input bytecode and deterministic result identity are stable.
- UE-validation used-function linkage is address-free and every imported
  callback is trap-backed.

## Frozen V1 boundary

- two profiles: executable `native-runtime` and compile-only `ue-validation`;
- one complete selected bundle; packaged default or explicit project
  replacement, never merge/fallback/search;
- `manifest.json`, `symbols.jsonl`, `assets.jsonl`, canonical UTF-8/LF and
  SHA-256 integrity;
- host-surface plus declaration-only active script baseline;
- no UE run command and no UE-loadable bytecode claim;
- current const-only globals and hidden raw-handle syntax remain unchanged.

Full UE preprocessor ownership migration was found unnecessary for the JSON
binding solution and unsafe to fake with an ignored shadow parse. It is
recorded separately in `refactor-as-language-core-ue-facade-parity`.

## Gate

Strict validation:

```powershell
openspec validate feature-ue-angelscript-standalone-compiler --strict
```

Result: exit `0`.
