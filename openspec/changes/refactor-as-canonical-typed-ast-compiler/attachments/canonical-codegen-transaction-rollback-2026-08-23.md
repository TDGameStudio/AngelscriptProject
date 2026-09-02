# Canonical CodeGen transaction rollback — types and imports (2026-08-23)

Worktree: `D:\as-cta`
Change: `refactor-as-canonical-typed-ast-compiler`

## Status

Implemented and focused-validated. This is a bounded repair to the current
canonical CodeGen transaction journal; it does **not** make CodeGen a wholly
detached artifact pipeline and does not authorize a default-pipeline switch.

## The two real failures

`asCBytecodeCodeGen::Generate()` exposes some declaration state before all
function bodies finish emitting. A source-level `fallthrough` reaches the
sealed AST and is currently rejected by the emitter with
`asCONTEXT_NOT_FINISHED`, so it is a useful genuine *post-install* failure
trigger: declarations before it have already been installed, while the module
must still remain exactly retry-safe.

### Provisional script object type

The fixture declares an empty `LeakedType`, successfully emits `First()`, then
fails in `Unsupported()` at `fallthrough`. Before the repair, `Abandon()`
dropped the artifact's `types` array but left the type in:

- `asCModule::classTypes` and `allLocalTypes`; and
- `asCScriptEngine::allRegisteredTypesByName`.

That produced a visible ghost type and made a same-module retry observe a
false duplicate declaration. The precise red evidence is
`Saved/Tests/cta-codegen-type-rollback-red/20260823_052542_620_c33b31d8`
(8/9; `ModuleClassTypes before=0 after=1`).

`asSBytecodeCodeGenArtifact::Abandon()` now removes the type from its module
collections and the engine name index, destroys its internals, clears the
owner, and releases it. The test then reparses the same class name in the
same module and successfully publishes `Retry()`; it must own a fresh
`LeakedType`. The initial focused evidence was
`Saved/Tests/cta-codegen-type-rollback-retry/20260823_053100_710_91a6c9ef`
(9/9).

### Imported declaration slot

Imports had a separate gap. `DECL_IMPORT` calls `AddImportedFunction()` before
body emission, directly creating both a module `bindInformations` entry and
an engine `importedFunctions` slot. The original artifact did not retain that
owner record, so the same later `fallthrough` failure leaked one import from
both views.

The regression test now snapshots all of the following before `Generate()`
and compares them immediately after the failure:

- `asCModule::GetImportedFunctionCount()`;
- `asCScriptEngine::importedFunctions` length and occupied count; and
- `freeImportedFunctionIdxs` length.

The red test was
`Saved/Tests/cta-codegen-import-rollback-red/20260823_054150_360_21af2dd9`
(9/10). It reported exactly one leaked module import, one engine import slot,
and one occupied engine import entry.

The artifact now owns the successful `sBindInfo*` records in an `imports`
array. On `Abandon()` it removes each record from the module before releasing
the imported signature; the signature destructor removes its matching engine
slot, and the record is then deleted. `Commit()` clears the journal only after
ownership has transferred to the module. The retry fixture parses the same
import declaration and requires exactly one fresh slot, not the failed
attempt plus a second copy.

### Class method / constructor / destructor association timing

The type and import tests exposed a related ownership ordering problem during
source review. `FillFunctionSignature()` used to append a generated method ID
or overwrite constructor/destructor behaviour IDs as soon as the signature was
known. A later body-emitter failure then removed those functions from
`engine->scriptFunctions` before the provisional type was destroyed.
`asCObjectType::ReleaseAllFunctions()` indexes those IDs during teardown, so
the old ordering could read a removed slot. A normal Debug run happened not to
fail because `asCArray` retains allocation capacity after shrinking; that is
not a bounds or lifetime guarantee.

The association is now delayed to `asSBytecodeCodeGenArtifact::Commit()`:

```text
signature: bind function -> object type only (needed by body emission)
emit all bodies
commit: add references, then install method/constructor/destructor identity
```

