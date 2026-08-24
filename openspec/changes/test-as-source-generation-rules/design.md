# Context

This design follows the manual-bind source organization work but deliberately stops before test-driver integration. Its job is to make source generation deep, reviewable, reproducible, and exportable before asking any runner to consume it.

The quantitative planning snapshot is:

- 614 exact legacy manual-bind authored-export candidates from the existing downstream catalog; the upstream `test-as-manual-bind-source-coverage` plan separately owns the canonical 3,041-source / 11,987-callable / 249-source-only denominator;
- 271 exact Native SDK source-generator products covering 45,760 mandatory cells;
- 90 `Coverage/*.cpp` files containing 1,022 `TEST_METHOD`s;
- 3,559 current inline AS source units in `AngelscriptTest`, including all 2,374 `ASTEST_AS*` macro invocations;
- 1,311 initial future static-function entries: 614 downstream authored-export candidates, 271 SDK products, 260 Coverage generation candidates, and 166 non-Coverage inline candidates.

The Coverage/inline candidate counts are a reproducible first disposition, not permission to generate or adopt those tests. Each owning-file review task must confirm the finite axes and oracle before a candidate rule is implemented.

## Goals

- Make explicit coverage matrices exhaustive and independent of seed.
- Add useful variability without making failures irreproducible or changing the intended test surface.
- Represent the real observation depth of the repository instead of treating every test as `int == value` or compile-pass/fail.
- Support authored and generated source through one complete result type and one generated plugin API.
- Keep generation rules and development tools outside the plugin; keep only final generated C++ release artifacts inside it.
- Inventory current source precisely enough that implementation work can proceed per AS file/product/method.
- Preserve current tests until a separate adoption OpenSpec explicitly selects and validates replacements.

## Non-goals

- Compiling or executing generated AS in this OpenSpec creation pass.
- Replacing any Native SDK builder, Coverage method, inline literal, or manual-bind test.
- Moving current inline AS into `TestSource` as part of this change.
- Building a coverage-guided fuzzer, reducer, long-lived corpus, network service, or Unreal-aware random API caller.
- Making Python call the C++ implementation or C++ invoke Python. Parity must compare independent implementations.
- Requiring a rigid prose template for AS comments.

# Responsibility boundaries

| Owner | Authoritative responsibilities | Explicitly excluded |
| --- | --- | --- |
| `TestSource/Generation` | Versioned schemas, recipe data, authored-case index, small reviewed goldens, semantic comment facts, stable identities | Python/C++ implementation logic, Unreal runner code, bulk generated output |
| `Tools/AngelscriptCodeGen` Python | Rule authoring ergonomics, inspection, explicit Saved/temp output, independent reference implementation, static C++ release emission | UE runtime dependency, plugin shipping content, process-global RNG |
| `Tools/AngelscriptCodeGen/cpp` | Standard-C++ independent implementation, parity driver, release emitter, deterministic algorithms | Unreal types, Python embedding, `std::random` as observable RNG |
| `Plugins/Angelscript/.../Generated/TestCode` | Generated public value/API declaration, per-CaseKey static functions, sorted dispatch, embedded source/manifest/oracle | JSON/rule files, Python, generator executable, TestSource `.as`, static registrars, ForceLink |
| Existing C++/AS tests | Execution authority and behavioral oracle until later adoption | Implicitly switching to generated source in this change |
| This OpenSpec | Design, specifications, inventories, tasks, research, and validation | Product/source implementation during the current plan-only pass |

# End-to-end model

1. A caller selects a stable `CaseKey`, recipe ID, complete explicit-axis request, and unsigned 64-bit seed.
2. The rule engine enumerates every explicit matrix cell in canonical order. Seed never filters, samples, adds, or removes these cells.
3. For each cell, named random substreams select only the recipe-declared legal literal, boundary representative, identifier, independent declaration order, optional legal combination, or grouping.
4. The emitter returns canonical AS source bundle entries plus a canonical manifest and complete typed oracle. Generated source is in memory unless an explicit output mode is requested.
5. Python and portable C++ run the same request independently. Their source bytes, manifest bytes, CaseKeys, cell ordering, oracle payloads, and errors must match.
6. An explicit release command converts reviewed authored/generated cases into generated C++ functions. The plugin does not need the development rules to read those results.

