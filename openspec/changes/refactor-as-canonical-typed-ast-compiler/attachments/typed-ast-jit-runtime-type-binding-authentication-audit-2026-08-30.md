# TypedASTJIT Runtime type-binding authentication audit — 2026-08-30

## Outcome

This read-only audit confirms that the compiler's dynamic-TypeId architecture
is structurally correct but not yet consumed consistently by TypedASTJIT.

Canonical AST and detached relocations use complete stable type identity;
candidate installation resolves that identity through the immutable,
generation-local `asCRuntimeTypeBindingTable`; current numeric TypeId and live
type pointers remain generation-local execution coordinates. Snapshot,
executable and binding lifetimes are published together and old generations
retain their original type/layout mapping through leases.

TypedASTJIT still derives parts of its native ABI from live
`asCScriptFunction::parameterTypes`, `asCTypeInfo::name` and Canonical spelling
special cases such as `FString`/`FLinearColor`. It does not consume the frozen
Runtime type-binding table as an authentication gate. This is the highest
remaining TypeId/type-ABI completion blocker for Tasks 7.2/7.4.

## Current safe architecture

```text
Canonical complete stable type identity
    -> pointer-free detached relocation + expected ABI key
    -> candidate generation-local Runtime binding table
    -> exact profile/native-environment/layout/behaviour authentication
    -> candidate-local pointer/offset/slot/current numeric TypeId patching
    -> atomic executable + snapshot + bindings publication
```

The design prevents a numeric TypeId allocated by one Engine or generation
from becoming a durable semantic identity. Same-nominal Hot Reload revisions
may map to different layouts and numeric IDs without retargeting an old
generation.

## Current TypedASTJIT gap

The StaticJIT generation graph exposes only a weaker type view, and current
TypedASTJIT analysis/emission does not use that graph type collection to
authenticate every native ABI-relevant Canonical type. Instead, supported
paths may still consult live Runtime function/type objects or infer a native
shape from names.

Consequences:

- the backend does not prove that its type decision belongs to the same
  immutable generation as the Canonical snapshot and published dependencies;
- wrong profile, native environment, layout or behaviour rows cannot be
  tested as a deterministic per-function admission failure at this boundary;
- the dynamic-TypeId solution is implemented at the compiler transaction
  layer but incompletely enforced by this backend consumer.

No confirmed silent misbind was found in the currently supported scalar/enum
and reviewed native bridge/direct subset after CTA-S82 through CTA-S88. The
gap is an authentication/completion blocker, not evidence that every current
TypedASTJIT function is wrong.

## Existing fail-closed boundaries

Current code already selects typed per-function fallback for reviewed
unsupported families, including:

- receiver-bearing call shapes not yet modeled safely;
- imports and mutable globals;
- unsupported property/mixin/constructor/delegate paths;
- unsupported native object-frame lifetime/exception/suspend facts;
- unsupported cross-translation-unit direct calls.

Those boundaries reduce safety risk but do not complete the requested call,
lifetime and provider breadth. Tasks 7.2, 7.4 and 7.5 therefore remain open.

## Required next gate

Introduce a request/generation-owned immutable Runtime type view derived from
the exact `asCRuntimeTypeBindingTable`, not from live Engine discovery. Before
typed emission, every ABI-relevant type dependency must resolve exactly once
against:

- complete stable type identity;
- type kind and template arguments;
- target profile;
- native environment;
- layout/size/alignment key;
- behaviour/call ABI key;
- generation ownership.

Missing, duplicate, ambiguous, wrong-kind, wrong-profile, wrong-environment or
wrong-layout rows must choose one precise per-function fallback before any
TypedASTJIT body/provider record is emitted. The backend may copy a
pointer-free stable identity/ABI summary into its artifact, but must not retain
AST, protocol or Runtime table pointers after generation.

## Minimal deterministic TDD slice

Use a currently typed-emitted `const FString&` route as the positive baseline.
For otherwise identical generation requests, inject independently:

1. missing binding row;
2. duplicate/ambiguous binding row;
3. wrong target profile;
4. wrong native environment;
5. wrong layout/behaviour signature.