The transaction fixture covers a class with one successfully emitted method
followed by the source-level `fallthrough` rejection and asserts complete
module/engine-table restoration plus removal of the provisional type. Its
pre-change observation was a test pass rather than a trustworthy green for
the former ordering; the source-level bounds/lifetime analysis is the reason
for the ordering repair.

### Duplicate script class declarations

`RegisterCanonicalScriptTypes()` previously treated every existing type name
as a reason to `continue`. Two same-name script class declarations in one
sealed AST therefore returned success and silently omitted the second source
declaration. The direct AST fixture was a true red:
`Saved/Tests/cta-codegen-duplicate-class-red/20260823_060217_636_332231ab`
(0/1; `Generate()` returned success instead of `asINVALID_DECLARATION`).

The final rule is ownership-aware:

- an existing type owned by any script module is a duplicate/redeclaration
  that CodeGen cannot merge safely, so it fails with `asINVALID_DECLARATION`;
- an existing type with no owning script module is a native registration.
  Sema may expose it as a class-shaped declaration so CodeGen can consume its
  already-registered constructors/behaviours, and this bridge remains valid.

The rollback assertion confirms the first temporary script type is removed
when the second name causes rejection. The existing native value-object
construct/member/cleanup fixture stays in the complete CodeGen prefix, so the
native bridge is verified rather than assumed.

Focused green evidence:

- Build: `Saved/Build/build/20260823_054311_971_e2253481` — succeeded.
- Transaction prefix:
  `Saved/Tests/cta-codegen-import-rollback-green/20260823_054352_382_035da053`
  — **10/10 PASS**.
- Whole Canonical CodeGen prefix:
  `Saved/Tests/cta-codegen-regression-import-rollback/20260823_054436_429_21e4cd2f`
  — **35/35 PASS**.
- CanonicalAST parent prefix:
  `Saved/Tests/cta-canonical-ast-regression-import-rollback/20260823_054711_095_15b8a3e5`
  — **94/94 PASS**.
- CodeGen after deferred type association:
  `Saved/Tests/cta-codegen-deferred-type-association/20260823_055555_365_9a8576bf`
  — **36/36 PASS**.
- CodeGen after duplicate-script-type coverage:
  `Saved/Tests/cta-codegen-duplicate-class-final/20260823_060604_313_181bd811`
  — **37/37 PASS**.
- CanonicalAST after duplicate-script-type coverage:
  `Saved/Tests/cta-canonical-ast-duplicate-class-final/20260823_060710_261_8a9a1fba`
  — **96/96 PASS**.
- CanonicalAST after deferred type association:
  `Saved/Tests/cta-canonical-ast-deferred-type-association/20260823_055642_702_4a813dfc`
  — **95/95 PASS**.
- Standalone Debug CMake/CTest:
  `Saved/StandaloneTests/Standalone_01_Standalone/20260823_054814_766_c7067cff`
  — **21/21 PASS**.
- Standalone Debug CMake/CTest after deferred type association:
  `Saved/StandaloneTests/Standalone_01_Standalone/20260823_055758_893_a1d00175`
  — **21/21 PASS**.
- Standalone Debug CMake/CTest after duplicate-script-type coverage:
  `Saved/StandaloneTests/Standalone_01_Standalone/20260823_060806_140_7d6af30e`
  — **21/21 PASS**.

## Error-code contract corrected in an existing test

One pre-existing CodeGen regression asserted `Generate() < 0`. That is not a
valid universal failure contract: publication verification can reject a sealed
AST using a positive `asAST_VERIFY_*` value (for example
`asAST_VERIFY_DANGLING_ID`). The test now requires `Generate() != 0` and
`CodeGen.Failed()`, while preserving its essential assertion that no partial
function is published. This distinguishes successful sealing from successful
publication and avoids misreporting a fail-closed verifier rejection as a
test failure.

## Exact scope and remaining work