# Shared generation contract

## Request

The versioned language-neutral request contains:

- schema version;
- stable `CaseKey` and origin;
- recipe ID and recipe version;
- complete explicit axis selection or request for canonical full enumeration;
- unsigned 64-bit seed;
- optional named output mode;
- reference IDs and required harness capabilities.

It never contains an absolute workspace path or an implementation-specific random-engine state.

## Result

One `FAngelscriptGeneratedCase`-equivalent result contains:

- origin, CaseKey, recipe/version, seed, and all selected axes;
- one or more logical source bundle entries with canonical UTF-8 bytes;
- canonical manifest bytes;
- zero or more executable cells with declaration/entry point and argument data;
- typed oracle variants;
- negative-mutation identity, diagnostic anchors, and corrected recovery source when required;
- knowledge-comment facts and source/reference provenance;
- required harness and cleanup/isolation contract.

The result is complete even when the immediate test only consumes one field. This prevents the earlier shallow-generator problem where a source string existed without adequate expectations.

# Stable identity

CaseKeys are logical, slash-separated, extension-free identities:

- authored: `TestSource/<relative path without .as>`;
- SDK product: `NativeSDK/<ProductId>`;
- Coverage candidate: `Coverage/<relative cpp without extension>/<Method>`;
- other inline candidate: `Inline/<relative cpp without extension>/<Method>/<ordinal>`.

Absolute paths, drive letters, checkout names, and source line numbers are evidence, not identity. A UTF-8 FNV-1a hash is used only where a fixed-width suffix/key is necessary. C++ symbols are deterministic sanitized names with collision validation; the canonical CaseKey remains the public identity.

# Exhaustive coverage and controlled randomness

## Mandatory matrix first

Every reviewed recipe declares explicit axes and constraints. The Cartesian product after constraints is canonical and exhaustive. A product that declares 15 types × 4 directions always produces 60 cells for every seed. Changing the seed cannot turn 60 into 59 or 61.

## Portable random algorithm

Observable randomness is `SplitMix64-v1`. Seed/case/cell/slot derivation uses specified unsigned 64-bit operations and UTF-8 CaseKey hashing. Bounded selection uses rejection sampling; permutations use deterministic Fisher-Yates. Named substreams prevent inserting a new random choice in one slot from perturbing unrelated slots.

The following are prohibited for observable output because they cannot provide the required cross-language contract: Python `random.Random`, C++ standard random distributions/engines, Unreal `FRandomStream`, process-global state, time-derived default seeds, and platform hashes.

## Legal random slots

Recipes may vary:

- legal literals and representative boundary values within a frozen semantic class;
- collision-free identifiers that do not affect lookup meaning;
- order of declarations proven independent;
- optional combinations explicitly declared legal;
- grouping/parenthesization that preserves the tested semantics.

Recipes may not vary:

- membership of explicit coverage axes;
- expected semantic/diagnostic/lifecycle outcome;
- which single invalid mutation a negative cell represents;
- required recovery/cleanup/isolation source;
- harness requirements;
- source formatting contracts that are themselves under test.

# Generation surface

The first contract supports the following source families, recorded in `catalogs/recipe-family-registry.csv`:

- authored source export;
- declarations, namespaces, enums, typedefs, classes, interfaces, mixins, and publication order;
- function return/parameter types, arity, position, direction, call form, and writeback;
- expressions, operators, conversions, assignments, evaluation order, and boundaries;
- statements and control transfer;
- `UCLASS`, `USTRUCT`, `UENUM`, `UINTERFACE`, `UPROPERTY`, and `UFUNCTION` shapes;
- arrays, maps, sets, dictionary-like and element/key/value operations;
- lexical/parser/preprocessor source bundles and positions;
- compiler stages, metadata, bytecode, runtime, module/import/save-load, type-system, embedding, debug, GC/ownership, cleanup, and isolation cases;
- negative cases built as one named mutation from a valid baseline, plus corrected recovery source when the current oracle observes recovery.