Expected result for every negative:

- only the affected function selects a stable typed fallback category;
- zero TypedASTJIT body is emitted for that function;
- VM/other functions remain available;
- no live Runtime type-name search repairs the missing/mismatched row;
- provider dependency output carries only the authenticated pointer-free
  stable identity and ABI expectation.

After that gate, add a production fallback matrix for each unsupported
call/lifetime family and resolve one remaining design decision: whether a
missing producer `FunctionContent`/`EnvironmentAbi` row must fail immediately
or may be derived from exact generation graph facts. Current derivation is not
known to cause a name/position misbind, so this is recorded as dependency
authority design work rather than the primary blocker.

## Non-claims

- No production code was changed by this audit.
- The generation-local Runtime type-binding table itself is not classified as
  defective.
- Current supported TypedASTJIT scalar/native paths are not broadly declared
  unsafe; the missing proof is immutable generation authentication.
- Tasks 7.2, 7.4 and 7.5 remain unchecked.
- Product default remains LEGACY.
- Standalone is excluded.

## CTA-S93 implementation follow-up — 2026-08-30

The focused production gate exposed an earlier producer failure before the
TypedASTJIT authentication negatives could become the expected consumer RED.
The managed fixture
`TypedRuntimeBindingManaged_65C28A(const FString&in)` produced no Runtime
signature-binding rows in the StaticJIT generation snapshot. The permanent
test diagnostic reported `filtered=0 total=0`, while also proving that the
module hash and owner stable-function key used by the test were correct.

Temporary trace instrumentation then established the exact boundary:

- Canonical Bytecode CodeGen appended the parameter-signature relocation for
  `FString` with `role=Parameter`, `formal=0` and the correct owner key;
- the prepared global artifact contained the relocation and completed its
  resolve phase;
- the StaticJIT snapshot still captured zero Runtime type-binding rows;
- no module adoption occurred on this source-compilation path.

The root cause is a production integration split. UE parallel source
compilation enters `asCBytecodeCodeGen::GeneratePreparedModule`; that path
committed TypeIds, globals and prepared bodies but did not allocate the
Canonical Runtime generation or adopt the resolved binding table. Detached
artifact `Commit()` and direct module-build tests did adopt the table, which is
why those paths did not reveal the omission.

Evidence:

- producer RED:
  `Saved/Tests/cta-s93-binding-row-diagnostic-red/20260830_173849_982_a4663bd4/Report/index.json`;
- traced producer RED:
  `Saved/Tests/cta-s93-binding-pipeline-trace-red/20260830_174232_514_0d6716c5/Report/index.json`;
- the trace-only logging was removed after diagnosis;
- the diagnostic build and the first prepared-path implementation build both
  passed through `Tools/RunBuild.ps1`.

The first implementation attempt allocated the generation after pending
TypeId commit and adopted the table after prepared globals were installed. It
closed the zero-row producer symptom far enough for the test body to finish,
but engine/test-fixture teardown then crashed in
`asCObjectType::ReleaseAllFunctions`, reached through
`asCModule::InternalReset` -> retired generation `Release()` -> AST lease
destruction. The process exited with code 3 before Automation could publish a
valid GREEN result.

Crash evidence:

- run:
  `Saved/Tests/cta-s93-prepared-binding-adoption-green-consumer-red/20260830_174556_788_6e343bd4`;
- snapshot:
  `Saved/Angelscript/CrashSnapshots/51284_20260830_174626_740/AngelscriptCrashSnapshot.json`;
- top ownership-sensitive frames:
  `asCObjectType::ReleaseAllFunctions`, `asCModule::InternalReset`,
  `asCModule::~asCModule`, `asCRuntimeTypeGeneration::Release`, and
  `asCASTSnapshot::~asCASTSnapshot`.

This is now classified as a candidate/active-module generation ownership and
retirement bug, not a missing relocation bug. The attempted wiring is not a
completed fix and must not be counted as GREEN or default-cutover evidence.
The next step is to reconcile the prepared candidate swap and retirement
protocol so executable bodies, snapshot leases and the immutable binding table
transfer ownership exactly once. Only after teardown is clean can CTA-S93
advance to the intended missing/duplicate/profile/environment/layout consumer
authentication RED and GREEN matrix.