This is a **compensating** transaction, not the final detached architecture.
Script object types currently have to be discoverable while function
signatures are constructed, and imported declarations currently have to
install a bindable slot before call emission. On later failure, the artifact
now reverses the relevant owner/index insertions.

The following release/cutover requirements remain open:

1. Audit every other pre-commit mutation (all declaration kinds, allocator
   state, behaviour tables, type/function dependency references, and error
   branches) and either journal it or make it detached.
2. Reject unsupported declaration graphs before mutation with complete,
   exact coverage; never silently omit a declaration.
3. Complete the publication verifier's grammar, CFG/transfer, cleanup, and
   stable-reference invariants.
4. Complete Cache V2's pointer-free exact body DTO and restore verification.
5. Remove remaining parser/Sema dependence on legacy `asCScriptNode` before
   considering the canonical path authoritative or changing the default from
   LEGACY.

Accordingly, this repair improves the integrity of the opt-in canonical path
but does not change the overall safe-default-switch readiness estimate by
itself.

## Follow-up — candidate function IDs stay detached through body emission

The initial compensating transaction still had one important pre-commit
mutation: every candidate script function called
`asCScriptEngine::AddScriptFunction()` as soon as its signature was known.
That made its numeric ID available for `CALL` emission, but wrote into
`engine->scriptFunctions` and consumed `freeScriptFunctionIds` before every
body had succeeded. `Abandon()` later removed the slots, so the direct
rollback tests often observed the old state; that is still an unnecessary
"publish, then erase" dependency rather than an artifact boundary.

The artifact now mirrors the engine's deterministic LIFO ID allocation
without mutating it:

```text
candidate function order
    -> asSBytecodeCodeGenArtifact::GetNextPendingScriptFunctionId()
    -> sealed CALL IDs in candidate bytecode
    -> all body emission succeeds
    -> Commit(): add every candidate to engine->scriptFunctions
                 then attach module/type ownership
```

`asSBytecodeCodeGenArtifact::functions` now also owns the temporary initial
functions for mutable globals. They receive a candidate ID and are attached
to their `asCGlobalProperty`, but remain absent from the engine function
table until `Commit()`. Their ownership is deliberately two-stage:

1. the artifact retains the construction reference while emission is pending;
2. the property retains its normal init-function reference;
3. `Commit()` registers all candidate functions then releases the artifact
   reference for initializer-only entries; and
4. `Abandon()` removes global properties first, releasing the property
   reference, then destroys the artifact-owned initializer safely.

This ordering prevents an initializer from outliving a failed property
rollback, and it prevents body emission failure from having to repair a
published function-ID slot. `Commit()` distinguishes initializer-only entries
from callable declarations, so initializers are never added to module global
function lists or type method tables.

### Direct rollback regression

`IsolatedFailedGenerateLeavesNoCandidatePublication` was added to the
isolated CodeGen tests. It calls `asCBytecodeCodeGen::Generate()` directly —
not `asCModule::Build()` — with a mutable global followed by a source-level
`try/catch` body that CodeGen currently rejects. It snapshots and verifies:

- module callable functions, globals, imports, types, and publisher;
- engine script-function and free-ID table lengths; and
- engine global-property/free-ID table lengths plus the global address map.

The test deliberately does not let Build's later `InternalReset()` hide a
Generate ownership error. It passed both before and after the change because
the former compensating `Abandon()` restored this particular external shape;
the new implementation is justified by the inspected pre-commit publication
path and by removing that hidden intermediate visibility, not by claiming a
new black-box failure.

### Evidence after this follow-up

- Build:
  `Saved/Build/cta-artifact-function-deferral-build/20260823_124458_776_07bbba3b/RunMetadata.json`
  — succeeded.
- Direct isolated rollback:
  `Saved/Tests/cta-artifact-function-deferral-isolated/20260823_124515_669_977e9840/RunMetadata.json`
  — **1/1 PASS**.
- Exact mutable `uint64` initializer/reset lifecycle:
  `Saved/Tests/cta-artifact-function-deferral-u64-retry/20260823_124634_371_046ea30f/RunMetadata.json`
  — **1/1 PASS**.