World/Actor/network/hot-reload and other UE-host stories are not inferred from their syntax. They remain authored specialized scenarios unless a later review proves a finite source-only product and retains the exact host fixture.

# Authored Contract V2 import boundary

Authored export is a consumer of the reviewed `authored-case-contract-v2` rows from `test-as-manual-bind-source-coverage`, not a second source of authored test semantics. Its implementation cannot start merely because an audit draft exists: the primary change must first reconcile and receive user acceptance for its normalized plan, then materialize reviewed source-parity-clean contracts. Each exported callable is keyed by stable `caseId` plus `subcaseId` and carries the exact declaration parsed from the current `.as` source, the semantic entry-point name, typed invocation vectors, raw return oracle, explicit `&out`/`&inout` writebacks, exact exception oracle, adjacent knowledge-comment facts, fixture/cleanup/isolation metadata, and truthful runner status. Source-only authored files export their reviewed source assertion/diagnostic bundle without a fabricated entry point.

The v1 `Rules/Authored` files and `plannedSymbols` fields remain readable only to prove migration completeness. Export MUST fail closed when no reviewed V2 row exists, when source/declaration parity fails, or when a legacy list contains multiple possible symbols. It MUST NOT split semicolon-delimited strings and guess a declaration or entry point. V2 contracts remain owned and generated under `TestSource/Generation/Contracts/**`; the Python and C++ export adapters consume the same canonical rows and may not rewrite them.

# Typed oracle model

The oracle is a tagged, lossless data model rather than an `ExpectedInt` shortcut. Initial kinds include:

- compile status and exact diagnostic anchors;
- signed/unsigned integers with width, booleans, float/double bit/tolerance rules;
- string, name, text, enum, math struct, and aggregate values;
- object/reference identity and nullability;
- out/inout writeback and receiver/container state;
- reflected metadata, declaration, type ID, size/layout, and publication owner;
- bytecode shape/hash, trace/event order, and source position;
- exception state/payload where publicly observable;
- lifecycle counters, cleanup, GC ownership, and isolation;
- module/import/bind state, save/load identity, recovery, and corrected rebuild result.

Return values are always consumed when meaningful. Void functions require a post-state, callback/trace, diagnostic, metadata, lifecycle, or cleanup observation; “compiled successfully” alone is not accepted when the existing test checks more.

# Negative generation

Every negative cell starts from a valid source generated by the same recipe. It applies exactly one named mutation, freezes the mutation and diagnostic anchor, and retains all unrelated baseline facts. When the source test checks atomic failure, cleanup, isolation, or same-name rebuild, the result also includes a separately named corrected recovery source. Random byte/token corruption is outside this change.

# Knowledge comments

Generated and authored-export manifests carry structured comment facts:

- what language/UE/binding behavior the source exercises;
- concrete selected inputs and important state;
- exact expected values, diagnostics, metadata, side effects, lifecycle, or cleanup;
- ownership/boundary/recovery information when important;
- evidence/reference IDs.

Renderers may organize these facts differently for a small expression, a definition, a lifecycle case, or a negative/recovery bundle. Tests validate semantic presence and attachment, not one mandatory sentence layout.

# Canonical output and ownership

AS source is UTF-8 without BOM, uses LF, and ends with exactly one newline. Canonical manifests use a fixed schema/key order, compact separators, specified escaping, and LF. Both implementations must emit identical bytes and stable errors.

Generation returns memory values by default. Explicit modes may write:

- ignored `Saved`/temporary diagnostics;
- a deliberately small reviewed golden set under `TestSource/Generation/goldens`;
- generated plugin `.h`/`.cpp` release artifacts.