## CTA-S93 ownership and authentication closure — 2026-08-30

The teardown diagnosis above has now been resolved. The missing ownership edge
was not a second candidate swap: `FAngelscriptEngine` retained its
`StaticJITGenerationSnapshot` until C++ member destruction, which occurs after
the destructor body had already called `asIScriptEngine::ShutDownAndRelease()`.
Once the snapshot's Canonical AST lease retained a real retired Runtime
generation, releasing that last lease after ScriptEngine destruction attempted
to clean the retired module's functions and types through a dead Engine.

`FAngelscriptEngine::Shutdown()` now resets the Engine-owned StaticJIT snapshot
before `ShutDownAndRelease()`. This releases Canonical AST and retired-generation
leases while their Engine is still valid. It does not extend any raw pointer
lifetime and it does not weaken generation retirement.

Evidence:

- ownership-fix build:
  `Saved/Build/cta-s93-shutdown-snapshot-lease-green-build/20260830_175219_555_816f7652/Build.log`;
- clean producer GREEN / consumer RED after the ownership fix:
  `Saved/Tests/cta-s93-shutdown-snapshot-lease-producer-green-consumer-red/20260830_175248_033_e871ec01/Report/index.json`;
- TypedASTJIT authentication implementation build:
  `Saved/Build/cta-s93-runtime-binding-auth-green-build/20260830_175815_986_00967489/Build.log`;
- first focused authentication GREEN:
  `Saved/Tests/cta-s93-runtime-binding-auth-green/20260830_175838_337_2439ef5a/Report/index.json`.

TypedASTJIT now derives the required return/formal/receiver coordinates from
the exact same-compilation sealed Canonical declaration. For every direct
closure member it requires exactly one binding row per non-primitive
coordinate and validates:

- module and Canonical owner function stable identity;
- role and source-formal ordinal;
- stable type identity, kind and complete qualifiers;
- target profile and native environment;
- complete expected/resolved layout and behaviour ABI equality;
- the exact generation-local `asITypeInfo*` already installed in the matching
  Runtime function return/formal/receiver slot.

The last check is pointer equality against an already-selected Runtime
signature slot, not type-name inference. The pointer is used synchronously
only. Successful output receives a deterministic, owned, pointer-free summary;
it retains no AST, table, ScriptEngine, `asITypeInfo*`, numeric TypeId or
generation pointer. A mismatch selects the stable per-root
`RuntimeTypeBindingMismatch` fallback before any affected body is emitted.

### Positive-path RED found after the first negative matrix

The first focused GREEN proved that all injected bad rows failed closed, but
it did not prove that an unmodified managed row could emit. Adding that
positive assertion produced a valid RED:

`Saved/Tests/cta-s93-positive-auth-diagnostic-red/20260830_180809_587_aab06599/Report/index.json`.

All stable and ABI facts matched (`canonical-coordinate=1`, `environment=1`,
`exact-abi=1`); only `same-generation=0` failed. The check had required the
native `FString` TypeInfo to occur in `Graph.Types`, but that graph enumerates
script types and intentionally does not classify every Engine-registered
native ABI dependency as a generated script type.

The fix authenticates `EngineLocalType` against the exact installed Runtime
function signature slot for the same Canonical owner/role/formal coordinate.
The focused test now proves all of the following in one fixture:

- a valid `const FString&in` row emits and publishes exactly one complete
  pointer-free summary;
- mutating the request-owned row after generation does not mutate output;
- the unrelated scalar function emits with no managed-type summary;
- missing, duplicate, wrong-profile, wrong-environment, wrong-layout,
  wrong-behaviour, wrong-kind, null-coordinate and a different same-Engine
  TypeInfo coordinate all fall back only the affected managed root.

Final focused evidence:

- build:
  `Saved/Build/cta-s93-runtime-signature-coordinate-green-build/20260830_181216_661_564ceb11/Build.log`;
