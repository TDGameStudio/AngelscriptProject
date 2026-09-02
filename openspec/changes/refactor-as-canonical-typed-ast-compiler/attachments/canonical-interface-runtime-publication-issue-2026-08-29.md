# Canonical interface Runtime publication issue — 2026-08-29

## Status

Open. Task 3 of the approved exact-interface publication plan has entered its
production RED stage. Sema-owned exact method relations, verifier admission and
Sidecar V8 transport are already green; detached Runtime interface shells and
dispatch projection are not yet implemented.

This issue is not evidence that the Canonical pipeline is ready to replace the
LEGACY default.

## Initial production RED

Test source:

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionInterfaceDispatchTests.cpp`

Test method:

- `CanonicalBuildPublishesDeclarationOnlyInterfaceMethods`

The test requires an interface-bearing source build selected as CANONICAL to:

1. succeed through detached `asCBytecodeCodeGen`;
2. publish an `asCObjectType` whose explicit interface identity is retained;
3. publish the exact declaration method as `asFUNC_INTERFACE`;
4. keep `scriptData == nullptr` for that declaration-only requirement;
5. bind the method to the exact Runtime interface shell; and
6. publish no legacy compiler invocation.

Authoring build:

- Command: `Tools\RunBuild.ps1 -Label cta-interface-task3-red-build -TimeoutMs 1800000 -NoXGE`
- Result: PASS.
- Evidence: `Saved/Build/cta-interface-task3-red-build/20260829_202155_058_25141063/`

Runtime RED:

- Command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.InterfaceDispatch" -Label cta-interface-task3-runtime-red -TimeoutMs 600000`
- Result: **0/1 PASS**, one expected failure.
- Evidence: `Saved/Tests/cta-interface-task3-runtime-red/20260829_202214_800_39cdc393/`
- Exact CodeGen diagnostic:
  `Canonical CodeGen failed code=-7 line=12321: unsupported declaration kind Interface (id=2 name=ICanonicalProbe)`.

The RED therefore fails at the detached CodeGen admission boundary before a
Runtime type shell can be constructed. It does not fail because of VM
execution, interface-call lowering or a legacy fallback.

## Interface-shell GREEN

The smallest detached publication increment now accepts a Canonical Interface
declaration, creates its zero-sized Runtime shell, and publishes its bodyless
method as `asFUNC_INTERFACE` with `scriptData == nullptr` and the exact
interface `objectType`.

- Build command:
  `Tools\RunBuild.ps1 -Label cta-interface-shell-green-build -TimeoutMs 1800000 -NoXGE`
- Build result: PASS.
- Build evidence:
  `Saved/Build/cta-interface-shell-green-build/20260829_202410_270_3ebc60b8/`
- Test command:
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.InterfaceDispatch" -Label cta-interface-shell-green -TimeoutMs 600000`
- Test result: **1/1 PASS**, zero failures/skips.
- Test evidence:
  `Saved/Tests/cta-interface-shell-green/20260829_202421_910_ccd16063/`

This GREEN closes only the declaration-only interface shell increment. It does
not yet install a class interface closure, chunk offsets or dispatch entries.

## Dispatch RED isolation

The first compound dispatch fixture used inherited same-name overloads
(`Probe(int)` and `Probe(bool)`). It failed before Runtime projection with an
`unresolved-callee` Canonical Sema diagnostic:

- Result: **1/2 PASS**, one expected failure.
- Evidence:
  `Saved/Tests/cta-interface-dispatch-red/20260829_202552_018_302cfb56/`

Systematic tracing found that the current Sema name lookup visits base scopes
only when the direct scope does not already own that name. The derived
interface's `Probe(bool)` therefore hides the base interface's `Probe(int)` for
this call lookup. That is a separate inherited-overload semantic gate and must
not be mistaken for a Runtime dispatch-table failure.

The Runtime projection fixture was consequently isolated with distinct method
names, `ProbeBase(int)` and `ProbeDerived(bool)`, while preserving interface
inheritance and inherited class implementation. The isolated fixture now:

1. passes Canonical parsing, Sema relation sealing and detached CodeGen;
2. publishes both Runtime interface shells and their declaration methods; and
3. fails at the first exact Runtime class-graph assertion because
   `DerivedProbe::interfaces` does not contain the directly implemented
   `IDerivedProbe`.

- Authoring build: PASS.
- Build evidence:
  `Saved/Build/cta-interface-dispatch-isolated-red-build/20260829_202718_087_1e09142b/`
- Runtime result: **1/2 PASS**, one expected failure.
- Runtime evidence:
  `Saved/Tests/cta-interface-dispatch-isolated-red/20260829_202733_119_bd39d273/`
- Exact failed assertion:
  `the class must publish the exact directly implemented interface`.

This is the authoritative current Task 3 RED. The next implementation step is
the generation-local exact object/DeclId projection plus class interface
closure, offsets and dispatch chunks. The inherited same-name overload case
remains a separately recorded semantic requirement and will re-enter the gate
before the overload test can be declared GREEN.

## Confirmed implementation gaps

### Detached declaration/type admission

`CanonicalDeclIsSupportedForCodeGen()` does not accept
`asAST_DECL_INTERFACE`. `RegisterCanonicalScriptTypes()` creates only class
shells and currently has no exact Canonical declaration-to-Runtime object map
for interface owners.

### Declaration-only functions

The current detached function loop skips bodyless methods and constructs new
functions as `asFUNC_SCRIPT`. An interface requirement instead needs an
Engine-visible, module-owned `asFUNC_INTERFACE` shell with no `ScriptFunctionData`
and no bytecode-emission work item.

### Exact dispatch relations are not consumed

The authenticated `asCDecl::methodRelations` array currently has no consumer in
`as_bytecode_codegen.cpp`. Ordinary class inheritance is still finalized by
Runtime name/signature rematching, and detached CodeGen has no interface closure,
chunk or offset construction.

### Prepared Stage 1/2 is a separate ownership boundary

Prepared Stage 2 already owns type/function shells, method tables, ordinary
vtables and interface chunks. `GeneratePreparedModule()` replaces function
bodies transactionally; it cannot safely half-rewrite that Stage-2-owned graph.
Task 4 must therefore make Stage 2 consume the exact relation plan or make the
prepared CodeGen path fail closed after a read-only exact consistency check.
Fixing detached artifact `Commit()` alone is not sufficient.

## Approved repair boundary

The implementation will proceed in independently testable increments:

1. accept Canonical interface declarations and create detached interface type
   shells;
2. create declaration-only `asFUNC_INTERFACE` shells and exact DeclId binds;
3. build one generation-local, non-owning exact dispatch plan from sealed
   `methodRelations`;
4. validate the complete plan before any Engine/module visibility change;
5. mechanically install ordinary slots, interface closure, chunk offsets and
   entries during artifact Commit;
6. inject a post-preparation/pre-commit failure and prove `Abandon()` leaves no
   candidate entries while last-good publication remains executable; and
7. authenticate the separately owned prepared Stage 1/2 graph in Task 4.

No step may fall back to method name/signature matching for an authored
`BASE_OVERRIDE` or `INTERFACE_IMPLEMENTATION` relation.

## Ownership and identity hazards

- `methods`, behaviours and every vtable entry independently own function
  references. A single implementation appearing in multiple interface chunks
  therefore needs one reference per installed entry.
- `asCObjectType::interfaces` is currently a non-owning Runtime pointer list;
  the projection must not add an unpaired type reference.
- An interface requirement's `vfTableIdx` is its chunk-local ordinal. A class
  implementation's `vfTableIdx` is its ordinary class slot. These identities
  must not be conflated.
- A prepared-body rollback does not roll back Stage-2 method/vtable graph
  mutation.
- Projection records are generation-local and non-owning. They must not survive
  Generate/Commit and must never be serialized or exposed as Public AST facts.

The following remain prohibited durable identities:

