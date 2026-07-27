# Runtime / Language Internal-Method Review Addendum

## Why this addendum exists

The first handoff reconciled `431` Runtime, Module, TypeSystem, and Embedding rows but omitted the cross-file call-site record:

`as_scriptengine.cpp | asCDataType | CreatePrimitive | 4928`

This addendum records that missing row and rechecks whether the prior `14` `ApiDeferred` rows are actually blocked or can be closed immediately in the test module. It does not modify the first handoff, the main reconciliation table, `tasks.md`, production source, or test source.

## Revised result

The addendum contains `15` terminal review records:

| Feasibility | Count | Meaning |
|---|---:|---|
| `ImmediateDirectTestGap` | 5 | The internal surface is already exported/public to the test module and a meaningful direct owner can be added without changing production code. |
| `ProductionPathUnwired` | 6 | The internal implementation has no current production caller because the fork's configuration-group API is stubbed. Testing isolated dead storage would not prove the public contract. |
| `CompileConfigurationUnreachable` | 1 | The implementation is excluded by this fork's unconditional build configuration. |
| `TestSeamRequired` | 1 | The production path is active, but the exact state needed for a core SDK oracle is private and unavailable to the raw SDK fixture. |
| `ProductionPathBroken` | 2 | The relevant delegate path is retained but already documented as unsafe; a positive ownership test must wait for the delegate implementation repair. |

No row qualifies as `NotApplicable`. In particular, the six configuration-group methods are not used by today's storage-only public API, but they describe retained intended functionality rather than unrelated code. They remain `ApiDeferred` with an implementation prerequisite instead of being silently dismissed.

## Missing `CreatePrimitive` record

`asCScriptEngine::GetDataTypeFromTypeId` maps primitive IDs through `asCDataType::CreatePrimitive` at `as_scriptengine.cpp:4928`. The two public consumers immediately below it are:

- `GetTypeDeclaration`, `as_scriptengine.cpp:4993-5000`
- `GetSizeOfPrimitiveType`, `as_scriptengine.cpp:5004-5009`

The existing `TYPE-DATATYPE-QUALIFIER-CARTESIAN` owner directly constructs `asCDataType` values. It does not call `asCScriptEngine::GetDataTypeFromTypeId`, so it cannot be used as source-traceable evidence for this particular script-engine call site.

This is an immediately implementable test gap:

- Product ID: `TYPE-ENGINE-PRIMITIVE-TYPEID-ROUNDTRIP`
- Target: `TypeSystem/AngelscriptNativePrimitiveTypeIdRoundTripTests.cpp`
- Direct entry: cast the raw test engine to `asCScriptEngine` and call `GetDataTypeFromTypeId`
- Public corroboration: `GetTypeDeclaration` and `GetSizeOfPrimitiveType`
- Case axes:
  - primitive ID: `void`, `bool`, all signed widths, all unsigned widths, `float32`, `float64`
  - observation: token, validity/kind, public declaration, public byte size
  - floating alias: assert against the current fork's `asCDataType::floatIsFloat64` mode
  - branch exclusion: object-mask and invalid IDs must not be treated as primitive IDs
- Exact oracle: an independent constant table supplies expected token, canonical declaration, and byte size for every primitive ID.

The generated/repeated case description should be printed through the existing native case support. This test does not need generated AngelScript source because the behavior is a C++ SDK type-ID conversion; inventing script text would not improve its oracle.

## Six configuration-group rows: implementation prerequisite, not test-only work

The current fork explicitly exposes only storage-only/no-op behavior:

- `BeginConfigGroup` returns `0` without creating or selecting a group at `as_scriptengine.cpp:5476-5479`.
- `EndConfigGroup` returns `0` at `5482-5485`.
- `RemoveConfigGroup` returns `0` without lookup, live-object checks, or removal at `5488-5491`.
- `FindConfigGroupForFunction`, `FindConfigGroupForGlobalVar`, `FindConfigGroupForTypeInfo`, and `FindConfigGroupForFuncDef` all return null at `5493-5511`.
- `asCConfigGroup::RemoveConfiguration` itself is empty at current source lines `117-119`.

Repository-wide call-site reconciliation also shows that `AddType`, `AddReferencesForFunc`, `HasLiveObjects`, and `RemoveConfiguration` have no production caller; `AddReferencesForType` and `RefConfigGroup` only call each other inside the same otherwise unreachable island.

Therefore these six rows remain `ApiDeferred`:

- `AddType`
- `RefConfigGroup`
- `AddReferencesForFunc`
- `AddReferencesForType`
- `HasLiveObjects`
- `RemoveConfiguration`

The prerequisite is concrete: implement active-group ownership in `BeginConfigGroup`/`EndConfigGroup`, route type/function/global registration into the active group, implement owner lookup, implement balanced foreign-group references, and route `RemoveConfigGroup` through live-object validation and `RemoveConfiguration`. Only then should the focused products in the CSV be enabled.

Directly testing the isolated arrays now would verify retained code, but it would not verify any current public SDK behavior. Such tests may be used while implementing the prerequisite, but must not be used to reclassify today's public contract as covered.

## Context rows

### `HandleAppException`: compile-configuration unreachable

