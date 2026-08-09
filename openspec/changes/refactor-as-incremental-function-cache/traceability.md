# Requirement Traceability

This matrix maps every normative requirement in the change to its implementation task group and mandatory evidence. It is a planning artifact; no row is complete until the referenced tests/reports exist.

## `as-script-artifact-identity`

| Requirement | Tasks | Required evidence |
|---|---|---|
| Persisted script entities have deterministic full-width identities | 1.2–1.3 | `Cache.Identity.EntityKeysIgnoreProcessAndEnumerationState` and source-line stability |
| Module identity uses canonical logical source coordinates | 1.2–1.3, 4.1–4.2 | project relocation and case-collision tests |
| Every type and callable kind has a canonical owner | 1.2–1.3 | overload/synthetic ownership golden vectors |
| Pre-compile function input is independent from logical identity | 1.4, 4.3, 4.5–4.6 | body/dependency digest matrix and compiler-call counters |
| Compiled execution and debug content are validated separately | 1.4, 2.1–2.4, 4.3 | formatting/debug split and corrupt execution rejection |
| Compatibility, compilation context, and environment symbols are distinct | 1.4–1.5, 4.3–4.4 | Editor/Game profile and referenced/unrelated binding tests |
| Full 256-bit hashes are authoritative | 1.2–1.3, 2.4 | display-GUID collision and conflicting metadata rejection |
| Numeric FunctionId remains current-engine state | 1.6 | hot-reload route rebuild and two-engine isolation |
| StaticJIT consumes identity without owning Cache V2 | 1.7, 5.9 | provider miss/removal/mismatch VM fallback with unchanged Cache state |

## `as-incremental-script-cache`

| Requirement | Tasks | Required evidence |
|---|---|---|
| Cache V2 is logically segmented and physically packed | 2.1–2.3, 3.3 | record/archive golden data and no-one-file-per-function store inspection |
| Module activation is atomic | 4.7–4.8, 5.1–5.2 | missing-record rollback and successful complete restore |
| Exact source snapshots bypass preprocess parse and compile | 4.1–4.2, 4.9 | exact warm counters all zero |
| Changed modules retain unchanged function bodies | 4.3–4.6, 4.9 | one-body edit compiles exactly one function |
| Type schemas invalidate structural dependency closure | 4.3–4.4, 4.8 | property/inheritance/dependent-module matrix |
| Globals and initializer order are one module-state cache unit | 4.3–4.4, 4.7 | global initializer and hard-value dependency matrix |
| Invalidation uses typed semantic dependencies | 4.1–4.4 | full mutation matrix with exact stable keys/reasons |
| Cache V2 is a Saved-only immutable generation store | 3.1–3.2, 5.1–5.2 | empty first start and context namespace tests |
| Generation publication is atomic and recoverable | 3.4–3.6 | every injected crash point and concurrent writer test |
| Cache preparation is bounded parallel and deterministic | 3.8, 5.3, 5.9 | serial/random scheduling byte equality and multi-engine isolation |
| Loose source is authoritative over stale cache | 3.6, 5.1–5.2, 5.7 | fresh failure versus hot-reload last-good tests |
| Editor and PIE continuously maintain Cache V2 | 5.1–5.4, 7.3 | async Current/Pending transitions and real PIE behavior |
| Shutdown performs a bounded flush without late compilation | 5.5 | complete-before-timeout and timeout cancellation tests |
| Packaged runtime reload is configurable and code-only | 5.6–5.7 | Disabled/Manual/Automatic and RequiresRestart state machine |
| Runtime reload and cache controls are exposed through stable APIs | 5.6–5.8 | reflection, console and completion delegate tests |
| Cache settings have safe deterministic defaults | 5.6 | reflected default-value tests |
| Cache data is validated before allocation and engine mutation | 2.4, 3.6 | malformed manifest/pack/root/budget matrix |
| Legacy PrecompiledScript cache has no production path | 6.1–6.2 | legacy rejection and production reference scan |
| Diagnostics prove incremental behavior with stable identifiers | 5.8, 7.4–7.6 | deterministic JSON and package reports |
| Unreachable content is reclaimed outside startup | 3.7 | reachability/explicit compaction and no-startup-compaction tests |

## `as-cooked-packaging-runtime`

| Requirement operation | Tasks | Required evidence |
|---|---|---|
| MODIFIED: AngelScript Caches Are Staged | 6.3–6.4 | staged loose Script/`Binds.Cache` and legacy/baseline absence |
| REMOVED: Packaging Tooling With Precompiled Pre-Step | 6.2, 6.4 | no generation parameter/process/command and source scan classification |
| ADDED: Packaging tooling does not pre-generate script cache data | 6.3–6.4 | Development/Shipping package metadata and archive inspection |
| ADDED: Packaged runtime creates and updates Cache V2 from loose source | 5.2, 6.3–6.5, 7.4–7.5 | first-launch, invalid-source and structural cold-start package reports |
| ADDED: Real packages receive deterministic multi-launch cache verification | 6.5–6.6, 7.4–7.5 | separate Development and Shipping `CachePackage` summaries |

## Final Gates

- `Tools\RunTestSuite.ps1 -Suite Cache` covers focused unit/runtime integration.
- `Angelscript.TestModule.Cache.PIE` supplies actual Editor PIE lifecycle evidence.
- `Tools\RunTestSuite.ps1 -Suite CachePackage` supplies actual Development/Shipping executable evidence.
- `Tools\RunTestSuite.ps1 -Suite All` checks repository-wide regressions but intentionally does not rebuild packages.
- `verification.md` records exact counts, command exits, report paths, benchmark paths, legacy reference classification and any remaining limitations before completion is claimed.