- Runtime `FunctionId`;
- numeric `TypeId`;
- `vfTableIdx`;
- interface chunk offset;
- Runtime object/function pointer; and
- un-remapped snapshot-local DeclId outside its owning snapshot lease.

## Non-claims

- The native AngelScript Parser/Builder/Compiler and `asCScriptNode` remain
  available behind explicit LEGACY/reference/recovery/differential paths.
- HIR remains deleted and is not replaced by the dispatch plan.
- The product default remains LEGACY.
- Public AST V1 is unchanged.
- Standalone is deferred by explicit project scope and is not touched here.
- The initial RED covers declaration-only Runtime shells only; it does not yet
  prove interface VM execution, overload identity, inherited implementation,
  rollback or prepared-path authentication.

## Exact detached dispatch projection progress

The detached artifact now carries a generation-local, non-owning projection
from exact Canonical declaration identity to Runtime object/function shells.
The old post-hoc class finalizer that rematched methods by spelling and
signature has been removed from this path. Before publication, the new plan
constructs and validates:

- the exact declaration-method inventory;
- the base-class ordinary virtual slots and exact `BASE_OVERRIDE` replacements;
- the transitive interface closure;
- one chunk offset per published interface; and
- each interface chunk entry from its sealed `INTERFACE_IMPLEMENTATION` edge.

Installation occurs only after every candidate function owns an Engine
function slot. Method-table and virtual-table ownership are acquired once per
installed occurrence, including duplicate function pointers in multiple
interface chunks; `Abandon()` can therefore release the committed prefix with
the existing artifact rollback path.

Authoring build and the first isolated execution fixture are GREEN:

- Build: PASS at
  `Saved/Build/cta-interface-dispatch-plan-build/20260829_204032_775_3b71cf14/`.
- Focused Runtime gate: **2/2 PASS** at
  `Saved/Tests/cta-interface-dispatch-plan-green-attempt/20260829_204047_750_c64d40d5/`.
- The execution fixture proves interface inheritance, inherited class
  implementation, exact chunk entries and a real VM interface call returning
  `42`; it is not only a graph-shape assertion.

This closes the isolated detached projection increment, not Task 3 as a whole.
Atomic failure/last-good tests and broader interface-shape coverage remain
unverified.

## Atomic publication TDD RED

Four additional focused cases are authored for the remaining Task 3 surface:

1. a base-class method satisfying an interface introduced by a derived class;
2. two overloaded requirements resolved through their sealed exact edges;
3. failure immediately after dispatch-plan preparation with a byte-for-byte
   Engine/module publication snapshot comparison; and
4. a failed replacement generation retaining the last-good generation's
   digest, Runtime type identities and executable entry point.

The first authoring build intentionally fails only because the post-plan,
pre-commit failure seam does not exist yet:

- Build result: expected RED.
- Evidence:
  `Saved/Build/cta-interface-dispatch-task3-new-tests-red/20260829_204501_787_d817b5be/`.
- Missing test-only API:
  `SetTestFailureAfterInterfaceDispatchPreparation()` and
  `WasTestInterfaceDispatchPreparationFailureInjected()`.

No production compilation error was reported in this build. The next
increment is to add this test-only seam immediately after complete dispatch
plan validation and before relocations or `Commit()`, route it through
`Abandon()`, then execute all six interface-publication cases. Until that gate
is GREEN, aggregate-generation atomicity and last-good retention remain open.

## Compatibility risks found by the read-only ownership audit

Two legacy-shape differences need explicit resolution before Task 3 can be
called compatible even though current Runtime dispatch is internally coherent:

- Canonical interface closure collection is breadth-first, while legacy
  `AddInterfaceToClass` is depth-first preorder. Parallel
  `interfaces`/`interfaceVFTOffsets` arrays still execute correctly, but
  reflection, serialization, dumps or consumers that observe enumeration order
  can differ.
- Canonical inherited interface-method inventory currently de-duplicates by
  Runtime function pointer. Legacy `CompileInterfaces` de-duplicates inherited
  requirements by full signature. In a diamond where sibling interfaces
  declare identical signatures, Canonical may retain two inherited requirement
  entries where legacy retains one.

