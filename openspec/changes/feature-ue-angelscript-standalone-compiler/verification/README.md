# Standalone Verification Records

This directory stores milestone evidence for the single `feature-ue-angelscript-standalone-compiler` OpenSpec lifecycle.

Create these records only when the corresponding workstream has fresh evidence:

- `phase-00-feasibility.md`
- `phase-01-portable-native.md`
- `phase-02-offline-contract.md`
- `phase-03-analysis-core.md`
- `phase-04-template-adapters.md`
- `phase-05-resource-validation.md`
- `phase-06-release.md`
- `final.md`
- `compat-first-20260801.md` (targeted fork-minimization correction and fresh
  standalone/UE regression evidence)

Each phase record must include:

- commit and workspace identity;
- exact standard commands;
- exit codes and test/build counts;
- relevant artifact hashes;
- resolved bundle source/kind/path/hash, symbol completeness, and independent asset completeness for UE-validation evidence;
- default-bundle double-export identity and explicit-project replacement/no-fallback evidence where applicable;
- architecture, privacy, determinism, differential, resource, or performance results owned by that phase;
- every known disagreement, deferral, or unsupported classification;
- links to machine-readable evidence kept under the change directory;
- whether the phase exit gate passed.

Phase verification does not archive the OpenSpec. The change is archived only after the complete first-release contract passes `final.md`.
