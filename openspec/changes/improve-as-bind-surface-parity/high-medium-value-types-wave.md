# High- and Medium-Priority Value-Type Binding Wave

## Scope decision

This is the approved implementation wave for the reviewed high- and
medium-priority UnrealCSharp families. It is broader than an audit and is not
limited to `FMatrix`.

| Cluster | Types | Script-facing outcome |
| --- | --- | --- |
| Asset Manager values | `FPrimaryAssetType`, `FPrimaryAssetId`, `FAssetBundleEntry`, `FAssetBundleData` | Scripts can construct and inspect primary-asset identifiers and assemble/query bundle descriptions using existing `FTopLevelAssetPath`. |
| Geometry values | `FBox2D`, `FMatrix` | Scripts can use an axis-aligned 2D box and the engine-default 4x4 matrix for common geometric operations. |
| Time values | `FFrameNumber`, `FFrameTime` | Scripts can represent whole/sub-frame time, convert/round it, and use its scalar arithmetic. |

`FPolyglotTextData` remains deferred. `TLazyObjectPtr` remains an intentional
non-goal unless a concrete compatibility consumer requires it.

## Engine and public-type decisions

### Use current engine public representations

The configured UE 5.8 engine defines `FMatrix` and `FBox2D` as its public,
double-backed LWC aliases. The new binding exposes the same concise script
names:

```angelscript
FMatrix Matrix;
FBox2D Bounds;
```

The initial wave MUST NOT add both `FMatrix44f` and `FMatrix44d`. A future
precision-specific need can add them deliberately; adding both now would
duplicate the default math vocabulary without an identified script consumer.

### Use top-level asset paths for bundles

Current `FAssetBundleEntry::AssetPaths` is
`TArray<FTopLevelAssetPath>`, not the older `FSoftObjectPath` array used by
the reference plugin. The AngelScript API MUST expose the current native form.
`FTopLevelAssetPath` and `FSoftObjectPath.GetAssetPath()` are already bound.

`FAssetBundleData.FindEntry` returns a native pointer into its owner. The
binding MUST NOT leak that pointer/reference to AngelScript. It will provide a
safe query form selected during implementation, such as `bool` plus copied
`out FAssetBundleEntry` or an index/value query.

### Extend Matrix through the supported engine surface

`FMatrix` is engine-reflected. Its explicit provider supplements it with the
common transform, origin/axis, determinant, inverse, frustum-plane, hash, and
conversion operations. UE 5.8 returns `FVector4` from both
`TransformPosition(FVector)` and `TransformVector(FVector)`; the script API
uses those exact return types. `EForceInit` is not script-visible, so
`FMatrix::Zero()` is the script-safe equivalent of the C# zero initialization
path; `FMatrix::Identity()` remains the identity factory.

### Range and interval registration boundary

All six range/interval types are already declared and receive their default
and copy constructors through `Bind_UStruct` reflection. `Bind_FRange.cpp`
therefore runs in `PostReflectionBindings` and only supplements their behavior:
bound-state factories, value/bound range construction, predicates, range
algebra, and interval arithmetic. It must not add duplicate default
constructors or `ValueClassForTarget` declarations.

## Provider and test layout

Every new provider uses direct-lambda `ExplicitBindings`, with its public API
table at the top of the `.cpp` containing the `FAngelscriptBind` definition.
Purpose text and non-obvious `@param` notes stay next to that registration.

| Family | Runtime provider | Focused CQTest |
| --- | --- | --- |
| Asset Manager values | `Binds/Bind_AssetBundleData.cpp`; existing `Binds/Bind_UAssetManager.cpp` | `AngelscriptTest/Bindings/AngelscriptAssetBundleDataBindingsTests.cpp` |
| `FBox2D` | `Binds/Bind_FBox2D.cpp` | `AngelscriptTest/Bindings/AngelscriptBox2DBindingsTests.cpp` |
| Frame values | `Binds/Bind_FFrameTime.cpp` | `AngelscriptTest/Bindings/AngelscriptFrameTimeBindingsTests.cpp` |
| `FMatrix` | `Binds/Bind_FMatrix.cpp` | `AngelscriptTest/Bindings/AngelscriptMatrixBindingsTests.cpp` |