Bulk generated `.as` files and corpus history are not committed. `script-corpus` is not revived.

# `FAngelscriptTestCode` release API

The old experimental name is retained because it expresses the role better than “TestCenter”, but its registry architecture is not retained. Planned value types include:

- `EAngelscriptTestCodeOrigin`;
- `FAngelscriptTestCodeAxisValue`;
- `FAngelscriptTestCodeCell`;
- `FAngelscriptTestOracle`;
- `FAngelscriptGeneratedCase`;
- `FAngelscriptTestCode`.

For each product or authored fixture, generation emits one named static function returning the complete case. It does not emit one C++ function for each of the 45,760 expanded SDK cells; cells remain data within the product result. A generated sorted table implements `TryGenerateByCaseKey`, `EnumerateCaseKeys`, and `EnumerateCells`. There are no static registrar constructors, mutable global `TMap`, linker ForceLink calls, or load-order-dependent discovery.

# Inventory and task derivation

The planning scripts are intentionally checked into this OpenSpec so the plan is auditable:

- `ExportCoverageMethodInventory.ps1` must reproduce 90 files and 1,022 methods;
- `ExportCurrentInlineAsInventory.ps1` must inventory every `ASTEST_AS*` invocation plus likely direct AS raw literal;
- `BuildGenerationTaskCatalogs.ps1` joins the 614 manual-bind paths and 271 SDK product/cardinality records, produces recipe/static registries, and generates detailed tasks;
- `ValidateGenerationRulePlan.ps1` rejects count, identity, field, task-body, disposition, or scope drift.

Automatic disposition is a planning candidate. `AuthoredExport`, `GeneratedRecipe`, and `SpecializedScenario` have different consequences, and every owning file has an explicit review task before candidate implementation.

# Adoption boundary

This change is additive. Even after rules and release functions are implemented, current tests continue calling their current builders/literals. A later OpenSpec must explicitly select consumers, compare current/generated source and behavior, define rollback, update runner ownership, and remove old code only after equivalent or stronger evidence. That phase wall is intentional because source generation and test-driver migration have different risks.

# Risks and mitigations

- **False confidence from random samples:** explicit axes are exhaustive and seed-independent; seed sweeps are additional variation only.
- **Python/C++ drift:** implementations share schemas/data/goldens, not implementation code, and every release is byte-compared.
- **Shallow expectations:** result validity requires typed oracle completeness appropriate to the recipe and current reference test.
- **Over-generating UE scenarios:** host-coupled cases default to specialized authored scenarios; syntax alone is insufficient for promotion.
- **Huge generated C++:** one static function per product/fixture, product cells stored compactly, deterministic theme shards, and stale-output manifests.
- **Static initialization order:** generated immutable dispatch tables replace registrars and ForceLink.
- **Brittle comments:** tests check knowledge facts rather than exact prose.
- **Inventory drift:** scripts rescan current main sources and fail on baseline changes instead of silently carrying stale counts.

# Decisions and rejected alternatives

- **Chosen:** `TestSource` owns reviewed source/rules; plugin owns release output. **Rejected:** keep source-generation truth inside the plugin, because it couples authoring tools to the deliverable.
- **Chosen:** Python and portable C++ are independent peers. **Rejected:** C++ embedding Python or Python wrapping one C++ implementation, because that proves integration rather than semantic parity.
- **Chosen:** exhaustive matrices plus controlled random slots. **Rejected:** pure fuzz sampling for required coverage and pure fixed source for every repeatable variation.
- **Chosen:** one static function per product/fixture. **Rejected:** one function per cell (release bloat) and one runtime registrar per case (load-order/linker complexity).
- **Chosen:** complete result/oracle. **Rejected:** source-only string or `ExpectedInt` as the general contract.
- **Chosen:** no replacement in this change. **Rejected:** migrating builders while rule semantics and parity are still being established.
