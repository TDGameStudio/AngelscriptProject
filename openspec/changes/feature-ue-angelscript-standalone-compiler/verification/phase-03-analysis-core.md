# Phase 03 standalone UE analysis core

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


Status: passed for the published support matrix.

The final external-consumer, Release-package, regression, and path-scope
reconciliation is recorded in `v1-closeout-20260801.md`; that record is the
current authority for counts and hashes.

Implemented:

- integrity/compatibility checked single-bundle loading;
- deterministic source roots, import closure, script-baseline replacement,
  indices, registration passes, bundle type oracle, semantic observer, class
  model, support classification, and compile-only traps;
- packaged default and explicit project replacement with no merge, fallback,
  cache search, or environment lookup;
- deterministic `result.json`, `diagnostics.jsonl`, `.asbc`, and
  `.classes.jsonl`;
- absolute no-run/no-UE-load boundary.

Evidence:

- `AngelscriptStandalone.OfflineContract`, `UEAnalysis`,
  `UECliEndToEnd`, `Corpus`, and architecture/soak gates passed in the final
  suite.
- project-v6 evidence compiles representative Struct, Array, Map, Delegates,
  adapter matrix, map regression, delegate regression, and resource source
  against one complete project bundle.
- normalized differential-result contract compares only status, normalized
  diagnostics, stable symbols, portable class/resource subsets,
  classification, bytecode completion, and optional native result.
- no comparison field exists for bytecode bytes, address, runtime ID, prose,
  elapsed time, or machine path.

Known boundary: full automatic UE-facade-versus-LanguageCore frontend
descriptor parity is follow-up work and is not advertised as blanket parity.