Short native helpers remain with the provider. Split a functions file only
when it exceeds the current 100-line guideline.

## Test contract and delivery order

Each test uses `TEST_CLASS_WITH_FLAGS`, a local `ASTEST_AS` fixture, and an
observable script result. It tests public AngelScript syntax, never provider
names or source layout.

| Family | Required scenarios |
| --- | --- |
| Asset Manager | Primary-id construction/parsing/string round trip; bundle validity/equality; add, replace, reset, and safe entry/path query. |
| `FBox2D` | Construction, area/center/extent, expansion, containment, overlap/intersection, point distance. |
| Frame values | Whole/sub-frame construction, frame extraction, decimal conversion, floor/ceil/round, scalar arithmetic. |
| `FMatrix` | Identity/multiplication, position/vector transform, inverse round trip, transpose/equality, quaternion/rotator conversion. |

1. Verify exact current-engine declarations and existing registrations, then
   add the Asset Manager failing tests.
2. Implement/validate Asset Manager values, including safe `FindEntry`.
3. Implement/validate `FBox2D` and frame values as independent commits.
4. Add failing Matrix test, implement its bounded `FMatrix` surface, and
   validate separately.
5. Update this record, `reference-inventory.md`, and tasks with final script
   signatures, deferred members, test prefixes, build results, and the
   StaticJIT decision.

Run the narrowest `Tools\\RunTests.ps1 -TestPrefix` after each family, then
run `Tools\\RunBuild.ps1` after the whole wave (or earlier if dependencies
require it). Add StaticJIT coverage only if the changed declaration/operator
form demonstrates a JIT-specific risk.

## Implementation evidence (2026-08-09)

Implemented providers:

- `Bind_AssetBundleData.cpp`: registers non-reflected bundle values, safe
  `bool FindEntry(FName, FAssetBundleEntry&out)`, path mutation, and a
  `GetNumBundles()` query. `TArray<FAssetBundleEntry>` is intentionally not a
  public property because AngelScript rejects nested container properties.
- `Bind_FBox2D.cpp`: adds construction, equality, area/center/extent,
  expansion, intersection, and containment to the engine-reflected type.
- `Bind_FFrameTime.cpp`: adds whole/sub-frame construction, frame extraction,
  rounding, decimal conversion, and scalar multiplication.
- `Bind_FMatrix.cpp`: adds behavior to the engine-reflected `FMatrix` type;
  it does not re-declare the type or duplicate its reflection-owned default
  constructor. `FMatrix::Identity()` is a namespaced global helper.
- `Bind_FRange.cpp`: supplements the reflection-owned range, bound, and
  interval types in `PostReflectionBindings`; it deliberately leaves the
  default/copy constructors to reflection.
- `Bind_UAssetManager.cpp`: completes primary-asset identifier construction,
  parsing, and string value behavior; the previously incorrect placement
  constructor destination was corrected from `FPrimaryAssetType*` to
  `FPrimaryAssetId*`.

Focused validation:

```text
Tools\RunBuild.ps1 -Label value-type-parity-nested-container -TimeoutMs 900000
  -> succeeded

Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.ValueTypeParity"
  -Label value-type-parity-green-final -TimeoutMs 600000
  -> 4/4 passed
```

No StaticJIT-specific test was added. The wave only adds ordinary explicit
value constructors/methods and the focused compile-and-execute test exercised
the relevant public declaration paths without a JIT-specific incompatibility.

Additional focused validation after the range/matrix parity closure:

```text
Tools\RunBuild.ps1 -Label range-bindings-final-build -TimeoutMs 900000
  -> succeeded
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.Range"
  -Label range-bindings-final -TimeoutMs 600000
  -> 2/2 passed
Tools\RunBuild.ps1 -Label matrix-bindings-green-build -TimeoutMs 900000
  -> succeeded
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.Matrix"
  -Label matrix-bindings-green -TimeoutMs 600000
  -> 1/1 passed
```
