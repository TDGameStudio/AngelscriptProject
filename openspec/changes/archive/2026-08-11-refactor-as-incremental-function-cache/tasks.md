# Cache V2 Vertical Tasks

This is the current executable checklist. The superseded horizontal checklist is
preserved at `history/pre-vertical-refactor-2026-08-09/tasks.md`. Checkboxes are
dependency-sized outcomes, not equal units and never a completion percentage.

Implementation-scope guard for every vertical: all code under
`Plugins/Angelscript` is an authorized change surface, including the maintained
AngelScript fork's builder/compiler, bytecode, VM, module/function state and
restore internals. Extend the smallest coherent lower-level seam whenever Cache
V2 correctness or complete restoration requires it; this permission does not
require unrelated source churn or a change to existing `.as` language syntax.
The implementation may add or change maintained-fork internal APIs, state,
compiler/bytecode hooks, serialization and VM restore behavior; do not treat the
current AS lower-level API as an immutable boundary. No additional scope approval
is required before making a demonstrated Cache V2 change anywhere under
`Plugins/Angelscript`; progressively record its rationale, compatibility impact,
focused tests and verification evidence in this change.

## V0. Accepted foundation and execution reset

- [x] V0.1 Preserve full-width stable module/type/function/global/property keys,
  separated function source/input/content/profile identities and the StaticJIT-
  facing artifact tuple.
- [x] V0.2 Preserve the common record envelope, canonical reader/writer, Budget,
  SourceIndex/ModuleInterface baseline and frozen remaining-record/Pack/Store
  authorities.
- [x] V0.3 Archive the superseded current plan/tasks/status, publish the vertical
  decision/plan/status/traceability set, and pass strict OpenSpec/link checks without
  changing Runtime behavior.

## V1. Complete in-memory module artifact transaction

- [x] V1.1 Implement and link the focused TypeSchema Dependency slice: the exact
  five-kind local closure is one allocation-free validator shared by producer and
  decoder; it does not classify source files or resolve the module graph.
- [x] V1.2 Finish remaining TypeSchema local/hash/layout validation required by
  supported real module forms, with unsupported forms failing closed. Put new tests
  in files grouped by semantic family, but do not make historical test-file splitting
  a functional prerequisite.
- [x] V1.3 Implement private ModuleState, FunctionBody, DebugSidecar and
  ModuleSnapshot codecs plus seven-kind RecordId recomputation and one immutable
  candidate/promotion path.
- [x] V1.4 Implement the sole `ValidateModuleSnapshotGraph` traversal, exact keyed
  coverage/ownership/reference checks and atomic empty output on failure.
- [x] V1.5 Capture a representative clean-compiled module into the complete
  pointer-free record graph and round-trip it through the sole factory/graph in two
  isolated test engines.
- [x] V1.6 Run the complete Cache Archive/module-artifact focused regressions and a
  full Runtime/Test module build; record exact behavior evidence.

## V2. Generation data plane, Store and cold publication

- [x] V2.1 Implement deterministic aggregate Pack and complete Manifest
  construction, None/Zlib validation, exact reachability and serial/order
  determinism. IC-251 aggregate publication and IC-252 Manifest/Pack-index
  budgeting are GREEN; close IC-253's canonical-Zlib scratch and bounded
  reachability-queue audit before marking this complete.
- [x] V2.2 Implement Saved-only namespace selection, strict final/temp names and
  immutable Pack/Manifest put-if-absent with flush/close/reopen validation.
- [x] V2.3 Implement namespace locking, reread/rebase and old-or-new
  Current/Previous/PendingColdStart root publication.
- [x] V2.4 Implement pinned read sessions, cumulative Budget and explicit
  startup-external compaction/GC boundaries.
- [x] V2.5 Publish and reopen the first real cold generation from a successful
  normal compile without a package pre-step or forced process exit.
- [x] V2.6 Pass deterministic, corruption, cancellation, concurrent-reader/writer
  and Store fault-injection tests.
- [x] V2.7 Add a read-only standalone Python Cache V2 dump tool after the normal
  Manifest/Pack format is operational. Support deterministic text and JSON,
  generation/module/record-kind/stable-key filters, full Manifest/Pack/index and
  common semantic-record summaries, hash/size/link diagnostics, graceful corrupt
  input errors, and golden/corruption tests. Treat VM/initializer/debug opaque
  payloads as hash/codec/size metadata unless an explicit matching decoder exists.

## V3. Direct source candidates and exact warm restore

- [x] V3.1 Define and test `DirectSourceInputs` and its canonical digest from raw source,
  logical coordinates, stable provider/hook versions, explicit options and profile.
- [x] V3.2 Persist bounded include/generated/preprocess dependency candidates and
  validate them without rerunning the preprocessor before lookup.
- [x] V3.3 Implement production SourceIndex discovery, additions/deletions/path
  collision handling and per-module ineligible-scope planning.
