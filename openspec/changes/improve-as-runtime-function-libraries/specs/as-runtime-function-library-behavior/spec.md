## ADDED Requirements

### Requirement: WrapIndex implements safe half-open wrapping

The signed and unsigned `Math::WrapIndex` overloads SHALL return a value in `[Min, Max)` after swapping reversed bounds, SHALL return the bound when both bounds are equal, and SHALL avoid intermediate signed overflow or unsigned underflow for every value in their declared integer domain.

#### Scenario: Values wrap across either boundary

- **WHEN** a value lies below Min or at/above Max for a non-empty range
- **THEN** `WrapIndex` SHALL return the congruent value inside the half-open range

#### Scenario: Reversed and equal bounds are deterministic

- **WHEN** Min is greater than Max or both bounds are equal
- **THEN** reversed bounds SHALL be swapped before wrapping and equal bounds SHALL return that bound

#### Scenario: Integer extremes remain defined

- **WHEN** signed or unsigned inputs include their type's minimum or maximum values
- **THEN** wrapping SHALL produce the mathematically expected in-range value without overflow-dependent behavior

### Requirement: Arbitrary-up vector helpers use the supplied plane

`FVector` and `FVector3f` arbitrary-up Size2D, SizeSquared2D, Dist2D, and DistSquared2D helpers SHALL project onto the plane described by UpDirection and then use the full projected vector magnitude or distance.

#### Scenario: Non-Z up direction preserves in-plane components

- **WHEN** UpDirection is X, Y, or a normalized non-axis vector
- **THEN** the float and double vector helpers SHALL match a native `VectorPlaneProject` followed by full Size or DistSquared calculation

#### Scenario: Distance and squared distance agree

- **WHEN** Dist2D and DistSquared2D are evaluated for the same finite projected vectors
- **THEN** Dist2D squared SHALL equal DistSquared2D within the type-appropriate tolerance

### Requirement: Angular distance is finite at numeric boundaries

Vector AngularDistance helpers SHALL clamp the cosine input to `[-1, 1]`; a zero-length operand SHALL return zero; and finite non-zero inputs SHALL return a finite angle in `[0, PI]`.

#### Scenario: Canonical directions return canonical angles

- **WHEN** inputs are parallel, orthogonal, or opposite non-zero vectors
- **THEN** AngularDistance SHALL return approximately `0`, `PI/2`, or `PI` respectively

#### Scenario: Zero vector does not produce NaN

- **WHEN** either operand has zero length
- **THEN** AngularDistance SHALL return zero

#### Scenario: Normal rounding is clamped

- **WHEN** normalized or assumed-normal inputs produce a dot value just outside the mathematical range because of floating-point error
- **THEN** AngularDistance and AngularDistanceForNormals SHALL return a finite endpoint angle rather than NaN

### Requirement: Runtime curve helpers mutate the effective curve

`FRuntimeFloatCurve::AddDefaultKey` SHALL modify the curve returned by `GetRichCurve()`. `UCurveFloat` mutation helpers SHALL reject null targets safely, preserve key validity, participate in editor modification/dirty semantics when available, and notify the curve owner after a successful mutation.

#### Scenario: Embedded runtime curve receives a key

- **WHEN** a RuntimeFloatCurve has no ExternalCurve and AddDefaultKey is called
- **THEN** its EditorCurveData SHALL contain the new key and subsequent getters SHALL observe it

#### Scenario: External runtime curve receives a key

- **WHEN** a RuntimeFloatCurve references an ExternalCurve and AddDefaultKey is called
- **THEN** the external UCurveFloat SHALL contain the new key and the unused embedded data SHALL remain unchanged
- **AND** the external asset SHALL receive the same editor modification/dirty and curve-update notification semantics as a direct UCurveFloat mutation

#### Scenario: Smart-auto key is distinct

- **WHEN** AddSmartAutoCurveKey succeeds
- **THEN** the key SHALL use cubic interpolation and `RCTM_SmartAuto`, while AddAutoCurveKey SHALL continue to use `RCTM_Auto`

#### Scenario: Curve asset mutation is observable

- **WHEN** a transient UCurveFloat is mutated successfully in an editor automation process
- **THEN** the curve update observer SHALL be notified and normal UObject dirty/transaction semantics SHALL be applied

#### Scenario: Invalid curve input is safe

- **WHEN** a null UCurveFloat or invalid FCurveKeyHandle is supplied
- **THEN** the helper SHALL return its documented failure/no-op result without crashing or modifying another key

### Requirement: Engine-defined input mapping helpers expose their real signature

The `UPlayerInput` mixin SHALL expose parameterless `GetEngineDefinedActionMappings()` and `GetEngineDefinedAxisMappings()` methods that return the complete UE engine-defined arrays. The obsolete ActionName and AxisName parameters SHALL NOT remain as overloads or compatibility aliases.

#### Scenario: Script compiles the parameterless methods

- **WHEN** script calls either engine-defined mapping method on a UPlayerInput receiver without a name argument
- **THEN** compilation and dispatch SHALL succeed and the returned array SHALL match the corresponding UE static array

#### Scenario: Legacy ignored parameter is rejected

- **WHEN** script calls either method with the removed FName argument
- **THEN** compilation SHALL fail because no compatibility overload exists

### Requirement: Dead and misleading Runtime helpers are removed

Runtime FunctionLibraries SHALL NOT expose wrappers that have no supported AS path or duplicate a richer engine declaration while discarding behavior. Unique plugin-specific and quaternion overloads SHALL remain available, and Runtime-owned helpers for Runtime types MAY be compiled only under `WITH_EDITOR` when they forward real editor-only engine behavior.

#### Scenario: Bare AssetManager wrappers are absent

- **WHEN** the UAssetManager mixin surface is inspected
- **THEN** `GetPrimaryAssetTypeInfo`, `GetPrimaryAssetTypeInfoList`, and `GetPrimaryAssetRules` SHALL be absent unless a later change deliberately designs supported AS types and signatures for them

#### Scenario: LevelStreaming editor helper follows its native build boundary

- **WHEN** `UAngelscriptLevelStreamingLibrary::GetShouldBeVisibleInEditor` is inspected
- **THEN** the UFunction and any manual supplement SHALL exist only under `WITH_EDITOR`
- **AND** an editor build SHALL forward the real `ULevelStreaming::GetShouldBeVisibleInEditor` result
- **AND** a non-editor build SHALL expose no such AS method

#### Scenario: Component duplicate removal preserves richer behavior

- **WHEN** an exact component declaration is already supplied by the engine with sweep, hit-result, or teleport semantics
- **THEN** a simplified FunctionLibrary duplicate SHALL be removed
- **AND** unique quaternion or plugin-specific declarations SHALL remain

#### Scenario: Widget metadata names a real parameter

- **WHEN** `UAngelscriptWidgetMixinLibrary::GetRenderTransform` is inspected
- **THEN** it SHALL NOT declare a nonexistent WorldContext parameter

### Requirement: Script helper isolates VM-private state

The FunctionLibrary implementation for global-variable initialization queries SHALL consume a Runtime Core internal adapter and SHALL NOT include or dereference `source/as_module.h` directly.

#### Scenario: Script namespace behavior is preserved

- **WHEN** a script global is currently being initialized
- **THEN** `Script::GetNameOfGlobalVariableBeingInitialized`, `GetNamespaceOfGlobalVariableBeingInitialized`, and `GetModuleNameOfGlobalVariableBeingInitialized` SHALL return the same values through the Core adapter

#### Scenario: No active initialization returns empty values

- **WHEN** no script global is being initialized
- **THEN** all three helpers SHALL return empty strings