Required follow-up: add a sibling-identical-signature diamond fixture and
either preserve legacy full-signature de-duplication/order explicitly or record
and gate a deliberate new canonical ordering contract. Neither difference may
be hidden by a successful single-interface VM call.

## Detached publication atomicity GREEN

The test-only post-plan/pre-commit boundary is now implemented immediately
after `PrepareCanonicalObjectDispatchPlans()` succeeds and before the no-op
fast path, Runtime type relocation, or artifact `Commit()`. The injected path
sets one diagnostic-only observation bit, records
`injected-interface-dispatch-precommit`, calls `artifact.Abandon(engine)`,
discards candidate globals and returns the requested negative error. It does
not change the production success path or persist a new artifact field.

- Authoring build: PASS at
  `Saved/Build/cta-interface-dispatch-precommit-seam-green-build/20260829_204743_396_7654d9d0/`.
- Complete Task 3 focused gate: **6/6 PASS**, zero failures/skips, at
  `Saved/Tests/cta-interface-dispatch-task3-six-gate/20260829_204809_563_95377d7c/`.

The six retained cases now prove:

1. declaration-only interface shells and bodyless `asFUNC_INTERFACE` methods;
2. interface inheritance, exact closure/chunks and real VM dispatch;
3. a base-class implementation satisfying an interface introduced by the
   derived class;
4. overload requirements selecting their independently sealed exact edges;
5. a post-preparation failure preserving module inventories, raw Engine
   function/global-property slots and free lists, declared types, TypeId maps,
   TypeId sequence, publisher and digest; and
6. a rejected replacement generation retaining the prior digest, exact Runtime
   type pointers and executable `StableEntry()` result `42`, while publishing no
   replacement entry.

This closes the detached atomicity portion of Task 3. Exact legacy ordering,
diamond signature de-duplication and inherited-base-VFT layout remain the
current compatibility gate; Prepared Stage 1/2 ownership/authentication remains
Task 4.

## Exact-legacy interface layout RED

Three focused compatibility fixtures were added after the ownership audit:

- sibling interfaces declaring an identical complete method signature;
- two explicit class interfaces where the first owns a base interface; and
- a derived class adding an ordinary method after copying a base table that
  already contains an interface chunk.

The first run is the intended behavioral RED:

- Build: PASS at
  `Saved/Build/cta-interface-layout-compat-red-build/20260829_205003_912_38ef8103/`.
- Focused result: **7/9 PASS**, two failures, at
  `Saved/Tests/cta-interface-layout-compat-red/20260829_205019_997_a9345b60/`.
- `DerivedOrdinarySlotFollowsCopiedBaseInterfaceChunk` is GREEN and proves the
  current plan preserves the exact legacy shape
  `[base ordinary, copied base chunk, derived ordinary, fresh derived chunk]`.
- `ClassInterfaceClosurePreservesLegacyDepthFirstOrder` fails because the
  current queue produces `ILeaf, ISibling, IRoot` instead of legacy
  `ILeaf, IRoot, ISibling`.
- `SiblingIdenticalRequirementsUseLegacySignatureDeduplication` fails because
  the derived interface retains both distinct function pointers instead of the
  first complete signature.

The repair is deliberately limited to these proven compatibility facts:
depth-first/preorder explicit interface closure and a separate full-signature
de-duplication rule for inherited interface method inventory. Exact class
method identities and interface chunks remain independently preserved.

## Exact-legacy interface layout GREEN

The projection now expands each explicit interface depth-first/preorder in
source order, de-duplicates the resulting closure by exact Runtime interface
identity, and only then appends the base class's already ordered interfaces.
Interface method inventory uses a dedicated inherited merge that calls the
Runtime complete-signature equality predicate against own and previously
inherited methods. This does not merge the defining interfaces themselves or
their class dispatch chunks: sibling interfaces with an identical requirement
still receive independent exact chunks and both calls execute.