`HandleAppException` is enclosed by `#ifndef AS_NO_EXCEPTIONS` at `as_context.cpp:5281-5299`. The fork then unconditionally defines `AS_NO_EXCEPTIONS` at `as_config.h:1176-1179`. Its implementation and catch-based callers are absent from the current binary.

It remains `ApiDeferred`. The prerequisite is a dedicated non-shipping test variant that can disable that unconditional define, followed by `RT-CTX-NATIVE-EXCEPTION-TRANSLATION` cases for no translator, global translator, object translator, translator that leaves the message unset, native global/method/constructor calls, and context reuse.

### `InvalidateReferencesToMemoryBlock`: active path, missing legal core seam

This method is active in editor builds because `AS_REFERENCE_DEBUGGING` equals `WITH_EDITOR`. It is called by the TArray, TMap, and TSet binding mutation paths, so it is neither dead nor `NotApplicable`.

The raw SDK fixture cannot populate `TrackedReferences` or invoke the method because both are private in `as_context.h:250-254`. The focused core test therefore needs a `WITH_ANGELSCRIPT_UNITTESTS` friend or accessor that does not change layout or the shipping API.

Planned product:

- Product ID: `DBG-REFERENCE-MEMORY-INVALIDATION`
- Target: `Runtime/Debug/AngelscriptNativeReferenceInvalidationTests.cpp`
- Exact oracle: only tracked slots whose pointee lies in `[Address, Address + Size)` become null.
- Case axes: tracked/untracked; before/lower/interior/last-byte/upper/after/null; zero/one/full size; zero/one/many tracked slots.

This remains `ApiDeferred` because adding that legal test seam is a production-header prerequisite. It should not be moved to the external add-on scope merely because container bindings are current callers; the algorithm itself is fork-native context debug behavior.

## Five immediately implementable direct owners

### Primitive type-ID conversion

Covered above by `TYPE-ENGINE-PRIMITIVE-TYPEID-ROUNDTRIP`.

### Object-type destruction and release

The three methods are public on the exported `asCObjectType` internal class, so no runtime seam is required:

- `DestroyInternal` → `TYPE-OBJECTTYPE-DESTRUCTION-OWNERSHIP`
- `ReleaseAllFunctions` → `TYPE-OBJECTTYPE-FUNCTION-RELEASE`
- `ReleaseAllProperties` → `TYPE-OBJECTTYPE-PROPERTY-RELEASE`

Target: `TypeSystem/AngelscriptNativeObjectTypeReleaseTests.cpp`.

The test must use a raw engine plus test-owned functions, types, properties, child funcdefs, and refcount sentinels. It must assert exact per-slot decrement and post-call clearing, including empty/populated state, ordinary/template/list-pattern/script-object kinds, zero/nonzero child external refs, and first/repeated invocation where the implementation promises inertness. The fixture must explicitly detach consumed state before normal engine teardown so the test does not introduce double releases.

Aggregate `DiscardModule` success is not an adequate oracle: it cannot distinguish which property/function ownership slot was released or whether an unrelated function was over-released.

### Script-function bytecode references

`asCScriptFunction::ReleaseReferences` is public on the internal class and can be exercised with a test-owned function:

- Product ID: `RT-SCRIPTFUNCTION-REFERENCE-RELEASE`
- Target: `Runtime/AngelscriptNativeScriptFunctionReferenceTests.cpp`
- Exact oracle: every bytecode-owned return, parameter, template, local-object, object-opcode, function-opcode, global-property, and string-constant reference loses exactly one retained reference; a no-bytecode function does not release bytecode-owned references.
- Case axes: bytecode absent/present; each reference category; zero/one/many; null/non-null config-group lookup.

The test must use minimal valid bytecode and neutralize consumed references before destructor teardown.

## Two delegate GC rows: blocked by the existing fork defect

`EnumReferences` and `ReleaseAllHandles` are registered GC behaviors, but this fork stores `funcdefType`, `objForDelegate`, and `funcForDelegate` as static `asCScriptFunction` state. The existing `ENG-OBJECT-SERVICE-DELEGATE-LIFECYCLE` owner already records missing delegate argument metadata, missing top-level execution support, cross-instance shared state, and access violations during positive execution and shutdown.

These rows remain `ApiDeferred` under `ProductionPathBroken`. The prerequisite is to move delegate state to each function instance, repair `MakeDelegate` metadata, and make valid execution and teardown safe. After that:

- `EnumReferences` must enumerate exactly the receiver owned by that delegate and never another delegate's receiver.
- `ReleaseAllHandles` must release exactly once, null only that instance's receiver, and be inert when repeated.
- Case axes must include null/non-null receiver, one/two delegates, independent receivers, first/repeated release, and teardown order.

Testing only the null-receiver branch now would be a shallow smoke test and must not be used to close either row.

## Execution implications

The implementation order represented by this addendum is:

1. Add all five pure test-layer owners together.
2. Build once and run their focused prefixes; fix the batch before broad execution.
3. Treat the configuration-group, exception-build, context-debug-seam, and delegate repairs as separate production changes with their own focused tests.

All new CQTests must follow the repository test guide and inline formatting rules, use scoped raw-engine ownership, matcher assertions, stable product/case IDs, and failure diagnostics. Generated AngelScript source is required only where the test genuinely generates script; when generated, it must be printed through `PrintGeneratedAsSource` before compilation.

No build or test execution was performed for this addendum.