- Complete production CodeGen prefix:
  `Saved/Tests/cta-artifact-function-deferral-production/20260823_124719_697_e4bd08bf/RunMetadata.json`
  — **59/59 PASS**.
- Existing direct CodeGen transaction matrix (unsealed, prior-function,
  global, import, type, retry, and success ownership paths):
  `Saved/Tests/cta-artifact-function-deferral-transaction/20260823_125012_982_148015c5/RunMetadata.json`
  — **12/12 PASS**.

### Remaining transaction limit

This moves **script-function slots and global initializer functions** behind
the commit boundary. It does **not** make the whole compiler output fully
detached: script object types must currently be discoverable to resolve
function signatures; and global properties supply stable storage addresses
during expression lowering. Those pre-commit mutations remain
journalled/compensated by `Abandon()` and need a later staged owner/index
architecture before 9.1 or 13.6 can truthfully be checked. The default
compiler pipeline remains `LEGACY`.

## Follow-up — imports join the candidate artifact

`CALLBND` encodes the imported-function ID in bytecode. It does not require a
live `engine->importedFunctions` entry while CodeGen emits the caller. The
former implementation nevertheless used `asCModule::AddImportedFunction()`
before body emission, mutating both `module->bindInformations` and the
engine's separate import-slot allocator.

Imports now use the same candidate pattern as script functions:

```text
sealed import declaration
  -> artifact mirrors freeImportedFunctionIdxs to choose FUNC_IMPORTED | slot
  -> detached asCScriptFunction(asFUNC_IMPORTED) + sBindInfo
  -> CALLBND uses the candidate ID while bodies emit
  -> Commit validates the complete slot plan, then installs module + engine
```

No import table is touched on a later emitter failure. `Abandon()` continues
to accept both old installed and new detached records, so its cleanup is
safe across the boundary. Commit validates all expected import slots before
its first insertion; under the engine build lock this should always hold, but
the check makes a violated allocator contract fail before a partial import
install.

Evidence after import deferral:

- Build:
  `Saved/Build/cta-artifact-import-deferral-build/20260823_125403_284_f78650b6/RunMetadata.json`
  — succeeded.
- Direct transaction matrix:
  `Saved/Tests/cta-artifact-import-deferral-transaction/20260823_125415_726_5311e54d/RunMetadata.json`
  — **12/12 PASS**, including `CodeGenEmitterFailureAfterImportLeavesNoImportSlots` and retry coverage.

This narrows the remaining pre-commit live state to script types and global
properties (including `varAddressMap`). It is not grounds to check 9.1/13.6
or change the default pipeline.

## Follow-up — global properties now join the candidate artifact

The remaining property path was not semantically required to be live during
expression lowering. A canonical `LDG` instruction embeds
`asCGlobalProperty::GetAddressOfValue()` directly. The engine's
`varAddressMap` is instead consulted later, when the completed function's
`AddReferences()` classifies bytecode pointers as global resources. That gives
the artifact a valid split between *stable candidate storage* and *published
owner/index lookup state*.

The CodeGen global-declaration loop now creates an unregistered
`asCGlobalProperty`, gives it an ID that mirrors the engine's LIFO
`freeGlobalPropertyIds` allocation without consuming it, allocates its value
storage, and records it in `artifact.globals`. Mutable integer initialization
functions can safely target that candidate address. Until every body emits,
none of the following change:

```text
engine->globalProperties
engine->freeGlobalPropertyIds
engine->varAddressMap
module->scriptGlobals
module->scriptGlobalsList
```

`Commit()` first verifies the whole prospective global slot plan, then verifies
the import plan, and only after both checks installs globals, their address-map
entries, imports, and script functions in that order. Installing globals ahead
of function `AddReferences()` preserves the normal bytecode resource tracking
contract. The Commit-side global installation deliberately mirrors the
publication half of `asCModule::AllocateGlobalProperty()`: the constructor
reference transfers to the engine table and the module takes its normal second
reference.