- test:
  `Saved/Tests/cta-s93-final-focused-green/20260830_181728_808_c67fe3d0/Report/index.json`
  (`1/1 PASS`, clean teardown).

### Retained old/current imported generation RED

The subsequent Compiler + TypedASTJIT + NativeBridge regression exposed a
second generation-identity edge in the producer:

`PreparedImportedDependencyGenerationShadowsCoexistingPublishedType` failed
because signature ABI capture searched the Engine by the stable name
`PreparedDependency::Payload` while both the retained old type and the current
prepared dependency type were alive. The detached artifact's ordinary
transient-type list did not contain the imported provider type, so the search
reported an ambiguity even though the prepared Runtime function parameter
already carried the exact current type pointer.

Both signature relocation capture and final binding-table construction now
prefer that prepared Runtime return/formal/receiver coordinate. General
Engine-name discovery remains only for relocation families that do not have an
exact signature coordinate. The final binding still verifies the Canonical
stable key/kind/qualifiers and full ABI before publication.

Evidence:

- regression RED and later S94 process stop:
  `Saved/Tests/cta-s93-compiler-typedjit-nativebridge-regression/20260830_181343_835_593fde62/RunMetadata.json`;
- focused generation-shadow build:
  `Saved/Build/cta-s93-imported-generation-signature-green-build/20260830_181638_501_a53b8e79/Build.log`;
- focused generation-shadow GREEN:
  `Saved/Tests/cta-s93-imported-generation-signature-green/20260830_181652_128_bace836f/Report/index.json`
  (`1/1 PASS`).

The combined regression was not a full GREEN: after the imported-generation
failure, the same run later stopped during startup/default projection at
`FLinearColor::LucBlue` with an explicit-scope unresolved identifier. That is
the independently tracked CTA-S94 Runtime default-projection blocker. S93 is
focused GREEN, but broad-suite closure must be rerun after S94 is fixed.

### CTA-S95 combined rerun — one remaining reviewed-spelling consumer

After CTA-S94 and the generation-snapshot pre-shutdown lease repair, the
combined Compiler CanonicalAST + Generation Engine + TypedASTJIT + NativeBridge
matrix completed instead of crashing. Its result is **777/778 PASS** at:

```text
Saved/Tests/cta-s95-canonical-generation-typedjit-nativebridge-regression/
  20260830_183855_124_b0e2871c/Report/index.json
```

The sole failure is
`ReviewedRuntimePrintCallUsesResolvedCanonicalTarget`. Its exact diagnostic is:

```text
TypedASTJITProviderBodyUnsupported:
  Function=int InvokeReviewedRuntimePrint_65C28A(
    const FString&in, const float, const FLinearColor&in)
  Detail=Canonical call formal type has no reviewed C++ spelling:
    Formal=2 Type=FLinearColor
```

This is no longer a target-resolution or dynamic-TypeId ambiguity: the call
already carries its exact resolved Canonical target, and the generation-owned
Runtime signature binding is present. The remaining backend consumer still
asks its reviewed C++ spelling table/name special cases to classify a managed
formal before provider body emission. `FLinearColor` reaches that consumer
through Runtime `Print`'s defaulted third formal, which is now correctly
projected by CTA-S94.

The next bounded gate is therefore to derive/authenticate that formal's native
ABI spelling from the exact immutable Runtime type-binding summary (or reject
it with a deliberate reviewed unsupported category), not to add another
`FLinearColor` name branch. The existing test is retained as the RED. The
combined result is not a final cutover GREEN, but it proves the S94 default and
S95 lease-lifecycle paths across the larger matrix and reduces the current
matrix to one explicit type-spelling consumer.

### CTA-S96 correction and closure — direct target ABI belongs to the descriptor

The implementation review corrected one part of the preceding next-step
wording. The immutable Runtime type-binding summary authenticates the generated
root/helper function signature; it is not the authority for a nested direct
native target's public C++ callable spelling. That spelling was already part of
the reviewed native-call descriptor as `CppCallableSignature`.