- Build: PASS at
  `Saved/Build/cta-interface-layout-compat-green-build/20260829_205136_691_9024385f/`.
- Focused result: **9/9 PASS**, zero failures/skips, at
  `Saved/Tests/cta-interface-layout-compat-green/20260829_205150_820_dae7dd11/`.

The compatibility gate now proves all three audited shapes: legacy DFS closure
order, sibling complete-signature method-inventory de-duplication with two live
dispatch chunks, and copied base interface chunks preceding a derived class's
new ordinary method and fresh interface chunk. The separate inherited
same-name overload lookup limitation remains a Canonical Sema issue; it is not
silently treated as a Runtime publication failure or closed by these tests.

## Broad regression and Prepared generated-closure issue

The first complete ProductionCodeGen regression after removing the detached
name/signature finalizer found three failures:

- Result: **129/132 PASS**, three failures, at
  `Saved/Tests/cta-interface-task3-production-regression/20260829_205256_009_522400e8/`.
- Failures:
  `PreparedGeneratedAccessorClosurePublishesCallableMethods`,
  `PreparedNativeNonPodGeneratedGetterSealsAndInvokesExactCopyConstructor`, and
  `PreparedNativeNonPodGeneratedSetterTransfersOwnedParameterAndInvokesExactAssignment`.

The common cause was not relation mismatch. The detached repair had made the
shared `AttachCanonicalObjectFunction(METHOD)` branch a no-op because the new
complete dispatch plan owns detached method installation. Prepared generation
also calls that helper for Sema-generated accessor closure functions that have
no Stage-2 shell. Those new functions therefore acquired bodies and module
entries but never entered the already prepared owner's `methods`/`methodTable`.

The repair makes ownership explicit at the two call sites:

- detached Commit passes `attachPreparedMethod=false` and installs all methods,
  bases, slots and chunks only through the validated exact plan; and
- Prepared generated closure passes `attachPreparedMethod=true` and appends
  only the newly generated method into the Stage-2-owned graph.

No authored Prepared method graph is rebuilt or name/signature rematched by
this compatibility branch.

- Repair build: PASS at
  `Saved/Build/cta-interface-prepared-generated-closure-fix-build/20260829_205415_245_92295415/`.
- Full ProductionCodeGen regression: **132/132 PASS**, zero failures/skips, at
  `Saved/Tests/cta-interface-task3-production-regression-green/20260829_205427_420_54369b5e/`.
- Final audit-strengthened interface gate: **9/9 PASS** at
  `Saved/Tests/cta-interface-task3-audit-complete/20260829_205547_025_5253d89f/`;
  its build passes at
  `Saved/Build/cta-interface-task3-audit-complete-build/20260829_205530_284_c0ea4a5b/`.
- CodeGen transaction/rollback regression: **20/20 PASS** at
  `Saved/Tests/cta-interface-task3-transaction-regression/20260829_205620_668_caa68adf/`.

The strengthened interface fixtures additionally lock the base-class interface
tail after current-class DFS closure, all-zero shared offsets for empty chunks,
the empty derived-interface chunk followed by two sibling chunks, and the base
table before derived copying. Task 3's detached publication, exact legacy
layout, failure atomicity and broad regression gate are now complete. Task 4's
read-only authentication of an already prepared interface graph remains a
separate boundary and is not claimed here.

The final focused rerun also asserts that the authored interface-typed call
contains `asBC_CALLINTF`, that interface-own `vfTableIdx` is the authored
chunk-local ordinal, that the publisher is Canonical CodeGen and that the
legacy compiler invocation count is zero:

- Final build: PASS at
  `Saved/Build/cta-interface-task3-final-build/20260829_205758_579_7eda0f07/`.
- Final focused gate: **9/9 PASS**, zero failures/skips, at
  `Saved/Tests/cta-interface-task3-final/20260829_205818_326_35a23506/`.
- Plugin implementation commit:
  `0fb646b [CanonicalAST] Refactor: publish exact interface dispatch candidates`.