- [x] V3.4 Restore the complete admitted module set in a fresh test engine, rebuild
  current numeric FunctionIds/stable routes and atomically activate one batch.
  Prepare all staging modules before one ClassGenerator/SwapIn/route commit; an
  injected late-module preparation failure must discard the full batch and report
  zero restored modules.
- [x] V3.5 Connect that coordinator to production `InitialCompile()` and prove the
  unchanged second launch has exactly zero preprocess, parse and function-compiler
  calls, executes every restored module, publishes one combined route snapshot and
  does not publish a redundant Store generation. Changed, partial and injected-
  failure candidates must miss before activation or fully roll back, then complete
  through the authoritative normal compiler.
- [x] V3.6 Close IC-448/IC-449 with atomic same-module base/derived class-graph
  capture and fresh-engine restore. Preserve exact function owners across local/
  inherited method and VFT slots, reconstruct both reflected UClasses base-first,
  execute the restored derived-to-base call, and make hard callable compilation
  publish both Signature and FunctionContent dependencies. Retain exact type,
  slot, function-key and relocation diagnostics for rejected graphs.
- [x] V3.7 Close IC-451/IC-452 with two-phase same-module class-property restore.
  Represent cross-referencing object properties by stable TypeKey/declaration ABI,
  keep their storage on the profile-owned handle-slot constants rather than target
  object size/layout, restore every type skeleton before any property, and prove
  bidirectional reflected property links plus restored UFUNCTION execution in a
  fresh Engine. Preserve inline-value ValueLayout dependency semantics.
- [x] V3.8 Close IC-453 with position-independent inherited-method matching and
  immutable VFT declaration-family ownership across Base/Middle/Leaf overrides.
  Restore all three UClasses into a fresh Engine, compare method/VFT topology and
  execute reflected two-level virtual dispatch before retaining related graph and
  TypeSchema regressions.
- [x] V3.9 Close IC-454 by making preprocessed static-name expressions carry
  canonical text in addition to their same-Engine numeric fast-path hint. Prove
  arbitrary name literals and generated BlueprintEvent wrappers execute after
  fresh-Engine Cache V2 restore without copying or trusting a producer index.
- [x] V3.10 Close IC-455 by reconstructing a declaring reflected UFunction once
  on the correct restored UClass and proving normal Base/Middle/Leaf UClass lookup
  plus most-derived BlueprintEvent dispatch; never clone inherited UFunctions as
  a lookup workaround.
- [x] V3.11 Prove cross-class function parameter and return types survive a
  fresh-Engine restore without retaining producer type pointers. Compare the
  restored `asCScriptFunction` parameter/return data types and reflected
  `FProperty` classes against consumer-owned types, then execute the method.
- [x] V3.12 Reconstruct the admitted reflected UFUNCTION/UPROPERTY contract
  exactly, including supported function/property flags and metadata. Compare the
  producer descriptor/UField surface to the restored UField surface and execute
  the restored reflected function; unsupported fields must reject before mutation.
- [x] V3.13 Prove a late preparation failure for one module containing multiple
  cross-linked classes leaves no UClass, descriptor, VM type or stable route from
  that module active. A following authoritative clean compile of the same names
  must succeed without stale-state collisions.
- [x] V3.14 Prove stable type/function identity and canonical record identity do
  not depend on source declaration order. Compile semantically equivalent sibling
  classes in opposite declaration order, compare their stable identities and
  restored cross-links, while permitting only Engine-local numeric FunctionIds to
  differ.

## V4. Changed-module oracle and incremental publication

- [x] V4.1 Route changed source through the existing authoritative preprocessor,
  parser, HotReload dependency ownership and forced-clean module compile mode.
- [x] V4.2 Compare semantic RecordIds—not Pack bytes—to classify
  ModuleInterface/TypeSchema/ModuleState/FunctionBody/DebugSidecar changes.
- [x] V4.3 Reuse unchanged records/packs, write only new content and publish a new
  complete ModuleSnapshot/Manifest.
- [x] V4.4 Implement conservative deterministic dependent-module propagation from
  public interface and typed semantic dependencies; uncertainty is a safe miss.
- [x] V4.5 Prove body-only, signature, class/property/layout, global/initializer,
  include/options and debug-only mutations against the clean-compile oracle.
  Execute the production admission, coordinate and evidence contract in
  `v4.5-clean-oracle-mutation-matrix.md`; serialized fixture-only mutations do
  not close this task.

## V5. Per-function compiler reuse

- [x] V5.1 Add the Unreal-free kind-tagged builder invocation descriptor for every
  supported ordinary/generated/factory/public-single/lambda family with explicit
  `NotCacheable` coordinates. Modify the maintained AngelScript builder/compiler
  sources directly where necessary; an outer Runtime-only imitation is not an
  acceptable substitute.