`Abandon()` now distinguishes an installed property from a detached candidate:
the former follows normal module/engine removal and allocator restoration; the
latter destroys its initializer reference and releases only the artifact-owned
property. A failed `Commit()` also now invokes `Abandon()` before returning, so
future fail-closed slot-plan validation cannot leak detached candidates.

### Evidence after global-property deferral

- Build:
  `Saved/Build/cta-artifact-global-deferral-build/20260823_130043_053_ef474728/RunMetadata.json`
  — succeeded.
- Direct `Generate()` failure without a subsequent `Build()` reset:
  `Saved/Tests/cta-artifact-global-deferral-isolated/20260823_130232_097_2ee84e3b/RunMetadata.json`
  — **1/1 PASS**. It proves the rejected mutable-global body restores global
  slots, free-ID count, and `varAddressMap` cardinality.
- Full transaction matrix:
  `Saved/Tests/cta-artifact-global-deferral-transaction/20260823_130055_633_c8277b6e/RunMetadata.json`
  — **12/12 PASS**.
- Complete production CodeGen prefix:
  `Saved/Tests/cta-artifact-global-deferral-production/20260823_130133_987_2a972e3e/RunMetadata.json`
  — **59/59 PASS**, including mutable global initialization, global reads, and
  execution after publication.

The direct rollback test was already an externally green test under the old
compensating cleanup, so it is retained as a regression guard rather than
claimed as a newly exposed black-box failure. The architectural improvement is
the removal of interim visibility and allocator mutation, verified by the
candidate path and commit ordering above.

### Remaining transaction limit

All current function, import, and global-property publication is now detached
through body emission. Script object types still enter module/engine lookup
structures before function signatures can be resolved, and module replacement
still resets the old state before a complete new Canonical artifact is known
good. General object/global initialization, funcdefs/closures, exception and
the rest of the language surface also remain outside the supported CodeGen
slice. Therefore this remains insufficient to check 9.1, 9.5, 10.4, or 13.6,
and it does not authorize changing the default pipeline.

## Follow-up — script types use an artifact-local resolution view

The last CodeGen-local publication was `RegisterCanonicalScriptTypes()`: it
inserted each `asCObjectType` into `engine->allRegisteredTypesByName`,
`module->classTypes`, and `module->allLocalTypes` so later function signatures
could resolve the type. That was an implementation convenience, not a runtime
necessity; it also meant a later body-emission failure temporarily exposed a
script type to unrelated lookup callers.

`asCRuntimeTypeBridge` now accepts an optional, read-only transient type array.
Canonical CodeGen creates the complete set of detached script object types
first, exposes that array only to the bridge for the lifetime of `Generate()`,
then performs field-layout resolution against that local set. A method or
constructor resolves its owning class through the same artifact. No public
engine/module type lookup table is modified during that work.

```text
canonical class declarations
  -> detached asCObjectType candidates (no module/engine insertion)
  -> artifact-local bridge resolves fields and function signatures
  -> emit all function/global/import candidates
  -> Commit validates type names and all allocator plans
  -> publish types -> globals/address map -> imports -> script functions
```

The two-phase type construction is important for source order independence:
all same-artifact types exist before any field type is resolved. Same-build
duplicate class names are rejected against the candidate set; existing native
types remain the prior bridge case and are not duplicated. On abandonment,
functions are destroyed before candidate types so method/object-type references
are released in the safe direction. Commit publishes types before
`AddReferences()` and object-function attachment, restoring ordinary runtime
lookup visibility precisely at the install boundary.

### Evidence after type deferral

- Build:
  `Saved/Build/cta-artifact-type-deferral-build/20260823_130825_188_692ba8a2/RunMetadata.json`
  — succeeded.
- Transaction suite:
  `Saved/Tests/cta-artifact-type-deferral-transaction/20260823_130842_667_7e8351ae/RunMetadata.json`
  — **12/12 PASS**, including class-method failure, duplicate class rejection,
  type rollback, and retry cases.