CTA-S96 now parses that descriptor field into an exact pointer-free return and
formal list during native-call validation. Call closure carries the validation
result, the backend copies it into the direct emission plan, and the Canonical
emitter selects each formal through the sealed call-argument `formalIndex`.
There is no `FLinearColor` name special case and no Runtime TypeId/name recovery
in this direct-target path.

Malformed or injected callable strings fail closed before any direct body is
emitted. The first combined rerun closed the Runtime Print failure but exposed
one test that manually built an old-shape emission plan; production Backend
already carried the new fields. After updating that test contract, the final
combined matrix is **778/778 PASS**, zero failures and zero skips:

```text
Saved/Tests/cta-s96-reviewed-native-signature-final-regression/
  20260830_191242_555_6d5a2aed/Report/index.json
```

Full root-cause, RED/GREEN and fail-closed parser evidence is in
`attachments/cta-s96-reviewed-native-cpp-callable-signature-gate-2026-08-30.md`.

### CTA-S97 closure — frozen root/helper body ABI is the post-capture authority

CTA-S96 closed nested direct-target callable spelling, but a separate
root/helper consumer remained. TypedASTJIT root eligibility and provider-body
emission could still reconstruct a reviewed value-object spelling from the
live Runtime function TypeInfo after an exact EntryPlan had already frozen the
body ABI.

CTA-S97 adds a production poison-name gate around a real
`const FString&in` UFUNCTION. After EntryPlan capture, the exact Runtime
TypeInfo name is temporarily changed to `FStringDisplayPoison_65C28A`. The old
backend rejected the root with `UnsupportedSignature`; the corrected backend
emits the exact frozen `const FString&` body formal and never emits or consults
the poison spelling.

The implementation establishes one shared production function-shape builder.
It combines:

- the sealed Canonical formal relation;
- the exact immutable Runtime signature coordinates authenticated by CTA-S93;
- the authenticated EntryPlan return/formal C++ ABI and marshalling mode.

Root eligibility, direct-closure dependency analysis and final provider-body
emission reuse the same frozen value. The duplicate backend builder and the
unused provider-emitter live-name spelling helpers are removed.

The adjacent EntryPlan admission defect is also closed. Structural admission
now recomputes the complete existing V2 hash; changing `BodyCppType` or another
hashed field after finalization fails closed instead of passing merely because
the stored hash is nonzero.

Evidence:

- poison-name RED:
  `Saved/Tests/cta-s97-frozen-root-signature-red/20260830_193324_406_0768b149/Report/index.json`;
- hash-authentication RED:
  `Saved/Tests/cta-s97-entryplan-hash-red/20260830_193629_123_c28eabdb/Report/index.json`;
- focused GREENs: **1/1 + 1/1**;
- ProjectGeneration Engine: **40/40 PASS**;
- complete TypedASTJIT: **56/56 PASS**;
- final Compiler CanonicalAST + ProjectGeneration Engine + TypedASTJIT +
  NativeBridge matrix: **779/779 PASS**, zero failures/skips, at
  `Saved/Tests/cta-s97-frozen-signature-final-regression/20260830_195920_029_55f09360/Report/index.json`.

The complete record is
`attachments/cta-s97-frozen-root-helper-body-signature-gate-2026-08-30.md`.

This closes the known post-freeze root/helper C++ ABI name inference. It does
not remove the capture-time reviewed-value registry, and container names still
participate in unsupported-family classification rather than ABI spelling.
CTA-S98 subsequently closes the derived-funcdef source-formal qualifier
producer/consumer propagation that was the next bounded blocker at this
checkpoint. Remaining work is unsupported-family, production-entry and
default-cutover/final-verification breadth.

## Updated non-claims

- Product default remains LEGACY.
- The original AngelScript AST/Parser/Builder/Compiler remains available to
  the explicitly selected LEGACY/reference/rollback path.
- HIR remains physically absent and was not recreated as an adapter.
- No persisted or generated identity uses numeric TypeId or an Engine-local
  pointer.
- The CTA-S97 **779/779** combined matrix is valid regression evidence for the
  implemented slices, but is not the complete focused/All/default-cutover
  matrix required by Tasks 0.3, 10.9, 12.2, 12.4 and 13.12.
- Standalone remains outside this change's completion gate.
