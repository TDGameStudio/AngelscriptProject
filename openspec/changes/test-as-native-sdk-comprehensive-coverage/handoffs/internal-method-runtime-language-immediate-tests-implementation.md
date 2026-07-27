# Immediate Internal-Method Test Owners

## Implemented scope

This implementation closes the five test-only gaps identified by `internal-method-runtime-language-review-addendum.md`. It adds three raw AngelScript SDK CQTest files and five catalog products without changing production code, `tasks.md`, `progress.md`, or the main internal-method reconciliation CSV.

| Internal method record | Product | Direct owner |
|---|---|---|
| `as_scriptengine.cpp:4928` → `asCDataType::CreatePrimitive` | `TYPE-ENGINE-PRIMITIVE-TYPEID-ROUNDTRIP` | `TypeSystem/AngelscriptNativePrimitiveTypeIdRoundTripTests.cpp\|FPrimitiveTypeIdRoundTripTests\|PrimitiveIdsPreserveTokenDeclarationAndSize` |
| `as_objecttype.cpp:82` → `asCObjectType::DestroyInternal` | `TYPE-OBJECTTYPE-DESTRUCTION-OWNERSHIP` | `TypeSystem/AngelscriptNativeObjectTypeReleaseTests.cpp\|FObjectTypeReleaseTests\|DestroyInternalClearsEmptyListAndOwnedState` |
| `as_objecttype.cpp:717` → `asCObjectType::ReleaseAllFunctions` | `TYPE-OBJECTTYPE-FUNCTION-RELEASE` | `TypeSystem/AngelscriptNativeObjectTypeReleaseTests.cpp\|FObjectTypeReleaseTests\|ReleaseAllFunctionsClearsEveryOwnedSlotFamily` |
| `as_objecttype.cpp:682` → `asCObjectType::ReleaseAllProperties` | `TYPE-OBJECTTYPE-PROPERTY-RELEASE` | `TypeSystem/AngelscriptNativeObjectTypeReleaseTests.cpp\|FObjectTypeReleaseTests\|ReleaseAllPropertiesBalancesOwnerAndPropertyKinds` |
| `as_scriptfunction.cpp:1286` → `asCScriptFunction::ReleaseReferences` | `RT-SCRIPTFUNCTION-REFERENCE-RELEASE` | `Runtime/AngelscriptNativeScriptFunctionReferenceTests.cpp\|FScriptFunctionReferenceTests\|SignatureAndLocalReferencesReleaseExactlyOnce` |

Each owner contains a receiver-qualified direct call to the exact internal method. The primitive owner also calls `asCDataType::CreatePrimitive` directly and compares it with `asCScriptEngine::GetDataTypeFromTypeId`, so the cross-file call-site record is not inferred only from a public declaration.

## Case depth

The five products add `28` stable case IDs:

- Primitive type-ID reconstruction: `12` built-in IDs — void, bool, four signed widths, four unsigned widths, float32, and float64.
- Object-type destruction: `3` shapes — empty, list-pattern detach, and an owned graph.
- Object-type function release: `5` slot families — factory, constructor, method, virtual, and garbage-collection behavior.
- Object-type property release: `4` owner/property combinations — application or script owner crossed with primitive or object property.
- Script-function reference release: `4` bytecode-owned categories — return type, parameter type, template subtype, and local object type.

No AngelScript source is constructed by these tests. They are deliberately pure C++ internal SDK owners, so the generated-source registry does not need a row and the tests do not emit invented script text.

## Oracle and cleanup rules

Every test method creates and destroys its own `FNativeTestEngine`.

The ObjectType tests use stack-owned `asFUNC_DUMMY` function sentinels and stack-owned type sentinels. They append only temporary engine function slots, preserve the original function-table length, null temporary entries before shrinking the table, and require exact before/after internal reference counts. The owning object clears its consumed arrays before normal stack teardown, while unrelated function sentinels must retain their baseline count.

The property owner uses `AddPropertyToClass` to establish the real ownership path, then requires object-property type counts to move from baseline `1` to retained `2` and back to `1`. It also requires `properties`, `localProperties`, and `propertyTable` lookup to be empty after release.

The script-function owner uses a minimal valid `RET` bytecode word to activate the bytecode-owned reference branch. `AddReferences` must move exactly one selected type from baseline `1` to `2`; `ReleaseReferences` must restore `1`. The fixture then clears the consumed bytecode and metadata arrays before the function destructor can revisit them.

All pointer assertions guard subsequent dereferences. No production test seam, mock production behavior, add-on registration, UE object, world, or plugin engine wrapper was added.

## Catalog and source ownership

`catalogs/coverage-products.psd1` contains one exact product owner for each new marker. The expanded cardinality for this batch is `28`.

The source files use:

- `WITH_ANGELSCRIPT_UNITTESTS` body gates;
- `TEST_CLASS_WITH_FLAGS` and scenario-specific `TEST_METHOD`;
- matcher assertions;
- case-owned raw engines;
- stable `FNativeCaseContext` IDs;
- explicit scope cleanup.

## Static verification

No build or automation test was run, as explicitly requested for this batch.

Static results:

- Catalog validation: `PASS`
  - Products: `318`
  - Expanded cases: `46,426`
  - Unique IDs: `46,426`
- Native SDK source reconciliation: `PASS`
  - Implemented products: `317`
  - Disabled implemented products: `1`
  - Incomplete products: `0`
  - Product-owned methods: `313`
  - Explicit non-product methods: `374`
  - Unresolved methods: `0`
- Native SDK boundary audit: `0` violations.
- Inline AngelScript formatting audit: `0` violations.

The first source-reconciliation attempt observed a concurrently added Compiler marker after its temporary catalog snapshot had already been copied. A retry from the synchronized catalog and source snapshot passed with zero unresolved products or methods; this was not a failure in the five products recorded here.

Build and focused execution remain required before any passing/runtime-complete claim. The recommended later order is one batch build, the three narrow Automation prefixes, then the full AngelScript SDK prefix.