- Production CodeGen suite:
  `Saved/Tests/cta-artifact-type-deferral-production/20260823_130923_955_bf30a8fc/RunMetadata.json`
  — **59/59 PASS**, including script value-object construction, member access,
  generated accessors, constructors, and method ownership.

### Revised remaining transaction limit

For the currently implemented language slice, `asSBytecodeCodeGenArtifact`
now keeps functions (including global initializers), imports, globals,
`varAddressMap` entries, and script object types detached until Commit. The
former module-level breach (old `asCModule::Build()` calling `InternalReset()`
before the replacement generation was known good) is superseded by the private
candidate-owner promotion protocol in
`canonical-module-candidate-replacement-design-2026-08-23.md`. A failed
canonical rebuild now restores the prior module generation; a successful one
promotes the candidate into the existing public module object.

This does **not** close the broader transaction/cutover gates. Funcdefs and
other declaration forms remain unsupported or unproven, and the compiler
surface still lacks general object/global initialization, closures, exceptions,
and the full language semantics. These limits continue to block 9.1, 9.5,
10.4, and 13.6 and prohibit a default-pipeline change.

## Follow-up — automatic imports have a function-only safe bridge

The legacy automatic-import lookup tables contain two materially different
things:

- `allScriptGlobalFunctions` contains a stable `asCScriptFunction` whose
  owning provider module remains responsible for the code and reference
  lifecycle. A consumer can safely bind an exact function call to that existing
  function.
- `allScriptGlobalVariables` exposes a raw address that is also encoded into
  consumer bytecode. It has no owner/reference relation from the consumer back
  to the provider property today.

Canonical Sema now projects only **explicitly qualified**, exact-signature
script functions from an automatic-import provider into the consumer AST. The
projection has a dedicated origin marker; CodeGen recognizes only that marker,
rechecks the namespace and full function signature against
`allScriptGlobalFunctions`, and binds the call to the existing provider
function. It neither allocates a new script-function slot nor treats an
unqualified/root name as a global import.

Direct references to another module's mutable global deliberately remain
rejected. An exploratory implementation that lowered such a reference passed
execution but crashed during engine teardown: after the provider property's
address had left `varAddressMap`, consumer function reference release
misclassified the stale address as a string constant. This is a real ownership
bug, not a test-only ordering issue. Supporting it requires a separate
provider-global lifetime/lease route (including discard, reload, Cache V2
restore, and bytecode reference release); it must not be enabled by borrowing a
raw address from the legacy lookup map.

### Evidence — 2026-08-23

- Build:
  `Saved/Build/cta-canonical-automatic-imports-safety-assertion-build/20260823_140156_526_8b7f3c12/RunMetadata.json`
  — succeeded.
- Function bridge plus rejected mutable-global access:
  `Saved/Tests/cta-canonical-automatic-imports-safe-bridge-green2/20260823_140215_299_360675dc/RunMetadata.json`
  — **1/1 PASS**. The provider's namespaced function returns through the
  automatic-import consumer; the direct global consumer returns a canonical
  CodeGen error and does not fall back to `asCCompiler`.
- CodeGen transaction matrix after the bridge:
  `Saved/Tests/cta-canonical-codegen-transaction-full/20260823_140405_214_8e77fabe/RunMetadata.json`
  — **12/12 PASS**.
- Full production CodeGen group after the bridge:
  `Saved/Tests/cta-canonical-production-codegen-full-after-safe-import/20260823_140557_691_00c61819/RunMetadata.json`
  — **63/63 PASS**. This is regression evidence for the implemented subset,
  not evidence that the remaining language surface or Cache V2 lifecycle is
  complete.
- Full production CodeGen group after the Canonical failed-rebuild snapshot
  regression:
  `Saved/Tests/cta-canonical-production-codegen-full-snapshot-regression/20260823_141152_631_3f75ad61/RunMetadata.json`
  — **64/64 PASS**.