- [x] V5.2 Produce `FunctionSourceDigest`, capture successful-miss actual
  dependencies and resolve current `FunctionInputDigest` only after authoritative
  declaration/type state exists.
- [x] V5.3 Implement the per-invocation `Restored/Miss/RejectedCorrupt/NotCacheable`
  hook and private full VM artifact validation/attachment before engine mutation.
  The maintained fork's bytecode/function/module/VM/restore internals are in
  scope, and the adapter must rebuild complete state rather than attach raw
  bytecode or preserve an obsolete numeric-ID dependency.
- [x] V5.4 Prove one isolated body edit invokes only the correct compiler closure and
  unchanged functions are real pre-compiler hits.
- [x] V5.5 Prove forced-clean and cached modes have equal semantic hashes, VM state
  and observable behavior across every supported invocation family and two engines.
- [x] V5.6 Close production compiler reuse: carry one graph-validated selected
  Generation past an exact-start miss into the authoritative `CompileModules`
  path; install per-module builder restore and compile-result callbacks only after
  the current declaration/type/state authorities required by
  `FunctionInputDigest` exist. Prove through real `InitialCompile()` behavior that
  unchanged functions are restored before their compiler closure, misses compile
  normally, the resulting complete module set publishes atomically, and typed
  hit/miss diagnostics are emitted. Direct callback/component tests alone do not
  close this task.

## V6. Lifecycle and StaticJIT isolation

- [x] V6.1 Implement one Cache service and mutation gate per engine plus one
  pointer-free successful-publication DTO boundary.
- [x] V6.2 Implement Editor initial compile/reload, PIE Current versus
  PendingColdStart, structural promotion/reinstancing and last-good active behavior.
- [x] V6.3 Implement bounded shutdown flush, settings, C++/Blueprint/console APIs,
  packaged reload policy and the complete `cache-v2-debuggability.md` contract:
  a minimal Engine-native C++ DTO/status/JSON producer, typed explain chains,
  bounded opt-in decision trace, and Python-first offline diff/verify/dependency
  analysis/correlation. Do not duplicate the same presentation logic in both
  languages.
- [x] V6.6 Close IC-446 by widening the shared diagnostic schema with a bounded
  stable module/declaration/type/function/dependency catalog, typed validation
  failure coordinates and the current pointer-free VM/Native route snapshot.
  Make Python correlate exact ModuleSnapshot RecordIds and live route identities
  against persisted FunctionBody records, render useful semantic text/JSON, and
  prove deterministic/no-FunctionId/read-only behavior with focused C++ and
  Python tests before real Editor/PIE/package evidence.
- [x] V6.4 Rebuild Engine-owned stable FunctionId maps and immutable Native/VM route
  snapshots after compile/restore.
- [x] V6.5 Prove the Cache-owned route-refresh isolation seam with injected
  sibling-Provider outcomes: absence/removal/content/profile/ABI mismatch and Live
  Coding failure affect only per-function routing while valid VM Cache remains.
  Provider ABI/catalog matching and the Live Coding state machine remain owned and
  finally proven by `refactor-as-static-jit-external-module`.

## V7. Cutover and final acceptance

- [x] V7.1 Prove legacy `PrecompiledScript.Cache`, DataGuid and persisted numeric/
  pointer relocation cannot satisfy Cache V2 while `Binds.Cache` remains accepted.
- [x] V7.2 Remove the legacy production reader/writer/generator/forced-exit path and
  package pre-generation after V2 parity; retain only the inventoried sibling
  StaticJIT transport bridge until its own cutover.
- [x] V7.3 Stage loose NonUFS source and add isolated Development/Shipping package-
  smoke helpers outside the normal `All` suite.
- [x] V7.4 Run complete Cache and affected HotReload/StaticJIT automation prefixes.
- [x] V7.5 Run real PIE cold/warm/body/structural/failure/promote scenarios.
- [x] V7.6 Run real Development and Shipping cold/warm/edit/invalid/restored/
  structural multi-launch matrices last.
- [x] V7.7 Benchmark cold/warm/mutations, serial/parallel, diagnostics disabled/
  summary/verbose overhead and 4/16/64 MiB Pack policy; use the Engine-native
  session JSON plus Python dump/diff against real generated stores, update Chinese
  then English guidance and archive the completed change.

## Historical task mapping

| Superseded group | Current destination |
|---|---|
| R/A accepted identity and archive baseline | V0 |
| B record codecs, TypeSchema, factory and graph | V1 |
| C Pack/Manifest plus D Store | V2 |
| E1–E2 source inventory/exact planning | V3 |
| E3–E5/E9 changed-module invalidation/state | V4 |
| E6–E8/E10 compiler hook and VM artifact reuse | V5 |
| F lifecycle/routing | V6 |
| G cutover/package/real acceptance | V7 |
