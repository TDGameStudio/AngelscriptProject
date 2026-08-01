# Phase 05 offline resource validation

Status: passed for static, typed contexts.

The final external-consumer, Release-package, regression, and path-scope
reconciliation is recorded in `v1-closeout-20260801.md`; that record is the
current authority for counts and hashes.

Implemented:

- normalized object/package/generated-class and mount paths;
- immutable asset/type/base/redirect/scope indices;
- found, redirected, missing, incompatible, and unknown states;
- object/generated-class assignability;
- bounded literals, const values, and deterministic concatenation;
- stable diagnostics, strict authoritative-missing policy, counts, and
  class/default diagnostic links;
- typed constructors/wrappers/properties/defaults/load calls and bundle-marked
  callable parameters;
- no asset/class load, resolve, cook, GC, or reflection execution.

The final exporter adds optional `resourceKind` and
`resourceTypeStableId` fields to callable parameters. Manual `LoadObject`
registration is marked by the final observer; reflected soft object/class
properties and explicit `AngelscriptResourceContext` metadata are marked
without changing any bind file. Standalone accepts the marker only after
compiler resolution to the stable callable ID and exact argument span.

Current project-v7 evidence:

- 37 non-empty parameter resource markers;
- two byte-identical complete bundle exports;
- strict compile of
  `Standalone/Tests/Corpus/Resources/project-known-path.as`;
- result: `complete`, found `1`, all other resource states `0`;
- result SHA-256:
  `4ff733d00b9f574393f70ae70da6ba3cfde03f276bcb288d77746cc3e41d9249`;
- committed machine-readable record:
  `Plugins/Angelscript/Standalone/Tests/Evidence/project-v7-resource-contract.json`.

A TDD regression covers the maintained fork's zero constructor call span with
valid argument spans. The red case failed resource recognition; the final
stable-ID/argument-span path passes and the real project script reports the
expected found asset.
