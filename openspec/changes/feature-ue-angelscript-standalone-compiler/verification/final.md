# Final implementation reconciliation

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


Status: implemented, freshly verified, and archive-ready as of 2026-08-01.
The change has not been archived or committed in this work session.

## Delivered outcome

`Plugins/Angelscript/Standalone` is a Win64 no-Unreal compiler/runtime product
that builds the authoritative maintained fork and shared portable language
sources. Native AngelScript compiles and executes inside the documented
bounded profile. UE-AngelScript compiles only against one final-engine JSON
bundle and cannot execute.

The original global/manual/generated/reflected binding code remains entirely
UE-owned and unchanged in shape. UE exports the final registered semantic
surface once; standalone reconstructs declaration/type behavior with
non-executable traps. Third parties therefore need no second standalone bind
implementation and no per-bind macro.

## Required boundaries confirmed

- only native artifacts execute;
- UE-validation artifacts are neither executable nor advertised as
  UE-loadable;
- explicit project bundle replaces packaged default; no merge or fallback;
- no native pointer/address, source/body, bytecode/executable, asset payload,
  private machine path, or second project-kind bundle is shipped; the one
  packaged default now intentionally reflects the declared
  `AngelscriptProject` project/plugin scope;
- no file/network/process/dynamic-library/arbitrary FFI native surface;
- no standalone branch/exporter hook in existing binds or ClassGenerator;
- current mutable-global rejection and raw-handle policy are unchanged;
- DebugServer V2 and the VS Code extension were not changed; offline editor
  projection remains optional future work.

## Evidence map

- current Compat-first fork minimization and fresh standalone/UE regressions:
  `compat-first-20260801.md`;
- architecture/native: `phase-00-feasibility.md`,
  `phase-01-portable-native.md`;
- shared language boundary: `phase-01-language-core.md`;
- producer and deterministic bundles: `phase-02-offline-contract.md`;
- UE compile-only analysis: `phase-03-analysis-core.md`;
- template adapters: `phase-04-template-adapters.md`;
- resources and parameter markers: `phase-05-resource-validation.md`;
- official suites/package/hashes: `phase-06-release.md`;
- final external-consumer, Release, regression, and path-scope reconciliation:
  `v1-closeout-20260801.md`;
- machine-readable project evidence:
  `Standalone/Tests/Evidence/project-v6.json` and
  `project-v7-resource-contract.json`.

## Deliberate follow-up

The complete UE preprocessor-to-LanguageCore facade/descriptor ownership
migration is not disguised as complete. It is a separate, strictly valid
OpenSpec:

```text
refactor-as-language-core-ue-facade-parity
```

It does not block standalone binding portability because the complete JSON
snapshot is the V1 process boundary. It must use characterization and
normalized descriptor/callback parity before deleting any mature UE logic.

## Current completion authority

- Debug Standalone: `19/19 PASS`;
- Release Standalone/package: `19/19 PASS`;
- external content-only consuming project: two byte-identical Project exports,
  installed-CLI `ue-validation/project` compile complete, bundle identity exact;
- active Native SDK: `691/691 PASS`;
- OfflineContract runtime/editor: `11/11`, `9/9`;
- Preprocessor/Compiler/Bindings: `60/60`, `81/81`, `244/244`;
- UE Development build: passed;
- product version validation: passed;
- both active OpenSpecs strict validation: passed;
- root/plugin path-scope and whitespace audits: passed without modifying the
  unrelated user-owned Coverage and TestMacros worktree changes.

Exact commands, report paths, package hashes, bundle hashes, warning context,
and the red/green remediation history are recorded in
`v1-closeout-20260801.md`.
