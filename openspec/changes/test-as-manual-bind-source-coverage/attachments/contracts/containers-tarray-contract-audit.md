# Containers/TArray authored-contract audit

## Scope and outcome

This is a plan-only, read-only migration map for `TestSource/Containers/TArray/**`. It does not edit TestSource, OpenSpec, runners, bindings, or product code.

- Source coverage: `58/58` files and inventory CaseIds.
- Callable coverage: `98/98` owner-qualified current callables.
- Designed `145` exact replacement declarations; `21` current compound callables split into independent raw contracts.
- Source-level negative cases with no callable: `12`; these remain compile-diagnostic contracts and do not fabricate execution coverage.
- Current callables missing an immediate English per-function comment: `98/98`.
- Case-level classification/oracle findings recorded: `14`.
- Proposed declarations contain no `Observe_*`, `SurfaceNNN`, `_Nominal`, or `Expected*`/`bExpect*` parameters.

## Domain boundary

The existing Bindings/TArray audit owns `TS-BIND-TARRAY-*`, MB-100 entry wiring, and exact bound surface registration. This report owns `TS-CONT-*` scenario/value/diagnostic contracts. A Containers case can cite `Sort`, `Append`, `FindIndex`, etc. as evidence, but it must not claim manual binding-entry coverage or reuse a binding CaseId.

## Binding and C++ cross-check findings

- Confirmed the exact AS-facing TArray registrations used here: indexed read/write, Add, Append, Swap, Insert, AddUnique, Empty, Reset, Reserve, SetNum, FindIndex, Contains, Remove, RemoveAt, Sort, Num, Max, IsValidIndex, foreach, and explicit iterators.
- Runtime index read/write/Swap use exact exception `Array index out of bounds.`; Insert, negative SetNum, and iterator Proceed have distinct diagnostics and are not conflated with OOB indexing.
- `TArraySortAndReverse` actually exercises only `Sort`; the plan does not invent a bound Reverse API.
- Reserve vectors use the relation `Max >= requested` while preserving Num/elements; they do not assume allocator capacity equals the request.
- AddUnique vectors assert its raw bool for both inserted and duplicate outcomes, in addition to receiver writeback.
- The float-index case is positive fork behavior because the reference C++ negative assertion is disabled under `#as-engine-behavior implicit-conversion-permissive`.
- Seven syntax-negative C++ references assert only compilation failure and preserve no exact diagnostic string. Those proposals are explicitly blocked on diagnostic capture instead of inventing exact text.

## Evidence hashes

- `sourceAggregateSha256`: `5c739d51408942787d21b1ec85b0c81fd5d1297db0eb10212fbe2e82bf9b83c9`
- `inventorySha256`: `3e8da3b5b0c3d1158736043912e2a6f93d5f7ce31bfd13c0cd43cb31a7d1dde5`
- `existingBindingsTArrayAuditSha256`: `247dae9d8aff5c1fa99c6792b49e156b2d8cfdb42a4f124795f85d92dbd93925`
- `bindingSourceAggregateSha256`: `5fd4cb42a5e543c1a559ab911f942f80f5cf10ad0cdbee3762e001aea82d99ef`
- `referencedCppAggregateSha256`: `c58b53ffa4b9e2aabda89d166c914bc5d26b07290c0bec9b1f46732b92af7fd7`
- `generatorSha256`: `8bec8ae1a916772411793c3c4d9ebbc25f1c1abdbb66f0e14977d78d7f23e230`

## Deterministic execution batches

### B01-compile-diagnostics

Depends on: `none`. Exit: Every negative file has one exact/contains diagnostic contract; no execution claim.

### B02-syntax-and-basic-raw-array

Depends on: `B01-compile-diagnostics`. Exit: Basic functions use semantic names, explicit inputs, raw returns/writebacks.

### B03-typed-value-roundtrips

Depends on: `B02-syntax-and-basic-raw-array`. Exit: Color/rotator/transform/string functions expose typed arrays and raw values.

### B04-reflected-array-functions

Depends on: `B03-typed-value-roundtrips`. Exit: Reflected methods have exact externalized inputs/out arrays; runner status remains truthful.

### B05-advanced-array-scenarios

Depends on: `B02-syntax-and-basic-raw-array, B03-typed-value-roundtrips`. Exit: Incidental BeginPlay actor stories are split into explicit pure-value callables.

### B06-world-and-uobject-identity

Depends on: `B05-advanced-array-scenarios`. Exit: World/UObject inputs are runner-owned; source never spawns hidden fixtures.

### B07-runtime-exceptions

Depends on: `B02-syntax-and-basic-raw-array`. Exit: Read/write OOB vectors assert exact exception and post-failure state.

## Contract conventions

- Stable `caseId` remains the current `TS-CONT-*` inventory identity. Each current callable gets a stable ordinal subcase; splits append `-A`, `-B`, and so on.
- Replacement is hard: remove legacy source symbols and do not add forwarding aliases. CaseId/subcaseId, not the old function name, preserve identity.
- Exact proposed declarations externalize operation inputs. `const TArray<T>&in` is read-only; `TArray<T>&inout` exposes receiver state; constructed data uses a typed return or `&out`.
- Expected values live only in vectors. Source callables return raw values or writebacks and do not compare to expected values.
- Every proposed callable includes the exact English comment that must be placed immediately above it.
- Actor `BeginPlay` stories are not preserved merely because the reference C++ used spawning as a harness. Unless lifecycle itself is the behavior, they are split into explicit invokable callables. These entries remain runner-update pending.
- UObject and World objects are supplied and cleaned up by the runner. The source may build reference arrays but must not spawn hidden actors.
- Compile-negative files assert diagnostics and never claim runtime execution. Runtime OOB cases assert exact `Array index out of bounds.` before checking post-failure writeback.

## Per-source exact migration map

### TS-CONT-0013 — `TestSource/Containers/TArray/Test_ArrayOfMaps.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageContainerNestedTests.cpp :: FAngelscriptCoverageContainerNestedTest :: ArrayOfMaps :: block 1 :: lines 105-112 :: sha256=525e895c6e060d54734dfa553e84c2ea5865fad765fd7ee12d520a1d916e06f5`.

Source-level contract (no callable): `TArray<TMap<int32,FString>> Dictionaries` must fail compilation with a diagnostic containing `Containers cannot be nested in other containers`. Execution status is `compile-diagnostic-only`.
Required adjacent source comment: `// CaseId TS-CONT-0013; source-level negative contract. The declaration TArray<TMap<int32,FString>> Dictionaries must fail compilation with a diagnostic containing 'Containers cannot be nested in other containers'. This source is compile-only; the runner owns expected-diagnostic registration and failed-module cleanup.`

### TS-CONT-0015 — `TestSource/Containers/TArray/Test_ArrayOfSets.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageContainerNestedTests.cpp :: FAngelscriptCoverageContainerNestedTest :: ArrayOfSets :: block 1 :: lines 137-144 :: sha256=fc00db341d7054575e3fdea0f376d18369beae14baa8826cac5319b720c2247b`.

Source-level contract (no callable): `TArray<TSet<int32>> SetCollection` must fail compilation with a diagnostic containing `Containers cannot be nested in other containers`. Execution status is `compile-diagnostic-only`.
Required adjacent source comment: `// CaseId TS-CONT-0015; source-level negative contract. The declaration TArray<TSet<int32>> SetCollection must fail compilation with a diagnostic containing 'Containers cannot be nested in other containers'. This source is compile-only; the runner owns expected-diagnostic registration and failed-module cleanup.`

### TS-CONT-0009 — `TestSource/Containers/TArray/Test_ArrayOfStructsContainingArrays.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageContainerAdvancedTests.cpp :: FAngelscriptCoverageContainerAdvancedTest :: ArrayOfStructsContainingArrays :: block 1 :: lines 330-373 :: sha256=6f18e17bddcd6658110d19b278d4988b56cf50a5242692e8d475726df1c5a194`.

Finding: `advertised-copy-independence-missing: current source/C++ oracle checks nested values but never mutates a copy`.

#### Current `ACoverageContainerArrayStructArrayActor::BeginPlay` — `void BeginPlay()` (line 29)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0009-SC001-A` → `global::void BuildPayloads(const TArray<int32>&in FirstValues, const TArray<int32>&in SecondValues, TArray<FArrayPayload>&out Payloads)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Build two payload structs from runner-provided inner arrays and publish the outer array.
  - Comment: `// CaseId TS-CONT-0009; subcase TS-CONT-0009-SC001-A; role Act. Build two payload structs from runner-provided inner arrays and publish the outer array. Inputs: const TArray<int32>&in FirstValues (in), const TArray<int32>&in SecondValues (in), TArray<FArrayPayload>&out Payloads (out). Raw return: void; writebacks: Payloads. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `FirstValues=[1,2]; SecondValues=[10,20,30]`; raw return `void`; writebacks `Payloads=[{Values:[1,2]},{Values:[10,20,30]}]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0009-SC001-B` → `global::int32 CountPayloads(const TArray<FArrayPayload>&in Payloads)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw outer array count.
  - Comment: `// CaseId TS-CONT-0009; subcase TS-CONT-0009-SC001-B; role Read. Return the raw outer array count. Inputs: const TArray<FArrayPayload>&in Payloads (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Payloads=[]`; raw return `0`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Payloads=two payloads`; raw return `2`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0009-SC001-C` → `global::int32 CountPayloadValues(const TArray<FArrayPayload>&in Payloads, int32 PayloadIndex)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw inner Values count at the selected payload.
  - Comment: `// CaseId TS-CONT-0009; subcase TS-CONT-0009-SC001-C; role Read. Return the raw inner Values count at the selected payload. Inputs: const TArray<FArrayPayload>&in Payloads (in), int32 PayloadIndex (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `two payloads; PayloadIndex=0`; raw return `2`; writebacks `none`; exception `none`.
  - Vector 2: inputs `two payloads; PayloadIndex=1`; raw return `3`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0009-SC001-D` → `global::int32 ReadPayloadValue(const TArray<FArrayPayload>&in Payloads, int32 PayloadIndex, int32 ValueIndex)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return one raw nested value without collapsing it into a boolean.
  - Comment: `// CaseId TS-CONT-0009; subcase TS-CONT-0009-SC001-D; role Read. Return one raw nested value without collapsing it into a boolean. Inputs: const TArray<FArrayPayload>&in Payloads (in), int32 PayloadIndex (in), int32 ValueIndex (in). Raw return: int32; writebacks: none. Valid indices return the exact element; invalid outer or inner indices raise the exact TArray bounds exception. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `payloads; PayloadIndex=1; ValueIndex=0`; raw return `10`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0009-SC001-E` → `global::void CopyPayloadThenAppendValue(FArrayPayload&inout Source, int32 AppendedValue, FArrayPayload&out OriginalCopy)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Copy the payload, append to Source.Values, and expose both states to prove value-copy independence.
  - Comment: `// CaseId TS-CONT-0009; subcase TS-CONT-0009-SC001-E; role Act. Copy the payload, append to Source.Values, and expose both states to prove value-copy independence. Inputs: FArrayPayload&inout Source (inout), int32 AppendedValue (in), FArrayPayload&out OriginalCopy (out). Raw return: void; writebacks: Source, OriginalCopy. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Source.Values=[1,2]; AppendedValue=3`; raw return `void`; writebacks `Source.Values=[1,2,3]; OriginalCopy.Values=[1,2]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0008 — `TestSource/Containers/TArray/Test_BoolNestedArrayProperties.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageBoolPropertyTests.cpp :: FAngelscriptCoverageBoolPropertyTest :: BoolNestedArrayProperties :: block 1 :: lines 389-396 :: sha256=90bbe8aeba2ea111adccd39c49ace6179216083d6a8457821112b762ef4b63d3`.

Source-level contract (no callable): `TArray<TArray<bool>> Matrix` must fail compilation with a diagnostic containing `Attempting to instantiate invalid template type 'TArray<bool[]>': Containers cannot be nested in other containers`. Execution status is `compile-diagnostic-only`.
Required adjacent source comment: `// CaseId TS-CONT-0008; source-level negative contract. The declaration TArray<TArray<bool>> Matrix must fail compilation with a diagnostic containing 'Attempting to instantiate invalid template type 'TArray<bool[]>': Containers cannot be nested in other containers'. This source is compile-only; the runner owns expected-diagnostic registration and failed-module cleanup.`

### TS-CONT-0022 — `TestSource/Containers/TArray/Test_FunctionArrayAndConversionRoundTrip.as`

Batch: `B03-typed-value-roundtrips`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageFLinearColorFunctionTests.cpp :: FAngelscriptCoverageFLinearColorFunctionTest :: FunctionArrayAndConversionRoundTrip :: block 1 :: lines 255-304 :: sha256=11c7f2635685ba8f032d6554890f2b9d789926caf4853b1a6d20e544eb856a8f`.

#### Current `global::MakeColorArray` — `TArray<FLinearColor> MakeColorArray()` (line 7)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0022-SC001` → `global::TArray<FLinearColor> MakeColorArray(FLinearColor First, FLinearColor Second, FLinearColor Third)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Return the three runner-provided colors in order.
  - Comment: `// CaseId TS-CONT-0022; subcase TS-CONT-0022-SC001; role Act. Return the three runner-provided colors in order. Inputs: FLinearColor First (in), FLinearColor Second (in), FLinearColor Third (in). Raw return: TArray<FLinearColor>; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `First=Red; Second=(.25,.5,.75,1); Third=Blue`; raw return `[Red,(.25,.5,.75,1),Blue]`; writebacks `none`; exception `none`.

#### Current `global::SumColorArray` — `FLinearColor SumColorArray(const TArray<FLinearColor>&in Values)` (line 17)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0022-SC002` → `global::FLinearColor SumColorArray(const TArray<FLinearColor>&in Values)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw component-wise color sum.
  - Comment: `// CaseId TS-CONT-0022; subcase TS-CONT-0022-SC002; role Read. Return the raw component-wise color sum. Inputs: const TArray<FLinearColor>&in Values (in). Raw return: FLinearColor; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]`; raw return `Transparent`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[(.1,.2,.3,.4),(.2,.3,.4,.5)]`; raw return `(.3,.5,.7,.9)`; writebacks `none`; exception `none`.

#### Current `global::ValidateArrayReturn` — `int ValidateArrayReturn()` (line 27)

Current findings: `missing-immediate-english-function-comment`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0022-SC003-A` → `global::int32 CountColorArray(const TArray<FLinearColor>&in Values)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw array count.
  - Comment: `// CaseId TS-CONT-0022; subcase TS-CONT-0022-SC003-A; role Read. Return the raw array count. Inputs: const TArray<FLinearColor>&in Values (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]`; raw return `0`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=three colors`; raw return `3`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.
- `TS-CONT-0022-SC003-B` → `global::FLinearColor ReadColorArrayValue(const TArray<FLinearColor>&in Values, int32 Index)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the selected raw color value.
  - Comment: `// CaseId TS-CONT-0022; subcase TS-CONT-0022-SC003-B; role Read. Return the selected raw color value. Inputs: const TArray<FLinearColor>&in Values (in), int32 Index (in). Raw return: FLinearColor; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[Red,Blue]; Index=1`; raw return `Blue`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::ValidateArrayInput` — `int ValidateArrayInput()` (line 37)

Current findings: `missing-immediate-english-function-comment`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0022-SC004` → `global::FLinearColor SumProvidedColors(const TArray<FLinearColor>&in Values)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw sum for externally supplied color values.
  - Comment: `// CaseId TS-CONT-0022; subcase TS-CONT-0022-SC004; role Read. Return the raw sum for externally supplied color values. Inputs: const TArray<FLinearColor>&in Values (in). Raw return: FLinearColor; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[(.1,.2,.3,.4),(.2,.3,.4,.5)]`; raw return `(.3,.5,.7,.9)`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::ReturnFromFColor` — `FLinearColor ReturnFromFColor(FColor Packed)` (line 46)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0022-SC005` → `global::FLinearColor ConvertPackedColor(FColor Packed)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw FLinearColor constructor conversion.
  - Comment: `// CaseId TS-CONT-0022; subcase TS-CONT-0022-SC005; role Read. Return the raw FLinearColor constructor conversion. Inputs: FColor Packed (in). Raw return: FLinearColor; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Packed=FColor::Red`; raw return `linear Red`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Packed=FColor::Black`; raw return `linear Black`; writebacks `none`; exception `none`.

#### Current `global::ReturnReinterpretedFColor` — `FLinearColor ReturnReinterpretedFColor(FColor Packed)` (line 51)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0022-SC006` → `global::FLinearColor ReinterpretPackedColor(FColor Packed)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw ReinterpretAsLinear result.
  - Comment: `// CaseId TS-CONT-0022; subcase TS-CONT-0022-SC006; role Read. Return the raw ReinterpretAsLinear result. Inputs: FColor Packed (in). Raw return: FLinearColor; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Packed=FColor::Green`; raw return `linear Green`; writebacks `none`; exception `none`.

#### Current `global::Observe_ColorArray_Nominal` — `bool Observe_ColorArray_Nominal()` (line 56)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0022-SC007` → `global::void InspectColorArray(const TArray<FLinearColor>&in Values, int32&out Count, FLinearColor&out First, FLinearColor&out Last)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Publish raw count and endpoint values instead of a compound comparison.
  - Comment: `// CaseId TS-CONT-0022; subcase TS-CONT-0022-SC007; role Read. Publish raw count and endpoint values instead of a compound comparison. Inputs: const TArray<FLinearColor>&in Values (in), int32&out Count (out), FLinearColor&out First (out), FLinearColor&out Last (out). Raw return: void; writebacks: Count, First, Last. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[Red,Gray,Blue]`; raw return `void`; writebacks `Count=3; First=Red; Last=Blue`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_ColorArray_EmptyDefault` — `bool Observe_ColorArray_EmptyDefault()` (line 61)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0022-SC008` → `global::FLinearColor SumColorArrayBoundary(const TArray<FLinearColor>&in Values)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the sum so the empty/default oracle remains outside the source.
  - Comment: `// CaseId TS-CONT-0022; subcase TS-CONT-0022-SC008; role Read. Return the sum so the empty/default oracle remains outside the source. Inputs: const TArray<FLinearColor>&in Values (in). Raw return: FLinearColor; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]`; raw return `Transparent`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[Red]`; raw return `Red`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_ColorArray_CopyIndependence` — `bool Observe_ColorArray_CopyIndependence()` (line 68)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0022-SC009` → `global::void CopyThenReplaceColor(TArray<FLinearColor>&inout Source, int32 Index, FLinearColor Replacement, TArray<FLinearColor>&out OriginalCopy)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Copy Source, replace one Source element, and expose both arrays.
  - Comment: `// CaseId TS-CONT-0022; subcase TS-CONT-0022-SC009; role Act. Copy Source, replace one Source element, and expose both arrays. Inputs: TArray<FLinearColor>&inout Source (inout), int32 Index (in), FLinearColor Replacement (in), TArray<FLinearColor>&out OriginalCopy (out). Raw return: void; writebacks: Source, OriginalCopy. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Source=[Red,Blue]; Index=0; Replacement=Green`; raw return `void`; writebacks `Source=[Green,Blue]; OriginalCopy=[Red,Blue]`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_FColorConversion_Nominal` — `bool Observe_FColorConversion_Nominal()` (line 76)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0022-SC010` → `global::FLinearColor ConvertPackedColorForObservation(FColor Packed)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw constructor conversion for runner-side component comparison.
  - Comment: `// CaseId TS-CONT-0022; subcase TS-CONT-0022-SC010; role Read. Return the raw constructor conversion for runner-side component comparison. Inputs: FColor Packed (in). Raw return: FLinearColor; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Packed=FColor::Red`; raw return `linear Red`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0023 — `TestSource/Containers/TArray/Test_FunctionConstArrayAndStoredMemberRoundTrip_01.as`

Batch: `B03-typed-value-roundtrips`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageFRotatorFunctionTests.cpp :: FAngelscriptCoverageFRotatorFunctionTest :: FunctionConstArrayAndStoredMemberRoundTrip :: block 1 :: lines 384-426 :: sha256=9156e639faa90c1fc1acd8ad67555c7ba3f07b84cc87e4aeec51e67844b0876a`.

#### Current `global::MakeRotatorArray` — `TArray<FRotator> MakeRotatorArray()` (line 6)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0023-SC001` → `global::TArray<FRotator> MakeRotatorArray(FRotator First, FRotator Second, FRotator Third)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Return runner-provided rotators in order.
  - Comment: `// CaseId TS-CONT-0023; subcase TS-CONT-0023-SC001; role Act. Return runner-provided rotators in order. Inputs: FRotator First (in), FRotator Second (in), FRotator Third (in). Raw return: TArray<FRotator>; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `First=Zero; Second=(0,90,0); Third=(10,20,30)`; raw return `ordered three rotators`; writebacks `none`; exception `none`.

#### Current `global::SumRotatorArray` — `FRotator SumRotatorArray(const TArray<FRotator>&in Values)` (line 15)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0023-SC002` → `global::FRotator SumRotatorArray(const TArray<FRotator>&in Values)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw component-wise rotator sum.
  - Comment: `// CaseId TS-CONT-0023; subcase TS-CONT-0023-SC002; role Read. Return the raw component-wise rotator sum. Inputs: const TArray<FRotator>&in Values (in). Raw return: FRotator; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]`; raw return `ZeroRotator`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[(1,2,3),(4,5,6)]`; raw return `(5,7,9)`; writebacks `none`; exception `none`.

#### Current `global::ValidateArrayReturn` — `int ValidateArrayReturn()` (line 25)

Current findings: `missing-immediate-english-function-comment`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0023-SC003` → `global::void InspectRotatorArray(const TArray<FRotator>&in Values, int32&out Count, FRotator&out First, FRotator&out Last)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Publish count and endpoint rotators without comparisons.
  - Comment: `// CaseId TS-CONT-0023; subcase TS-CONT-0023-SC003; role Read. Publish count and endpoint rotators without comparisons. Inputs: const TArray<FRotator>&in Values (in), int32&out Count (out), FRotator&out First (out), FRotator&out Last (out). Raw return: void; writebacks: Count, First, Last. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[Zero,(0,90,0),(10,20,30)]`; raw return `void`; writebacks `Count=3; First=Zero; Last=(10,20,30)`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::ValidateArrayInput` — `int ValidateArrayInput()` (line 35)

Current findings: `missing-immediate-english-function-comment`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0023-SC004` → `global::FRotator SumProvidedRotators(const TArray<FRotator>&in Values)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw sum of supplied rotators.
  - Comment: `// CaseId TS-CONT-0023; subcase TS-CONT-0023-SC004; role Read. Return the raw sum of supplied rotators. Inputs: const TArray<FRotator>&in Values (in). Raw return: FRotator; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[(1,2,3),(4,5,6)]`; raw return `(5,7,9)`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::ReadConstRotator` — `FRotator ReadConstRotator(const FRotator&in Value)` (line 43)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0023-SC005` → `global::FRotator InvertRotator(const FRotator&in Value)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return Value.GetInverse() without comparison.
  - Comment: `// CaseId TS-CONT-0023; subcase TS-CONT-0023-SC005; role Read. Return Value.GetInverse() without comparison. Inputs: const FRotator&in Value (in). Raw return: FRotator; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Value=ZeroRotator`; raw return `ZeroRotator`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Value=(0,90,0)`; raw return `inverse rotation`; writebacks `none`; exception `none`.

#### Current `global::Observe_RotatorArray_Nominal` — `bool Observe_RotatorArray_Nominal()` (line 48)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0023-SC006` → `global::void ReadRotatorArraySummary(const TArray<FRotator>&in Values, int32&out Count, FRotator&out Sum)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Publish raw count and sum for the runner oracle.
  - Comment: `// CaseId TS-CONT-0023; subcase TS-CONT-0023-SC006; role Read. Publish raw count and sum for the runner oracle. Inputs: const TArray<FRotator>&in Values (in), int32&out Count (out), FRotator&out Sum (out). Raw return: void; writebacks: Count, Sum. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[(1,2,3),(4,5,6)]`; raw return `void`; writebacks `Count=2; Sum=(5,7,9)`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_RotatorArray_EmptyDefault` — `bool Observe_RotatorArray_EmptyDefault()` (line 53)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0023-SC007` → `global::FRotator SumRotatorArrayBoundary(const TArray<FRotator>&in Values)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw sum for empty and populated boundary vectors.
  - Comment: `// CaseId TS-CONT-0023; subcase TS-CONT-0023-SC007; role Read. Return the raw sum for empty and populated boundary vectors. Inputs: const TArray<FRotator>&in Values (in). Raw return: FRotator; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]`; raw return `ZeroRotator`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[(1,2,3)]`; raw return `(1,2,3)`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0027 — `TestSource/Containers/TArray/Test_FunctionConstArrayAndStoredMemberRoundTrip_01_R01279.as`

Batch: `B03-typed-value-roundtrips`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageFTransformFunctionTests.cpp :: FAngelscriptCoverageFTransformFunctionTest :: FunctionConstArrayAndStoredMemberRoundTrip :: block 1 :: lines 483-525 :: sha256=c29dbf6614eeb2f88197bd3efae0ef089fcd7dcb9c9814cff4333d58feecae72`.

#### Current `global::MakeTransformArray` — `TArray<FTransform> MakeTransformArray()` (line 4)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0027-SC001` → `global::TArray<FTransform> MakeTransformArray(FTransform First, FTransform Second, FTransform Third)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Return runner-provided transforms in order.
  - Comment: `// CaseId TS-CONT-0027; subcase TS-CONT-0027-SC001; role Act. Return runner-provided transforms in order. Inputs: FTransform First (in), FTransform Second (in), FTransform Third (in). Raw return: TArray<FTransform>; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `First=Identity; Second=translation(10,20,30); Third=scaled transform`; raw return `ordered three transforms`; writebacks `none`; exception `none`.

#### Current `global::CombineTransformArray` — `FTransform CombineTransformArray(const TArray<FTransform>&in Values)` (line 13)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0027-SC002` → `global::FTransform CombineTransformArray(const TArray<FTransform>&in Values)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw transform product in array order.
  - Comment: `// CaseId TS-CONT-0027; subcase TS-CONT-0027-SC002; role Read. Return the raw transform product in array order. Inputs: const TArray<FTransform>&in Values (in). Raw return: FTransform; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]`; raw return `Identity`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[translation X1, translation Y2]`; raw return `translation(1,2,0)`; writebacks `none`; exception `none`.

#### Current `global::ValidateArrayReturn` — `int ValidateArrayReturn()` (line 23)

Current findings: `missing-immediate-english-function-comment`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0027-SC003` → `global::void InspectTransformArray(const TArray<FTransform>&in Values, int32&out Count, FTransform&out First, FTransform&out Last)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Publish count and endpoint transforms without comparisons.
  - Comment: `// CaseId TS-CONT-0027; subcase TS-CONT-0027-SC003; role Read. Publish count and endpoint transforms without comparisons. Inputs: const TArray<FTransform>&in Values (in), int32&out Count (out), FTransform&out First (out), FTransform&out Last (out). Raw return: void; writebacks: Count, First, Last. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=three transforms`; raw return `void`; writebacks `Count=3; First=Identity; Last=third transform`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::ValidateArrayInput` — `int ValidateArrayInput()` (line 33)

Current findings: `missing-immediate-english-function-comment`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0027-SC004` → `global::FTransform CombineProvidedTransforms(const TArray<FTransform>&in Values)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw product of supplied transforms.
  - Comment: `// CaseId TS-CONT-0027; subcase TS-CONT-0027-SC004; role Read. Return the raw product of supplied transforms. Inputs: const TArray<FTransform>&in Values (in). Raw return: FTransform; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[translation X1, translation Y2]`; raw return `translation(1,2,0)`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::ReadConstTransform` — `FTransform ReadConstTransform(const FTransform&in Value)` (line 41)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0027-SC005` → `global::FTransform InvertTransform(const FTransform&in Value)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return Value.Inverse() without comparison.
  - Comment: `// CaseId TS-CONT-0027; subcase TS-CONT-0027-SC005; role Read. Return Value.Inverse() without comparison. Inputs: const FTransform&in Value (in). Raw return: FTransform; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Value=Identity`; raw return `Identity`; writebacks `none`; exception `none`.

#### Current `global::Observe_TransformArray_Nominal` — `bool Observe_TransformArray_Nominal()` (line 46)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0027-SC006` → `global::void ReadTransformArraySummary(const TArray<FTransform>&in Values, int32&out Count, FTransform&out Combined)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Publish raw count and product for runner-side comparison.
  - Comment: `// CaseId TS-CONT-0027; subcase TS-CONT-0027-SC006; role Read. Publish raw count and product for runner-side comparison. Inputs: const TArray<FTransform>&in Values (in), int32&out Count (out), FTransform&out Combined (out). Raw return: void; writebacks: Count, Combined. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=two translations`; raw return `void`; writebacks `Count=2; Combined=their ordered product`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_TransformArray_EmptyDefault` — `bool Observe_TransformArray_EmptyDefault()` (line 51)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0027-SC007` → `global::FTransform CombineTransformArrayBoundary(const TArray<FTransform>&in Values)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw product for empty and populated boundary vectors.
  - Comment: `// CaseId TS-CONT-0027; subcase TS-CONT-0027-SC007; role Read. Return the raw product for empty and populated boundary vectors. Inputs: const TArray<FTransform>&in Values (in). Raw return: FTransform; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]`; raw return `Identity`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[translation X1]`; raw return `translation X1`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0024 — `TestSource/Containers/TArray/Test_FunctionConstArrayAndStoredMemberRoundTrip_02.as`

Batch: `B04-reflected-array-functions`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageFRotatorFunctionTests.cpp :: FAngelscriptCoverageFRotatorFunctionTest :: FunctionConstArrayAndStoredMemberRoundTrip :: block 2 :: lines 469-519 :: sha256=0aa36aba2e6ef8c5c1295306361a211970d8fff32d760863ca397274157c371b`.

#### Current `ACoverageFRotatorFunctionArrayActor::StoreAndReturn` — `FRotator StoreAndReturn(FRotator Value)` (line 18)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0024-SC001` → `ACoverageFRotatorFunctionArrayActor::FRotator StoreRotatorAndReturnInverse(FRotator Value)`
  - Status: declaration `candidate-reflected-runner-update-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `runner-created UObject`.
  - Behavior: Store Value on the instance and return its raw inverse.
  - Comment: `// CaseId TS-CONT-0024; subcase TS-CONT-0024-SC001; role Act. Store Value on the instance and return its raw inverse. Inputs: FRotator Value (in). Raw return: FRotator; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Runner releases the instance/module; all input containers remain runner-owned.`
  - Vector 1: inputs `Value=(10,20,30)`; raw return `inverse`; writebacks `StoredRotator=(10,20,30)`; exception `none`.
  - Blocker: Existing C++ reference uses the old reflected signature; source-only migration may materialize the new contract, but execution status stays pending until a runner invokes the exact new signature.

#### Current `ACoverageFRotatorFunctionArrayActor::AcceptRotatorArray` — `int AcceptRotatorArray(const TArray<FRotator>&in Values)` (line 25)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0024-SC002` → `ACoverageFRotatorFunctionArrayActor::int32 AcceptRotatorArray(const TArray<FRotator>&in Values, FRotator&out Combined)`
  - Status: declaration `candidate-reflected-runner-update-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `runner-created UObject`.
  - Behavior: Return the raw count and publish the ordered rotator sum.
  - Comment: `// CaseId TS-CONT-0024; subcase TS-CONT-0024-SC002; role Act. Return the raw count and publish the ordered rotator sum. Inputs: const TArray<FRotator>&in Values (in), FRotator&out Combined (out). Raw return: int32; writebacks: Combined. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Runner releases the instance/module; all input containers remain runner-owned.`
  - Vector 1: inputs `Values=[]`; raw return `0`; writebacks `Combined=ZeroRotator; StoredRotator=ZeroRotator; LastArrayCount=0`; exception `none`.
  - Vector 2: inputs `Values=[(1,2,3),(4,5,6)]`; raw return `2`; writebacks `Combined=(5,7,9); StoredRotator=(5,7,9); LastArrayCount=2`; exception `none`.
  - Blocker: Existing C++ reference uses the old reflected signature; source-only migration may materialize the new contract, but execution status stays pending until a runner invokes the exact new signature.

#### Current `ACoverageFRotatorFunctionArrayActor::MakeRotatorArray` — `TArray<FRotator> MakeRotatorArray(FRotator First, FRotator Second)` (line 37)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0024-SC003` → `ACoverageFRotatorFunctionArrayActor::TArray<FRotator> MakeRotatorArray(FRotator First, FRotator Second)`
  - Status: declaration `candidate-reflected-runner-update-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `runner-created UObject`.
  - Behavior: Return both inputs in order and store the same array on the instance.
  - Comment: `// CaseId TS-CONT-0024; subcase TS-CONT-0024-SC003; role Act. Return both inputs in order and store the same array on the instance. Inputs: FRotator First (in), FRotator Second (in). Raw return: TArray<FRotator>; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Runner releases the instance/module; all input containers remain runner-owned.`
  - Vector 1: inputs `First=Zero; Second=(30,60,90)`; raw return `[Zero,(30,60,90)]`; writebacks `StoredRotators=same`; exception `none`.
  - Blocker: Existing C++ reference uses the old reflected signature; source-only migration may materialize the new contract, but execution status stays pending until a runner invokes the exact new signature.

#### Current `ACoverageFRotatorFunctionArrayActor::FillOutRotatorArray` — `void FillOutRotatorArray(TArray<FRotator>&out Result)` (line 47)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0024-SC004` → `ACoverageFRotatorFunctionArrayActor::void FillOutRotatorArray(FRotator First, FRotator Second, TArray<FRotator>&out Result)`
  - Status: declaration `candidate-reflected-runner-update-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `runner-created UObject`.
  - Behavior: Fill Result from explicit inputs and mirror it to StoredRotators.
  - Comment: `// CaseId TS-CONT-0024; subcase TS-CONT-0024-SC004; role Act. Fill Result from explicit inputs and mirror it to StoredRotators. Inputs: FRotator First (in), FRotator Second (in), TArray<FRotator>&out Result (out). Raw return: void; writebacks: Result. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Runner releases the instance/module; all input containers remain runner-owned.`
  - Vector 1: inputs `First=Zero; Second=(30,60,90)`; raw return `void`; writebacks `Result=[Zero,(30,60,90)]; StoredRotators=same`; exception `none`.
  - Blocker: Existing C++ reference uses the old reflected signature; source-only migration may materialize the new contract, but execution status stays pending until a runner invokes the exact new signature.

### TS-CONT-0028 — `TestSource/Containers/TArray/Test_FunctionConstArrayAndStoredMemberRoundTrip_02_R01280.as`

Batch: `B04-reflected-array-functions`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageFTransformFunctionTests.cpp :: FAngelscriptCoverageFTransformFunctionTest :: FunctionConstArrayAndStoredMemberRoundTrip :: block 2 :: lines 568-618 :: sha256=9154ed377b2ccb41075c320f1ab8289c25b98899eac12cd8555196554b2e2be1`.

#### Current `ACoverageFTransformFunctionArrayActor::StoreAndReturnInverse` — `FTransform StoreAndReturnInverse(FTransform Value)` (line 17)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0028-SC001` → `ACoverageFTransformFunctionArrayActor::FTransform StoreTransformAndReturnInverse(FTransform Value)`
  - Status: declaration `candidate-reflected-runner-update-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `runner-created UObject`.
  - Behavior: Store Value and return its raw inverse.
  - Comment: `// CaseId TS-CONT-0028; subcase TS-CONT-0028-SC001; role Act. Store Value and return its raw inverse. Inputs: FTransform Value (in). Raw return: FTransform; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Runner releases the instance/module; all input containers remain runner-owned.`
  - Vector 1: inputs `Value=translation(10,20,30)`; raw return `inverse`; writebacks `StoredTransform=Value`; exception `none`.
  - Blocker: Existing C++ reference uses the old reflected signature; source-only migration may materialize the new contract, but execution status stays pending until a runner invokes the exact new signature.

#### Current `ACoverageFTransformFunctionArrayActor::AcceptTransformArray` — `int AcceptTransformArray(const TArray<FTransform>&in Values)` (line 24)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0028-SC002` → `ACoverageFTransformFunctionArrayActor::int32 AcceptTransformArray(const TArray<FTransform>&in Values, FTransform&out Combined)`
  - Status: declaration `candidate-reflected-runner-update-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `runner-created UObject`.
  - Behavior: Return the raw count and publish the ordered transform product.
  - Comment: `// CaseId TS-CONT-0028; subcase TS-CONT-0028-SC002; role Act. Return the raw count and publish the ordered transform product. Inputs: const TArray<FTransform>&in Values (in), FTransform&out Combined (out). Raw return: int32; writebacks: Combined. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Runner releases the instance/module; all input containers remain runner-owned.`
  - Vector 1: inputs `Values=[]`; raw return `0`; writebacks `Combined=Identity; StoredTransform=Identity; LastArrayCount=0`; exception `none`.
  - Vector 2: inputs `Values=two transforms`; raw return `2`; writebacks `Combined=ordered product; StoredTransform=same`; exception `none`.
  - Blocker: Existing C++ reference uses the old reflected signature; source-only migration may materialize the new contract, but execution status stays pending until a runner invokes the exact new signature.

#### Current `ACoverageFTransformFunctionArrayActor::MakeTransformArray` — `TArray<FTransform> MakeTransformArray(FTransform First, FTransform Second)` (line 36)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0028-SC003` → `ACoverageFTransformFunctionArrayActor::TArray<FTransform> MakeTransformArray(FTransform First, FTransform Second)`
  - Status: declaration `candidate-reflected-runner-update-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `runner-created UObject`.
  - Behavior: Return both inputs in order and store the same array.
  - Comment: `// CaseId TS-CONT-0028; subcase TS-CONT-0028-SC003; role Act. Return both inputs in order and store the same array. Inputs: FTransform First (in), FTransform Second (in). Raw return: TArray<FTransform>; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Runner releases the instance/module; all input containers remain runner-owned.`
  - Vector 1: inputs `First=Identity; Second=translated/scaled`; raw return `[First,Second]`; writebacks `StoredTransforms=same`; exception `none`.
  - Blocker: Existing C++ reference uses the old reflected signature; source-only migration may materialize the new contract, but execution status stays pending until a runner invokes the exact new signature.

#### Current `ACoverageFTransformFunctionArrayActor::FillOutTransformArray` — `void FillOutTransformArray(TArray<FTransform>&out Result)` (line 46)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0028-SC004` → `ACoverageFTransformFunctionArrayActor::void FillOutTransformArray(FTransform First, FTransform Second, TArray<FTransform>&out Result)`
  - Status: declaration `candidate-reflected-runner-update-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `runner-created UObject`.
  - Behavior: Fill Result from explicit inputs and mirror it to StoredTransforms.
  - Comment: `// CaseId TS-CONT-0028; subcase TS-CONT-0028-SC004; role Act. Fill Result from explicit inputs and mirror it to StoredTransforms. Inputs: FTransform First (in), FTransform Second (in), TArray<FTransform>&out Result (out). Raw return: void; writebacks: Result. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Runner releases the instance/module; all input containers remain runner-owned.`
  - Vector 1: inputs `First=Identity; Second=translated/scaled`; raw return `void`; writebacks `Result=[First,Second]; StoredTransforms=same`; exception `none`.
  - Blocker: Existing C++ reference uses the old reflected signature; source-only migration may materialize the new contract, but execution status stays pending until a runner invokes the exact new signature.

### TS-CONT-0055 — `TestSource/Containers/TArray/Test_GameStatePlayerArrayAndPlayerStateIdentitySurface.as`

Batch: `B06-world-and-uobject-identity`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageNetworkingTests.cpp :: FAngelscriptCoverageNetworkingTest :: GameStatePlayerArrayAndPlayerStateIdentitySurface :: block 1 :: lines 2443-2465 :: sha256=bc687467e479c2d00ad7d8998cccc2d8bc160241b90dfb203dc989fb19d29595`.

Finding: `tautological-mask-oracle: Num() >= 0 and Len() >= 0 cannot prove values; score >= 0 incorrectly excludes valid negative scores`.

#### Current `ACoverageNetworkingGameStatePlayerSurface::QueryGameStateAndPlayerState` — `int QueryGameStateAndPlayerState(AGameStateBase GameState, APlayerState PlayerState)` (line 9)

Current findings: `missing-immediate-english-function-comment`.

- `TS-CONT-0055-SC001-A` → `global::int32 CountGameStatePlayers(AGameStateBase GameState)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `runner-owned world/UObject`.
  - Behavior: Return PlayerArray.Num(), or zero for a null GameState boundary.
  - Comment: `// CaseId TS-CONT-0055; subcase TS-CONT-0055-SC001-A; role Read. Return PlayerArray.Num(), or zero for a null GameState boundary. Inputs: AGameStateBase GameState (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `GameState=null`; raw return `0`; writebacks `none`; exception `none`.
  - Vector 2: inputs `GameState with N players`; raw return `N`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0055-SC001-B` → `global::FString ReadPlayerStateName(APlayerState PlayerState)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `runner-owned world/UObject`.
  - Behavior: Return GetPlayerName(), or the empty string for a null PlayerState boundary.
  - Comment: `// CaseId TS-CONT-0055; subcase TS-CONT-0055-SC001-B; role Read. Return GetPlayerName(), or the empty string for a null PlayerState boundary. Inputs: APlayerState PlayerState (in). Raw return: FString; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `PlayerState=null`; raw return `''`; writebacks `none`; exception `none`.
  - Vector 2: inputs `named PlayerState`; raw return `raw player name`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0055-SC001-C` → `global::float32 ReadPlayerStateScore(APlayerState PlayerState)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `runner-owned world/UObject`.
  - Behavior: Return GetScore(), or zero for a null PlayerState boundary.
  - Comment: `// CaseId TS-CONT-0055; subcase TS-CONT-0055-SC001-C; role Read. Return GetScore(), or zero for a null PlayerState boundary. Inputs: APlayerState PlayerState (in). Raw return: float32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `PlayerState=null`; raw return `0.0`; writebacks `none`; exception `none`.
  - Vector 2: inputs `PlayerState score=12.5`; raw return `12.5`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

#### Current `global::Observe_NullFixturesYieldZero` — `int Observe_NullFixturesYieldZero(ACoverageNetworkingGameStatePlayerSurface Surface)` (line 31)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`.

- `TS-CONT-0055-SC002` → `global::int32 CountPlayersOrZero(AGameStateBase GameState)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `runner-owned world/UObject`.
  - Behavior: Expose the null GameState boundary as a raw player count rather than a mask/self-check.
  - Comment: `// CaseId TS-CONT-0055; subcase TS-CONT-0055-SC002; role Read. Expose the null GameState boundary as a raw player count rather than a mask/self-check. Inputs: AGameStateBase GameState (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `GameState=null`; raw return `0`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0051 — `TestSource/Containers/TArray/Test_IntNestedArrayContainerBoundary.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageIntPropertyTests.cpp :: FAngelscriptCoverageIntPropertyTest :: IntNestedArrayContainerBoundary :: block 1 :: lines 1256-1263 :: sha256=7aaad05c51aba1242dd3f5972ea4fcc5cdbd666610911906eb680b07cf40363d`.

Finding: `inventory-shape-mismatch: WorldStory must become NegativeDiagnostic`.

Source-level contract (no callable): `TArray<TArray<int32>> Matrix` must fail compilation with a diagnostic containing `Containers cannot be nested in other containers`. Execution status is `compile-diagnostic-only`.
Required adjacent source comment: `// CaseId TS-CONT-0051; source-level negative contract. The declaration TArray<TArray<int32>> Matrix must fail compilation with a diagnostic containing 'Containers cannot be nested in other containers'. This source is compile-only; the runner owns expected-diagnostic registration and failed-module cleanup.`

Blocker: SourceShape is marked WorldStory but source and C++ oracle are compile-negative; correct to NegativeDiagnostic.

### TS-CONT-0014 — `TestSource/Containers/TArray/Test_MapOfArrays_OneToMany.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageContainerNestedTests.cpp :: FAngelscriptCoverageContainerNestedTest :: MapOfArrays_OneToMany :: block 1 :: lines 121-128 :: sha256=e4381ec2daa56be877d1d7bf627cc957df81ea10cea4f98769b78c95dc4a9354`.

Source-level contract (no callable): `TMap<int32,TArray<int32>> GroupedData` must fail compilation with a diagnostic containing `Containers cannot be nested in other containers`. Execution status is `compile-diagnostic-only`.
Required adjacent source comment: `// CaseId TS-CONT-0014; source-level negative contract. The declaration TMap<int32,TArray<int32>> GroupedData must fail compilation with a diagnostic containing 'Containers cannot be nested in other containers'. This source is compile-only; the runner owns expected-diagnostic registration and failed-module cleanup.`

### TS-CONT-0011 — `TestSource/Containers/TArray/Test_NestedArrays_DeepMatrix.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageContainerNestedTests.cpp :: FAngelscriptCoverageContainerNestedTest :: NestedArrays_DeepMatrix :: block 1 :: lines 74-81 :: sha256=b39b834258a96590cfd13b43947ba2d384cf64f75fc587ce1ca49818efe88bd0`.

Source-level contract (no callable): `TArray<TArray<TArray<int32>>> Matrix` must fail compilation with a diagnostic containing `Containers cannot be nested in other containers`. Execution status is `compile-diagnostic-only`.
Required adjacent source comment: `// CaseId TS-CONT-0011; source-level negative contract. The declaration TArray<TArray<TArray<int32>>> Matrix must fail compilation with a diagnostic containing 'Containers cannot be nested in other containers'. This source is compile-only; the runner owns expected-diagnostic registration and failed-module cleanup.`

### TS-CONT-0012 — `TestSource/Containers/TArray/Test_NestedArrays_LocalDeepMatrix.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageContainerNestedTests.cpp :: FAngelscriptCoverageContainerNestedTest :: NestedArrays_LocalDeepMatrix :: block 1 :: lines 90-96 :: sha256=ddd69e1adeab76d6d8cd7cfa70b02f429bc6675a6a975899674f03fea0112a0a`.

#### Current `global::BuildLocalDeepMatrix` — `int BuildLocalDeepMatrix()` (line 4)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0012-SC001` → `global::void TriggerLocalThreeLevelArrayDeclaration()`
  - Status: declaration `reviewed-diagnostic`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Declare a local TArray<TArray<TArray<int32>>> to preserve the unsupported nesting boundary.
  - Comment: `// CaseId TS-CONT-0012; subcase TS-CONT-0012-SC001; role NegativeTrigger. Declare a local TArray<TArray<TArray<int32>>> to preserve the unsupported nesting boundary. Inputs: none. Raw return: void; writebacks: none. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `contains: "Containers cannot be nested in other containers"`.

### TS-CONT-0010 — `TestSource/Containers/TArray/Test_NestedArrays_TwoDimensionalMatrix.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageContainerNestedTests.cpp :: FAngelscriptCoverageContainerNestedTest :: NestedArrays_TwoDimensionalMatrix :: block 1 :: lines 58-65 :: sha256=262770fdd65c3687111dc8fc796c8b225c4dc7340c63c3b5f544deffe81cf1e3`.

Source-level contract (no callable): `TArray<TArray<int32>> Matrix` must fail compilation with a diagnostic containing `Containers cannot be nested in other containers`. Execution status is `compile-diagnostic-only`.
Required adjacent source comment: `// CaseId TS-CONT-0010; source-level negative contract. The declaration TArray<TArray<int32>> Matrix must fail compilation with a diagnostic containing 'Containers cannot be nested in other containers'. This source is compile-only; the runner owns expected-diagnostic registration and failed-module cleanup.`

### TS-CONT-0025 — `TestSource/Containers/TArray/Test_ParseIntoArrayDelimiterVariants.as`

Batch: `B03-typed-value-roundtrips`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageFStringMethodTests.cpp :: FAngelscriptCoverageFStringMethodTest :: ParseIntoArrayDelimiterVariants :: block 1 :: lines 798-819 :: sha256=9d52b11a3b00b1ee7da7fbfbc18e0076847bc1b0da81772354692191193804f0`.

#### Current `global::TestParseIntoArrayWithDelimiterArray` — `FString TestParseIntoArrayWithDelimiterArray()` (line 5)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0025-SC001` → `global::int32 ParseWithDelimiterArray(const FString&in Source, const TArray<FString>&in Delimiters, TArray<FString>&out Parts)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Return ParseIntoArray's raw count and expose the parsed parts.
  - Comment: `// CaseId TS-CONT-0025; subcase TS-CONT-0025-SC001; role Act. Return ParseIntoArray's raw count and expose the parsed parts. Inputs: const FString&in Source (in), const TArray<FString>&in Delimiters (in), TArray<FString>&out Parts (out). Raw return: int32; writebacks: Parts. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Source='alpha,beta;gamma|delta'; Delimiters=[',',';','|']`; raw return `4`; writebacks `Parts=['alpha','beta','gamma','delta']`; exception `none`.

#### Current `global::TestParseIntoArrayKeepsBoundaryEmptyValues` — `FString TestParseIntoArrayKeepsBoundaryEmptyValues()` (line 18)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0025-SC002` → `global::int32 ParseWithDelimiter(const FString&in Source, const FString&in Delimiter, bool bCullEmpty, TArray<FString>&out Parts)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Return the raw count and parts for the single-delimiter overload.
  - Comment: `// CaseId TS-CONT-0025; subcase TS-CONT-0025-SC002; role Act. Return the raw count and parts for the single-delimiter overload. Inputs: const FString&in Source (in), const FString&in Delimiter (in), bool bCullEmpty (in), TArray<FString>&out Parts (out). Raw return: int32; writebacks: Parts. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Source='|middle|'; Delimiter='|'; bCullEmpty=false`; raw return `3`; writebacks `Parts=['','middle','']`; exception `none`.

#### Current `global::Observe_ParseIntoArray_Nominal` — `bool Observe_ParseIntoArray_Nominal()` (line 26)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0025-SC003` → `global::FString FormatParsedParts(int32 Count, const TArray<FString>&in Parts, int32 FirstIndex, int32 SecondIndex)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Format explicit raw parse outputs without invoking another hidden parse.
  - Comment: `// CaseId TS-CONT-0025; subcase TS-CONT-0025-SC003; role Read. Format explicit raw parse outputs without invoking another hidden parse. Inputs: int32 Count (in), const TArray<FString>&in Parts (in), int32 FirstIndex (in), int32 SecondIndex (in). Raw return: FString; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Count=4; Parts=['alpha','beta','gamma','delta']; FirstIndex=1; SecondIndex=3`; raw return `'4:beta:delta'`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_ParseIntoArray_EmptyDefault` — `bool Observe_ParseIntoArray_EmptyDefault()` (line 32)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0025-SC004` → `global::int32 ParseEmptyStringBoundary(const FString&in Source, const FString&in Delimiter, TArray<FString>&out Parts)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Return the raw parse count and parts for empty and non-empty sources.
  - Comment: `// CaseId TS-CONT-0025; subcase TS-CONT-0025-SC004; role Act. Return the raw parse count and parts for empty and non-empty sources. Inputs: const FString&in Source (in), const FString&in Delimiter (in), TArray<FString>&out Parts (out). Raw return: int32; writebacks: Parts. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Source=''; Delimiter=','`; raw return `0`; writebacks `Parts=[]`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0131 — `TestSource/Containers/TArray/Test_TArray_Negative_01.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Negative :: block 1 :: lines 121-123 :: sha256=28b4923d5d49b0e7b11122b361c9c4148c7eecec7548ba03436624c5b7ea6795`.

Finding: `exact-diagnostic-not-preserved: current C++ AssertFailsToCompile checks failure only`.

#### Current `global::Test` — `void Test()` (line 4)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`.

- `TS-CONT-0131-SC001` → `global::void TriggerUntypedArrayDeclaration()`
  - Status: declaration `blocking-exact-diagnostic-capture-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Declare TArray without a template argument.
  - Comment: `// CaseId TS-CONT-0131; subcase TS-CONT-0131-SC001; role NegativeTrigger. Declare TArray without a template argument. Inputs: none. Raw return: void; writebacks: none. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `compile failure; exact diagnostic pending capture`.
  - Blocker: Capture and review the actual compiler diagnostic before promoting this entry to reviewed-diagnostic; the current C++ authority asserts failure only.

### TS-CONT-0132 — `TestSource/Containers/TArray/Test_TArray_Negative_02.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Negative :: block 2 :: lines 128-130 :: sha256=77c66626afc9c41894b9fd12bfea46fa96ba2042e615ad4b54fff7f12e1e14a7`.

Finding: `exact-diagnostic-not-preserved: current C++ AssertFailsToCompile checks failure only`.

#### Current `global::Test` — `void Test()` (line 4)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`.

- `TS-CONT-0132-SC001` → `global::void TriggerWrongElementTypeAdd(TArray<int32>&inout Values)`
  - Status: declaration `blocking-exact-diagnostic-capture-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Pass an FString literal to TArray<int32>.Add.
  - Comment: `// CaseId TS-CONT-0132; subcase TS-CONT-0132-SC001; role NegativeTrigger. Pass an FString literal to TArray<int32>.Add. Inputs: TArray<int32>&inout Values (inout). Raw return: void; writebacks: Values. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `compile failure; exact diagnostic pending capture`.
  - Blocker: Capture and review the actual compiler diagnostic before promoting this entry to reviewed-diagnostic; the current C++ authority asserts failure only.

### TS-CONT-0133 — `TestSource/Containers/TArray/Test_TArray_Negative_03.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Negative :: block 3 :: lines 135-137 :: sha256=586e90d48841f1d4a680b86a33fbfcdf118faf6e5bc6059bf8887910f7993d46`.

Finding: `exact-diagnostic-not-preserved: current C++ AssertFailsToCompile checks failure only`.

#### Current `global::Test` — `void Test()` (line 4)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`.

- `TS-CONT-0133-SC001` → `global::void TriggerUnknownElementTypeDeclaration()`
  - Status: declaration `blocking-exact-diagnostic-capture-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Instantiate TArray with an unknown element type.
  - Comment: `// CaseId TS-CONT-0133; subcase TS-CONT-0133-SC001; role NegativeTrigger. Instantiate TArray with an unknown element type. Inputs: none. Raw return: void; writebacks: none. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `compile failure; exact diagnostic pending capture`.
  - Blocker: Capture and review the actual compiler diagnostic before promoting this entry to reviewed-diagnostic; the current C++ authority asserts failure only.

### TS-CONT-0134 — `TestSource/Containers/TArray/Test_TArray_Negative_04.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Negative :: block 4 :: lines 142-144 :: sha256=f52594626bf4bb2c6059c3528491679abd5c97f3afb1f0c95db0dd949ec959e7`.

Finding: `exact-diagnostic-not-preserved: current C++ AssertFailsToCompile checks failure only`.

#### Current `global::Test` — `void Test()` (line 4)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`.

- `TS-CONT-0134-SC001` → `global::void TriggerNestedArrayDeclaration()`
  - Status: declaration `blocking-exact-diagnostic-capture-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Declare the unsupported TArray<TArray<int32>> local.
  - Comment: `// CaseId TS-CONT-0134; subcase TS-CONT-0134-SC001; role NegativeTrigger. Declare the unsupported TArray<TArray<int32>> local. Inputs: none. Raw return: void; writebacks: none. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `compile failure; exact diagnostic pending capture`.
  - Blocker: Capture and review the actual compiler diagnostic before promoting this entry to reviewed-diagnostic; the current C++ authority asserts failure only.

### TS-CONT-0135 — `TestSource/Containers/TArray/Test_TArray_Negative_05.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Negative :: block 5 :: lines 149-151 :: sha256=5dac2ddfd0392e38ff20128d47b626ff217bec477331f9c25183c0ce47bcdd02`.

Finding: `exact-diagnostic-not-preserved: current C++ AssertFailsToCompile checks failure only`.

#### Current `global::Test` — `void Test()` (line 4)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`.

- `TS-CONT-0135-SC001` → `global::void TriggerVoidArrayDeclaration()`
  - Status: declaration `blocking-exact-diagnostic-capture-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Instantiate the invalid TArray<void> type.
  - Comment: `// CaseId TS-CONT-0135; subcase TS-CONT-0135-SC001; role NegativeTrigger. Instantiate the invalid TArray<void> type. Inputs: none. Raw return: void; writebacks: none. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `compile failure; exact diagnostic pending capture`.
  - Blocker: Capture and review the actual compiler diagnostic before promoting this entry to reviewed-diagnostic; the current C++ authority asserts failure only.

### TS-CONT-0136 — `TestSource/Containers/TArray/Test_TArray_Negative_06.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Negative :: block 6 :: lines 156-158 :: sha256=6378d8771fdd7c0582b3421b0f35f24825b126da122c4d3639d759615f90f6bd`.

Finding: `exact-diagnostic-not-preserved: current C++ AssertFailsToCompile checks failure only`.

#### Current `global::Test` — `void Test()` (line 6)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`.

- `TS-CONT-0136-SC001` → `global::int32 TriggerStringArrayIndex(const TArray<int32>&in Values, const FString&in Index)`
  - Status: declaration `blocking-exact-diagnostic-capture-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Use FString as an integer-array index.
  - Comment: `// CaseId TS-CONT-0136; subcase TS-CONT-0136-SC001; role NegativeTrigger. Use FString as an integer-array index. Inputs: const TArray<int32>&in Values (in), const FString&in Index (in). Raw return: int32; writebacks: none. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `compile failure; exact diagnostic pending capture`.
  - Blocker: Capture and review the actual compiler diagnostic before promoting this entry to reviewed-diagnostic; the current C++ authority asserts failure only.

### TS-CONT-0137 — `TestSource/Containers/TArray/Test_TArray_Negative_07.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Negative :: block 7 :: lines 165-167 :: sha256=d0846114c6bb32545282bc9ea96adca50230c0fda03a03156a1706adaef708ec`.

Finding: `inventory-shape-mismatch: reference negative assertion is disabled; this is positive permissive-conversion behavior`.

#### Current `global::Test` — `void Test()` (line 7)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0137-SC001` → `global::int32 ReadIntWithFloatIndex(const TArray<int32>&in Values, float32 Index)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the element selected by the fork's permissive float-to-index conversion.
  - Comment: `// CaseId TS-CONT-0137; subcase TS-CONT-0137-SC001; role Read. Return the element selected by the fork's permissive float-to-index conversion. Inputs: const TArray<int32>&in Values (in), float32 Index (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[1]; Index=.5`; raw return `1`; writebacks `none`; exception `none`.

#### Current `global::Observe_FloatIndex_Nominal` — `int Observe_FloatIndex_Nominal()` (line 14)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0137-SC002` → `global::int32 ReadIntWithFractionalIndex(const TArray<int32>&in Values, float32 Index)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw value selected by a fractional float index.
  - Comment: `// CaseId TS-CONT-0137; subcase TS-CONT-0137-SC002; role Read. Return the raw value selected by a fractional float index. Inputs: const TArray<int32>&in Values (in), float32 Index (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[1]; Index=.5`; raw return `1`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_FloatIndex_ZeroDefault` — `int Observe_FloatIndex_ZeroDefault()` (line 22)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0137-SC003` → `global::int32 ReadIntWithIntegralFloatIndex(const TArray<int32>&in Values, float32 Index)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw value selected by zero represented as float.
  - Comment: `// CaseId TS-CONT-0137; subcase TS-CONT-0137-SC003; role Read. Return the raw value selected by zero represented as float. Inputs: const TArray<int32>&in Values (in), float32 Index (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[7]; Index=0.0`; raw return `7`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_FloatIndex_TruncTowardZeroBoundary` — `int Observe_FloatIndex_TruncTowardZeroBoundary()` (line 30)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0137-SC004` → `global::int32 ReadIntWithTruncatedPositiveFloatIndex(const TArray<int32>&in Values, float32 Index)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the value after the documented permissive conversion.
  - Comment: `// CaseId TS-CONT-0137; subcase TS-CONT-0137-SC004; role Read. Return the value after the documented permissive conversion. Inputs: const TArray<int32>&in Values (in), float32 Index (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[1,2]; Index=1.9`; raw return `2`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_FloatIndex_EmptyDefault` — `bool Observe_FloatIndex_EmptyDefault()` (line 39)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0137-SC005` → `global::int32 CountIntsInFloatIndexCase(const TArray<int32>&in Values)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw Num so the empty boundary is explicit.
  - Comment: `// CaseId TS-CONT-0137; subcase TS-CONT-0137-SC005; role Read. Return raw Num so the empty boundary is explicit. Inputs: const TArray<int32>&in Values (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]`; raw return `0`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_FloatIndex_CopyIndependence` — `bool Observe_FloatIndex_CopyIndependence()` (line 45)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0137-SC006` → `global::void CopyThenReplaceInt(TArray<int32>&inout Source, int32 Index, int32 Replacement, TArray<int32>&out OriginalCopy)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Copy Source, replace one element, and expose both arrays.
  - Comment: `// CaseId TS-CONT-0137; subcase TS-CONT-0137-SC006; role Act. Copy Source, replace one element, and expose both arrays. Inputs: TArray<int32>&inout Source (inout), int32 Index (in), int32 Replacement (in), TArray<int32>&out OriginalCopy (out). Raw return: void; writebacks: Source, OriginalCopy. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Source=[1]; Index=0; Replacement=9`; raw return `void`; writebacks `Source=[9]; OriginalCopy=[1]`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0138 — `TestSource/Containers/TArray/Test_TArray_Negative_08.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Negative :: block 8 :: lines 173-175 :: sha256=abfd002782a25f9a9cc4a512f27e8e6f551b84b3eba8a91e5423454538d8770c`.

Finding: `exact-diagnostic-not-preserved: current C++ AssertFailsToCompile checks failure only`.

#### Current `global::Test` — `void Test()` (line 7)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`.

- `TS-CONT-0138-SC001` → `global::void TriggerMismatchedArrayAssignment(TArray<int32>&inout Destination, const TArray<FString>&in Source)`
  - Status: declaration `blocking-exact-diagnostic-capture-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Assign a string array to an integer array.
  - Comment: `// CaseId TS-CONT-0138; subcase TS-CONT-0138-SC001; role NegativeTrigger. Assign a string array to an integer array. Inputs: TArray<int32>&inout Destination (inout), const TArray<FString>&in Source (in). Raw return: void; writebacks: Destination. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `compile failure; exact diagnostic pending capture`.
  - Blocker: Capture and review the actual compiler diagnostic before promoting this entry to reviewed-diagnostic; the current C++ authority asserts failure only.

### TS-CONT-0122 — `TestSource/Containers/TArray/Test_TArray_Positive_01.as`

Batch: `B02-syntax-and-basic-raw-array`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Positive :: block 1 :: lines 50-52 :: sha256=1a302bcb5e8c86c6f8c4dc9e9481fb9653f7b39225a8118b6f4aa089f6865ecb`.

#### Current `global::Test` — `void Test()` (line 4)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0122-SC001` → `global::TArray<int32> ConstructEmptyIntArray()`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Return a default-constructed empty integer array.
  - Comment: `// CaseId TS-CONT-0122; subcase TS-CONT-0122-SC001; role Act. Return a default-constructed empty integer array. Inputs: none. Raw return: TArray<int32>; writebacks: none. Zero arguments are intrinsic to default construction; the returned array exposes the result. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `no inputs: default construction is intrinsic`; raw return `[]`; writebacks `none`; exception `none`.

#### Current `global::Observe_EmptyDefault` — `bool Observe_EmptyDefault()` (line 9)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0122-SC002` → `global::int32 CountConstructedIntArray(const TArray<int32>&in Values)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw Num for the default/empty vector.
  - Comment: `// CaseId TS-CONT-0122; subcase TS-CONT-0122-SC002; role Read. Return raw Num for the default/empty vector. Inputs: const TArray<int32>&in Values (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]`; raw return `0`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0123 — `TestSource/Containers/TArray/Test_TArray_Positive_02.as`

Batch: `B02-syntax-and-basic-raw-array`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Positive :: block 2 :: lines 56-58 :: sha256=b5e7ae4487ea2a8ef36ab2575f5c58c1f264e7d91103bc65b0d1d42975a3776f`.

#### Current `global::Test` — `void Test()` (line 3)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0123-SC001` → `global::void AddTwoInts(TArray<int32>&inout Values, int32 First, int32 Second)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Append both inputs in order.
  - Comment: `// CaseId TS-CONT-0123; subcase TS-CONT-0123-SC001; role Act. Append both inputs in order. Inputs: TArray<int32>&inout Values (inout), int32 First (in), int32 Second (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; First=1; Second=2`; raw return `void`; writebacks `[1,2]`; exception `none`.

#### Current `global::Observe_AddNominal` — `bool Observe_AddNominal()` (line 10)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0123-SC002` → `global::void AddInt(TArray<int32>&inout Values, int32 Value)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Append one input and expose exact writeback.
  - Comment: `// CaseId TS-CONT-0123; subcase TS-CONT-0123-SC002; role Act. Append one input and expose exact writeback. Inputs: TArray<int32>&inout Values (inout), int32 Value (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[1]; Value=2`; raw return `void`; writebacks `[1,2]`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_EmptyDefault` — `bool Observe_EmptyDefault()` (line 18)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0123-SC003` → `global::int32 CountInts(const TArray<int32>&in Values)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw Num.
  - Comment: `// CaseId TS-CONT-0123; subcase TS-CONT-0123-SC003; role Read. Return raw Num. Inputs: const TArray<int32>&in Values (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]`; raw return `0`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0124 — `TestSource/Containers/TArray/Test_TArray_Positive_03.as`

Batch: `B02-syntax-and-basic-raw-array`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Positive :: block 3 :: lines 62-64 :: sha256=ffb1e8cdf5d2bb67508b6ed6f0ea2ad8a43ab1d02a2df2069369d2709450f391`.

#### Current `global::Test` — `void Test()` (line 4)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0124-SC001` → `global::int32 AddThenReadInt(TArray<int32>&inout Values, int32 Value, int32 Index)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Append Value and return the raw indexed element.
  - Comment: `// CaseId TS-CONT-0124; subcase TS-CONT-0124-SC001; role Act. Append Value and return the raw indexed element. Inputs: TArray<int32>&inout Values (inout), int32 Value (in), int32 Index (in). Raw return: int32; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; Value=5; Index=0`; raw return `5`; writebacks `Values=[5]`; exception `none`.

#### Current `global::Observe_IndexNominal` — `bool Observe_IndexNominal()` (line 11)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0124-SC002` → `global::int32 ReadIntAt(const TArray<int32>&in Values, int32 Index)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the selected raw element.
  - Comment: `// CaseId TS-CONT-0124; subcase TS-CONT-0124-SC002; role Read. Return the selected raw element. Inputs: const TArray<int32>&in Values (in), int32 Index (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[5]; Index=0`; raw return `5`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0125 — `TestSource/Containers/TArray/Test_TArray_Positive_04.as`

Batch: `B02-syntax-and-basic-raw-array`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Positive :: block 4 :: lines 68-70 :: sha256=bad42f220ddbc4e5ff69ee7f47b23961479097befb873f194fe73f16de327b89`.

#### Current `global::Test` — `void Test()` (line 3)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0125-SC001` → `global::int32 AddThenCountInt(TArray<int32>&inout Values, int32 Value)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Append Value and return raw Num.
  - Comment: `// CaseId TS-CONT-0125; subcase TS-CONT-0125-SC001; role Act. Append Value and return raw Num. Inputs: TArray<int32>&inout Values (inout), int32 Value (in). Raw return: int32; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; Value=1`; raw return `1`; writebacks `Values=[1]`; exception `none`.

#### Current `global::Observe_NumNominal` — `bool Observe_NumNominal()` (line 10)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0125-SC002` → `global::int32 CountAfterAddingInt(TArray<int32>&inout Values, int32 Value)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Append Value, return raw Num, and expose Values.
  - Comment: `// CaseId TS-CONT-0125; subcase TS-CONT-0125-SC002; role Act. Append Value, return raw Num, and expose Values. Inputs: TArray<int32>&inout Values (inout), int32 Value (in). Raw return: int32; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; Value=1`; raw return `1`; writebacks `Values=[1]`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_NumEmpty` — `bool Observe_NumEmpty()` (line 17)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0125-SC003` → `global::int32 CountEmptyOrPopulatedInts(const TArray<int32>&in Values)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw Num for empty and populated vectors.
  - Comment: `// CaseId TS-CONT-0125; subcase TS-CONT-0125-SC003; role Read. Return raw Num for empty and populated vectors. Inputs: const TArray<int32>&in Values (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]`; raw return `0`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[1]`; raw return `1`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0126 — `TestSource/Containers/TArray/Test_TArray_Positive_05.as`

Batch: `B02-syntax-and-basic-raw-array`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Positive :: block 5 :: lines 74-82 :: sha256=aed037372c9c50a0c18ba31b5c1cb0dae2fc7e4be7b62d7dd686cbb120f442ff`.

#### Current `global::Test` — `void Test()` (line 3)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0126-SC001` → `global::void AddThenRemoveIntAt(TArray<int32>&inout Values, int32 First, int32 Second, int32 RemoveIndex)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Append two inputs, remove one index, and expose ordered survivors.
  - Comment: `// CaseId TS-CONT-0126; subcase TS-CONT-0126-SC001; role Act. Append two inputs, remove one index, and expose ordered survivors. Inputs: TArray<int32>&inout Values (inout), int32 First (in), int32 Second (in), int32 RemoveIndex (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; First=1; Second=2; RemoveIndex=0`; raw return `void`; writebacks `[2]`; exception `none`.

#### Current `global::Observe_RemoveAtNominal` — `bool Observe_RemoveAtNominal()` (line 11)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0126-SC002` → `global::void RemoveIntAt(TArray<int32>&inout Values, int32 Index)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Remove the requested index and expose ordered survivors.
  - Comment: `// CaseId TS-CONT-0126; subcase TS-CONT-0126-SC002; role Act. Remove the requested index and expose ordered survivors. Inputs: TArray<int32>&inout Values (inout), int32 Index (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[1,2]; Index=0`; raw return `void`; writebacks `[2]`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0127 — `TestSource/Containers/TArray/Test_TArray_Positive_06.as`

Batch: `B02-syntax-and-basic-raw-array`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Positive :: block 6 :: lines 86-88 :: sha256=06325a8f2492b22913d31877dfbf6221013a5db5a0fd81237e6a11819d1c876b`.

#### Current `global::Test` — `void Test()` (line 3)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0127-SC001` → `global::void AddThenEmptyInts(TArray<int32>&inout Values, int32 Value, int32 ReservedSize)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Append Value then call Empty with explicit reserve.
  - Comment: `// CaseId TS-CONT-0127; subcase TS-CONT-0127-SC001; role Act. Append Value then call Empty with explicit reserve. Inputs: TArray<int32>&inout Values (inout), int32 Value (in), int32 ReservedSize (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; Value=1; ReservedSize=0`; raw return `void`; writebacks `[]`; exception `none`.

#### Current `global::Observe_EmptyClears` — `bool Observe_EmptyClears()` (line 10)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0127-SC002` → `global::void EmptyInts(TArray<int32>&inout Values, int32 ReservedSize)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Empty a populated array and expose zero elements.
  - Comment: `// CaseId TS-CONT-0127; subcase TS-CONT-0127-SC002; role Act. Empty a populated array and expose zero elements. Inputs: TArray<int32>&inout Values (inout), int32 ReservedSize (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[1]; ReservedSize=0`; raw return `void`; writebacks `[]`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_EmptyIdempotent` — `bool Observe_EmptyIdempotent()` (line 18)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0127-SC003` → `global::void EmptyAlreadyEmptyInts(TArray<int32>&inout Values, int32 ReservedSize)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Empty an already-empty array and expose idempotent state.
  - Comment: `// CaseId TS-CONT-0127; subcase TS-CONT-0127-SC003; role Act. Empty an already-empty array and expose idempotent state. Inputs: TArray<int32>&inout Values (inout), int32 ReservedSize (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; ReservedSize=0`; raw return `void`; writebacks `[]`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0128 — `TestSource/Containers/TArray/Test_TArray_Positive_07.as`

Batch: `B02-syntax-and-basic-raw-array`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Positive :: block 7 :: lines 92-94 :: sha256=81b054c51602edc9204de8cd5095a3654614732eda1e0e60c6716938ac18c894`.

#### Current `global::Test` — `void Test()` (line 3)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0128-SC001` → `global::void AddVector(TArray<FVector>&inout Values, FVector Value)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Append the explicit vector.
  - Comment: `// CaseId TS-CONT-0128; subcase TS-CONT-0128-SC001; role Act. Append the explicit vector. Inputs: TArray<FVector>&inout Values (inout), FVector Value (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; Value=(1,0,0)`; raw return `void`; writebacks `[(1,0,0)]`; exception `none`.

#### Current `global::Observe_VectorArrayNominal` — `bool Observe_VectorArrayNominal()` (line 9)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0128-SC002` → `global::FVector ReadVectorAt(const TArray<FVector>&in Values, int32 Index)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the selected raw vector.
  - Comment: `// CaseId TS-CONT-0128; subcase TS-CONT-0128-SC002; role Read. Return the selected raw vector. Inputs: const TArray<FVector>&in Values (in), int32 Index (in). Raw return: FVector; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[(1,0,0)]; Index=0`; raw return `(1,0,0)`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0129 — `TestSource/Containers/TArray/Test_TArray_Positive_08.as`

Batch: `B02-syntax-and-basic-raw-array`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Positive :: block 8 :: lines 98-100 :: sha256=d65a62dc2a776e19e6ef295743c39a63c3d464cb15e5b068187ef87dc07a2444`.

#### Current `global::Test` — `void Test()` (line 3)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0129-SC001` → `global::void AddString(TArray<FString>&inout Values, const FString&in Value)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Append the explicit string.
  - Comment: `// CaseId TS-CONT-0129; subcase TS-CONT-0129-SC001; role Act. Append the explicit string. Inputs: TArray<FString>&inout Values (inout), const FString&in Value (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; Value='Hello'`; raw return `void`; writebacks `['Hello']`; exception `none`.

#### Current `global::Observe_StringArrayNominal` — `bool Observe_StringArrayNominal()` (line 9)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0129-SC002` → `global::FString ReadStringAt(const TArray<FString>&in Values, int32 Index)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the selected raw string.
  - Comment: `// CaseId TS-CONT-0129; subcase TS-CONT-0129-SC002; role Read. Return the selected raw string. Inputs: const TArray<FString>&in Values (in), int32 Index (in). Raw return: FString; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=['Hello']; Index=0`; raw return `'Hello'`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_StringArrayEmptyElement` — `bool Observe_StringArrayEmptyElement()` (line 16)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0129-SC003` → `global::int32 ReadStringLengthAt(const TArray<FString>&in Values, int32 Index)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the selected string's raw length.
  - Comment: `// CaseId TS-CONT-0129; subcase TS-CONT-0129-SC003; role Read. Return the selected string's raw length. Inputs: const TArray<FString>&in Values (in), int32 Index (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=['']; Index=0`; raw return `0`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0130 — `TestSource/Containers/TArray/Test_TArray_Positive_09.as`

Batch: `B02-syntax-and-basic-raw-array`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxContainerTests.cpp :: FAngelscriptSyntaxContainerTest :: TArray_Positive :: block 9 :: lines 104-106 :: sha256=31e303cc55199c860bb68389ea66c7ead7281b76754fa591280445face2cf819`.

#### Current `global::Test` — `void Test()` (line 3)

Current findings: `missing-immediate-english-function-comment`, `generic-test-name`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0130-SC001` → `global::bool AddThenContainsInt(TArray<int32>&inout Values, int32 AddedValue, int32 SearchedValue)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Append AddedValue and return raw Contains for SearchedValue.
  - Comment: `// CaseId TS-CONT-0130; subcase TS-CONT-0130-SC001; role Act. Append AddedValue and return raw Contains for SearchedValue. Inputs: TArray<int32>&inout Values (inout), int32 AddedValue (in), int32 SearchedValue (in). Raw return: bool; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; AddedValue=5; SearchedValue=5`; raw return `true`; writebacks `Values=[5]`; exception `none`.

#### Current `global::Observe_ContainsNominal` — `bool Observe_ContainsNominal()` (line 10)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0130-SC002` → `global::bool ContainsInt(const TArray<int32>&in Values, int32 Value)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw Contains for present and absent vectors.
  - Comment: `// CaseId TS-CONT-0130; subcase TS-CONT-0130-SC002; role Read. Return raw Contains for present and absent vectors. Inputs: const TArray<int32>&in Values (in), int32 Value (in). Raw return: bool; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[5]; Value=5`; raw return `true`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[5]; Value=9`; raw return `false`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

#### Current `global::Observe_ContainsEmpty` — `bool Observe_ContainsEmpty()` (line 17)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `source-side-self-check-hides-raw-result`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0130-SC003` → `global::bool ContainsIntInEmptyOrPopulatedArray(const TArray<int32>&in Values, int32 Value)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw Contains, including the empty boundary.
  - Comment: `// CaseId TS-CONT-0130; subcase TS-CONT-0130-SC003; role Read. Return raw Contains, including the empty boundary. Inputs: const TArray<int32>&in Values (in), int32 Value (in). Raw return: bool; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; Value=5`; raw return `false`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0086 — `TestSource/Containers/TArray/Test_TArrayAddUniqueAndRemoveAll.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayAddUniqueAndRemoveAll :: block 1 :: lines 906-966 :: sha256=d37a5162e528366765026b441b9e73e2238287cdf89514357d9ca38d62d07592`.

#### Current `ACoverageTArrayUniqueRemoveActor::BeginPlay` — `void BeginPlay()` (line 17)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0086-SC001-A` → `global::bool AddUniqueInt(TArray<int32>&inout Values, int32 Value)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Return raw AddUnique and expose the receiver.
  - Comment: `// CaseId TS-CONT-0086; subcase TS-CONT-0086-SC001-A; role Act. Return raw AddUnique and expose the receiver. Inputs: TArray<int32>&inout Values (inout), int32 Value (in). Raw return: bool; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[5,10]; Value=15`; raw return `true`; writebacks `Values=[5,10,15]`; exception `none`.
  - Vector 2: inputs `Values=[5,10]; Value=5`; raw return `false`; writebacks `Values unchanged`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0086-SC001-B` → `global::int32 RemoveAllMatchingInts(TArray<int32>&inout Values, int32 Value)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Return raw Remove count and expose ordered survivors.
  - Comment: `// CaseId TS-CONT-0086; subcase TS-CONT-0086-SC001-B; role Act. Return raw Remove count and expose ordered survivors. Inputs: TArray<int32>&inout Values (inout), int32 Value (in). Raw return: int32; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[1,2,3,2,4,2,5]; Value=2`; raw return `3`; writebacks `Values=[1,3,4,5]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0089 — `TestSource/Containers/TArray/Test_TArrayAdvancedSearch.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayAdvancedSearch :: block 1 :: lines 1220-1283 :: sha256=f231fce6f5ff3bba6a9f3b16b786062f04e3c69b937b3e4728e06bd7aa5d20da`.

#### Current `ACoverageTArraySearchActor::BeginPlay` — `void BeginPlay()` (line 23)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0089-SC001-A` → `global::int32 FindLastIntIndex(const TArray<int32>&in Values, int32 Value)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the last matching index using explicit traversal.
  - Comment: `// CaseId TS-CONT-0089; subcase TS-CONT-0089-SC001-A; role Read. Return the last matching index using explicit traversal. Inputs: const TArray<int32>&in Values (in), int32 Value (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[5,10,5,15,5,20]; Value=5`; raw return `4`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[]; Value=5`; raw return `-1`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0089-SC001-B` → `global::bool ContainsInt(const TArray<int32>&in Values, int32 Value)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw Contains.
  - Comment: `// CaseId TS-CONT-0089; subcase TS-CONT-0089-SC001-B; role Read. Return raw Contains. Inputs: const TArray<int32>&in Values (in), int32 Value (in). Raw return: bool; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[5,10]; Value=5`; raw return `true`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Value=100`; raw return `false`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0089-SC001-C` → `global::bool IsIntArrayIndexValid(const TArray<int32>&in Values, int32 Index)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw IsValidIndex.
  - Comment: `// CaseId TS-CONT-0089; subcase TS-CONT-0089-SC001-C; role Read. Return raw IsValidIndex. Inputs: const TArray<int32>&in Values (in), int32 Index (in). Raw return: bool; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=six values; Index=5`; raw return `true`; writebacks `none`; exception `none`.
  - Vector 2: inputs `same; Index=10`; raw return `false`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0085 — `TestSource/Containers/TArray/Test_TArrayAppendAndMerge.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayAppendAndMerge :: block 1 :: lines 806-859 :: sha256=1cadff731189400c85d9091c3bf25cc318ded21223162c88a9b53b354f15fd44`.

#### Current `ACoverageTArrayAppendActor::BeginPlay` — `void BeginPlay()` (line 17)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0085-SC001-A` → `global::void AppendIntArray(TArray<int32>&inout Destination, const TArray<int32>&in Source)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Append Source and expose Destination's exact order.
  - Comment: `// CaseId TS-CONT-0085; subcase TS-CONT-0085-SC001-A; role Act. Append Source and expose Destination's exact order. Inputs: TArray<int32>&inout Destination (inout), const TArray<int32>&in Source (in). Raw return: void; writebacks: Destination. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Destination=[1,2,3]; Source=[4,5]`; raw return `void`; writebacks `Destination=[1,2,3,4,5]`; exception `none`.
  - Vector 2: inputs `Destination=[1,2,3]; Source=[]`; raw return `void`; writebacks `Destination unchanged`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0085-SC001-B` → `global::int32 CountAppendedInts(const TArray<int32>&in Values)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw Num for merged or empty results.
  - Comment: `// CaseId TS-CONT-0085; subcase TS-CONT-0085-SC001-B; role Read. Return raw Num for merged or empty results. Inputs: const TArray<int32>&in Values (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[1,2,3,4,5]`; raw return `5`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[]`; raw return `0`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0093 — `TestSource/Containers/TArray/Test_TArrayBulkOperations.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayBulkOperations :: block 1 :: lines 1554-1639 :: sha256=aba47f35f96277eaa893e9a2a7414020e4e1896efed44540c5b21e96665f9f15`.

#### Current `ACoverageTArrayBulkActor::BeginPlay` — `void BeginPlay()` (line 20)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0093-SC001-A` → `global::void ReserveAndFillIntRange(TArray<int32>&inout Values, int32 ReservedSize, int32 Start, int32 Count)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Reserve and append a consecutive range from explicit inputs.
  - Comment: `// CaseId TS-CONT-0093; subcase TS-CONT-0093-SC001-A; role Act. Reserve and append a consecutive range from explicit inputs. Inputs: TArray<int32>&inout Values (inout), int32 ReservedSize (in), int32 Start (in), int32 Count (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; ReservedSize=100; Start=0; Count=100`; raw return `void`; writebacks `Values=0..99; Num=100; Max>=100`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0093-SC001-B` → `global::void AppendThreeIntArrays(TArray<int32>&inout Destination, const TArray<int32>&in First, const TArray<int32>&in Second, const TArray<int32>&in Third)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Append three arrays in order and expose Destination.
  - Comment: `// CaseId TS-CONT-0093; subcase TS-CONT-0093-SC001-B; role Act. Append three arrays in order and expose Destination. Inputs: TArray<int32>&inout Destination (inout), const TArray<int32>&in First (in), const TArray<int32>&in Second (in), const TArray<int32>&in Third (in). Raw return: void; writebacks: Destination. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Destination=[]; First=0..49; Second=50..99; Third=100..149`; raw return `void`; writebacks `Destination=0..149`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0093-SC001-C` → `global::void AddUniqueIntsFromSource(const TArray<int32>&in Source, TArray<int32>&out UniqueValues)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Apply AddUnique in source order and expose exact unique values.
  - Comment: `// CaseId TS-CONT-0093; subcase TS-CONT-0093-SC001-C; role Act. Apply AddUnique in source order and expose exact unique values. Inputs: const TArray<int32>&in Source (in), TArray<int32>&out UniqueValues (out). Raw return: void; writebacks: UniqueValues. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Source=[1,2,3,2,4,3,5,1]`; raw return `void`; writebacks `UniqueValues=[1,2,3,4,5]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0094 — `TestSource/Containers/TArray/Test_TArrayDuplicateHandling.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayDuplicateHandling :: block 1 :: lines 1682-1752 :: sha256=501367b776975c4451545e6d2aab80f8bd9cb7b61a836b9ba0b0538bd372b262`.

#### Current `ACoverageTArrayDuplicatesActor::BeginPlay` — `void BeginPlay()` (line 20)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0094-SC001-A` → `global::int32 FindFirstDuplicateIntIndex(const TArray<int32>&in Values, int32 Value)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw first FindIndex.
  - Comment: `// CaseId TS-CONT-0094; subcase TS-CONT-0094-SC001-A; role Read. Return raw first FindIndex. Inputs: const TArray<int32>&in Values (in), int32 Value (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[5,10,5,15,5,20,5]; Value=5`; raw return `0`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0094-SC001-B` → `global::int32 FindLastDuplicateIntIndex(const TArray<int32>&in Values, int32 Value)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the last matching index.
  - Comment: `// CaseId TS-CONT-0094; subcase TS-CONT-0094-SC001-B; role Read. Return the last matching index. Inputs: const TArray<int32>&in Values (in), int32 Value (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `same; Value=5`; raw return `6`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0094-SC001-C` → `global::int32 CountMatchingInts(const TArray<int32>&in Values, int32 Value)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the exact occurrence count.
  - Comment: `// CaseId TS-CONT-0094; subcase TS-CONT-0094-SC001-C; role Read. Return the exact occurrence count. Inputs: const TArray<int32>&in Values (in), int32 Value (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `same; Value=5`; raw return `4`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0094-SC001-D` → `global::int32 RemoveDuplicateInts(TArray<int32>&inout Values, int32 Value)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Return raw Remove count and expose survivors.
  - Comment: `// CaseId TS-CONT-0094; subcase TS-CONT-0094-SC001-D; role Act. Return raw Remove count and expose survivors. Inputs: TArray<int32>&inout Values (inout), int32 Value (in). Raw return: int32; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[5,10,5,15,5,20,5]; Value=5`; raw return `4`; writebacks `Values=[10,15,20]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0091 — `TestSource/Containers/TArray/Test_TArrayEdgeCasesEmpty.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayEdgeCasesEmpty :: block 1 :: lines 1414-1468 :: sha256=61e81d563a275ff5cafa5902e2c385bac6851cedfa9cf2c599c4fb5660096758`.

#### Current `ACoverageTArrayEdgeCasesActor::BeginPlay` — `void BeginPlay()` (line 23)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0091-SC001-A` → `global::int32 CountInts(const TArray<int32>&in Values)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw Num for empty and singleton arrays.
  - Comment: `// CaseId TS-CONT-0091; subcase TS-CONT-0091-SC001-A; role Read. Return raw Num for empty and singleton arrays. Inputs: const TArray<int32>&in Values (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]`; raw return `0`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[42]`; raw return `1`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0091-SC001-B` → `global::int32 FindFirstIntInEdgeCaseArray(const TArray<int32>&in Values, int32 Value)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw FindIndex for empty and singleton arrays.
  - Comment: `// CaseId TS-CONT-0091; subcase TS-CONT-0091-SC001-B; role Read. Return raw FindIndex for empty and singleton arrays. Inputs: const TArray<int32>&in Values (in), int32 Value (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; Value=5`; raw return `-1`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[42]; Value=42`; raw return `0`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0091-SC001-C` → `global::bool ContainsIntInEdgeCaseArray(const TArray<int32>&in Values, int32 Value)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw Contains for empty and singleton arrays.
  - Comment: `// CaseId TS-CONT-0091; subcase TS-CONT-0091-SC001-C; role Read. Return raw Contains for empty and singleton arrays. Inputs: const TArray<int32>&in Values (in), int32 Value (in). Raw return: bool; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; Value=5`; raw return `false`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[42]; Value=42`; raw return `true`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0091-SC001-D` → `global::void SortEdgeCaseInts(TArray<int32>&inout Values, bool bDescendingOrder)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Sort empty or singleton arrays and expose unchanged valid state.
  - Comment: `// CaseId TS-CONT-0091; subcase TS-CONT-0091-SC001-D; role Act. Sort empty or singleton arrays and expose unchanged valid state. Inputs: TArray<int32>&inout Values (inout), bool bDescendingOrder (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; false`; raw return `void`; writebacks `[]`; exception `none`.
  - Vector 2: inputs `Values=[42]; false`; raw return `void`; writebacks `[42]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0074 — `TestSource/Containers/TArray/Test_TArrayFind.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayFind :: block 1 :: lines 214-245 :: sha256=9aa1f2b5cb0187f7b35cf423ce8ede4846ba1f2bb1a629b159cf6e55d6e2daf3`.

#### Current `ACoverageTArrayFindActor::BeginPlay` — `void BeginPlay()` (line 20)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0074-SC001` → `global::int32 FindFirstIntIndex(const TArray<int32>&in Values, int32 Value)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return FindIndex's raw first matching index or -1.
  - Comment: `// CaseId TS-CONT-0074; subcase TS-CONT-0074-SC001; role Read. Return FindIndex's raw first matching index or -1. Inputs: const TArray<int32>&in Values (in), int32 Value (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[100,200,300,200]; Value=200`; raw return `1`; writebacks `none`; exception `none`.
  - Vector 2: inputs `same; Value=999`; raw return `-1`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0076 — `TestSource/Containers/TArray/Test_TArrayForEachIteration.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayForEachIteration :: block 1 :: lines 359-415 :: sha256=ed252a9b9af9525abf335e194fbfa680c605fdba4ea6406939116d89df0d8673`.

#### Current `ACoverageTArrayForEachActor::BeginPlay` — `void BeginPlay()` (line 23)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0076-SC001-A` → `global::int32 SumIntsByValue(const TArray<int32>&in Values)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the foreach-by-value sum without mutating Values.
  - Comment: `// CaseId TS-CONT-0076; subcase TS-CONT-0076-SC001-A; role Read. Return the foreach-by-value sum without mutating Values. Inputs: const TArray<int32>&in Values (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[1,2,3,4,5]`; raw return `15`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[]`; raw return `0`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0076-SC001-B` → `global::int32 DoubleIntsByReference(TArray<int32>&inout Values)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Double each foreach reference, return the raw sum, and expose Values.
  - Comment: `// CaseId TS-CONT-0076; subcase TS-CONT-0076-SC001-B; role Act. Double each foreach reference, return the raw sum, and expose Values. Inputs: TArray<int32>&inout Values (inout). Raw return: int32; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[1,2,3,4,5]`; raw return `30`; writebacks `Values=[2,4,6,8,10]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0076-SC001-C` → `global::void TraverseIntsWithIterator(const TArray<int32>&in Values, int32&out Sum, int32&out Count)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Traverse with the explicit const iterator and publish raw sum/count.
  - Comment: `// CaseId TS-CONT-0076; subcase TS-CONT-0076-SC001-C; role Act. Traverse with the explicit const iterator and publish raw sum/count. Inputs: const TArray<int32>&in Values (in), int32&out Sum (out), int32&out Count (out). Raw return: void; writebacks: Sum, Count. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[2,4,6,8,10]`; raw return `void`; writebacks `Sum=30; Count=5`; exception `none`.
  - Vector 2: inputs `Values=[]`; raw return `void`; writebacks `Sum=0; Count=0`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0077 — `TestSource/Containers/TArray/Test_TArrayFString.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayFString :: block 1 :: lines 468-500 :: sha256=fa3ae40b237b3e775488511436979af3129ba61ddfc130ceff259ac7bb436896`.

#### Current `ACoverageTArrayStringActor::BeginPlay` — `void BeginPlay()` (line 17)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0077-SC001-A` → `global::void SortStrings(TArray<FString>&inout Values, bool bDescendingOrder)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Sort strings and expose exact order.
  - Comment: `// CaseId TS-CONT-0077; subcase TS-CONT-0077-SC001-A; role Act. Sort strings and expose exact order. Inputs: TArray<FString>&inout Values (inout), bool bDescendingOrder (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=['Hello','World','AngelScript','Test']; false`; raw return `void`; writebacks `ascending lexical order`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0077-SC001-B` → `global::int32 FindFirstStringIndex(const TArray<FString>&in Values, const FString&in Value)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw FindIndex for a string.
  - Comment: `// CaseId TS-CONT-0077; subcase TS-CONT-0077-SC001-B; role Read. Return raw FindIndex for a string. Inputs: const TArray<FString>&in Values (in), const FString&in Value (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `sorted values; Value='Hello'`; raw return `1`; writebacks `none`; exception `none`.
  - Vector 2: inputs `values; Value='Missing'`; raw return `-1`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0077-SC001-C` → `global::void InsertStringAt(TArray<FString>&inout Values, const FString&in Value, int32 Index)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Insert a string at the requested index.
  - Comment: `// CaseId TS-CONT-0077; subcase TS-CONT-0077-SC001-C; role Act. Insert a string at the requested index. Inputs: TArray<FString>&inout Values (inout), const FString&in Value (in), int32 Index (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `sorted values; Value='AAA'; Index=0`; raw return `void`; writebacks `Values starts with 'AAA'`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0078 — `TestSource/Containers/TArray/Test_TArrayFVector.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayFVector :: block 1 :: lines 550-571 :: sha256=fee460f32e74f20b7cbe14bf73e8bbf4c3e038f594a96bddfecd7e5b297f5ae0`.

#### Current `ACoverageTArrayVectorActor::BeginPlay` — `void BeginPlay()` (line 11)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0078-SC001-A` → `global::void InsertVectorAt(TArray<FVector>&inout Values, FVector Value, int32 Index)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Insert a vector at Index and expose exact ordered writeback.
  - Comment: `// CaseId TS-CONT-0078; subcase TS-CONT-0078-SC001-A; role Act. Insert a vector at Index and expose exact ordered writeback. Inputs: TArray<FVector>&inout Values (inout), FVector Value (in), int32 Index (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[X,Y,Z]; Value=(.5,.5,0); Index=1`; raw return `void`; writebacks `[X,(.5,.5,0),Y,Z]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0078-SC001-B` → `global::void RemoveVectorAt(TArray<FVector>&inout Values, int32 Index)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Remove the selected vector while preserving order.
  - Comment: `// CaseId TS-CONT-0078; subcase TS-CONT-0078-SC001-B; role Act. Remove the selected vector while preserving order. Inputs: TArray<FVector>&inout Values (inout), int32 Index (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[X,(.5,.5,0),Y,Z]; Index=3`; raw return `void`; writebacks `[X,(.5,.5,0),Y]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0073 — `TestSource/Containers/TArray/Test_TArrayInsertAndRemoveAt.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayInsertAndRemoveAt :: block 1 :: lines 135-166 :: sha256=e7b9f3836c89f4a5f9433aedfcfedcb1b7bb0348eb1420fb4fc93e5c3c238ecc`.

#### Current `ACoverageTArrayInsertActor::BeginPlay` — `void BeginPlay()` (line 11)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0073-SC001-A` → `global::void InsertIntAt(TArray<int32>&inout Values, int32 Value, int32 Index)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Insert Value at Index and expose ordered writeback.
  - Comment: `// CaseId TS-CONT-0073; subcase TS-CONT-0073-SC001-A; role Act. Insert Value at Index and expose ordered writeback. Inputs: TArray<int32>&inout Values (inout), int32 Value (in), int32 Index (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[10,20,30]; Value=15; Index=1`; raw return `void`; writebacks `[10,15,20,30]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0073-SC001-B` → `global::void RemoveIntAt(TArray<int32>&inout Values, int32 Index)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Remove the indexed element while preserving remaining order.
  - Comment: `// CaseId TS-CONT-0073; subcase TS-CONT-0073-SC001-B; role Act. Remove the indexed element while preserving remaining order. Inputs: TArray<int32>&inout Values (inout), int32 Index (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[5,10,15,20,30,35]; Index=2`; raw return `void`; writebacks `[5,10,20,30,35]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0080 — `TestSource/Containers/TArray/Test_TArrayNestedContainers_01.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayNestedContainers :: block 1 :: lines 695-702 :: sha256=80374017733faa6ff2a4364a0e5cf6a93fc6cc5ae5b888943831b679ef235d69`.

Source-level contract (no callable): `TArray<TArray<int32>> Matrix` must fail compilation with a diagnostic containing `Containers cannot be nested in other containers`. Execution status is `compile-diagnostic-only`.
Required adjacent source comment: `// CaseId TS-CONT-0080; source-level negative contract. The declaration TArray<TArray<int32>> Matrix must fail compilation with a diagnostic containing 'Containers cannot be nested in other containers'. This source is compile-only; the runner owns expected-diagnostic registration and failed-module cleanup.`

### TS-CONT-0081 — `TestSource/Containers/TArray/Test_TArrayNestedContainers_02.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayNestedContainers :: block 2 :: lines 706-713 :: sha256=1a0ce2a9a2502130be0d470f3b47e3023ecbff795f564cbc0b6d9aff822ff728`.

Source-level contract (no callable): `TArray<TArray<TArray<int32>>> Matrix` must fail compilation with a diagnostic containing `Containers cannot be nested in other containers`. Execution status is `compile-diagnostic-only`.
Required adjacent source comment: `// CaseId TS-CONT-0081; source-level negative contract. The declaration TArray<TArray<TArray<int32>>> Matrix must fail compilation with a diagnostic containing 'Containers cannot be nested in other containers'. This source is compile-only; the runner owns expected-diagnostic registration and failed-module cleanup.`

### TS-CONT-0082 — `TestSource/Containers/TArray/Test_TArrayNestedMapAndSetContainers_01.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayNestedMapAndSetContainers :: block 1 :: lines 729-736 :: sha256=001038783a371acd3734b10411b4743e2fc059641dba24d0ba5f3ef530353320`.

Source-level contract (no callable): `TArray<TMap<int32,FString>> Rows` must fail compilation with a diagnostic containing `Containers cannot be nested in other containers`. Execution status is `compile-diagnostic-only`.
Required adjacent source comment: `// CaseId TS-CONT-0082; source-level negative contract. The declaration TArray<TMap<int32,FString>> Rows must fail compilation with a diagnostic containing 'Containers cannot be nested in other containers'. This source is compile-only; the runner owns expected-diagnostic registration and failed-module cleanup.`

### TS-CONT-0083 — `TestSource/Containers/TArray/Test_TArrayNestedMapAndSetContainers_02.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayNestedMapAndSetContainers :: block 2 :: lines 740-747 :: sha256=a2cab5c64ae9b1c0b331f5d2aa286ad41bc8ab2ef81b3b713e6e56fe67e65f1d`.

Source-level contract (no callable): `TArray<TSet<int32>> Rows` must fail compilation with a diagnostic containing `Containers cannot be nested in other containers`. Execution status is `compile-diagnostic-only`.
Required adjacent source comment: `// CaseId TS-CONT-0083; source-level negative contract. The declaration TArray<TSet<int32>> Rows must fail compilation with a diagnostic containing 'Containers cannot be nested in other containers'. This source is compile-only; the runner owns expected-diagnostic registration and failed-module cleanup.`

### TS-CONT-0092 — `TestSource/Containers/TArray/Test_TArrayOutOfBoundsIndexAccess.as`

Batch: `B07-runtime-exceptions`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayOutOfBoundsIndexAccess :: block 1 :: lines 1507-1521 :: sha256=94513d3f83f8fffb26e4e82082ba4e939c430ae515445114792a21b9b7063fa3`.

Finding: `diagnostic-phase-mismatch: source compiles and fails at runtime, so it is not a compile-negative source`.

#### Current `global::ReadPastEnd` — `int ReadPastEnd()` (line 4)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0092-SC001` → `global::int32 ReadIntAt(const TArray<int32>&in Values, int32 Index)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the indexed raw value; an invalid index raises the exact exception.
  - Comment: `// CaseId TS-CONT-0092; subcase TS-CONT-0092-SC001; role Read. Return the indexed raw value; an invalid index raises the exact exception. Inputs: const TArray<int32>&in Values (in), int32 Index (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[10]; Index=0`; raw return `10`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[10]; Index=1`; raw return `void`; writebacks `none`; exception `exact: "Array index out of bounds."`.

#### Current `global::WritePastEnd` — `void WritePastEnd()` (line 11)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0092-SC002` → `global::void WriteIntAt(TArray<int32>&inout Values, int32 Index, int32 Replacement)`
  - Status: declaration `reviewed-exact`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Write through the indexed reference and expose Values; an invalid index raises the exact exception before mutation.
  - Comment: `// CaseId TS-CONT-0092; subcase TS-CONT-0092-SC002; role Act. Write through the indexed reference and expose Values; an invalid index raises the exact exception before mutation. Inputs: TArray<int32>&inout Values (inout), int32 Index (in), int32 Replacement (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[10]; Index=0; Replacement=20`; raw return `void`; writebacks `Values=[20]`; exception `none`.
  - Vector 2: inputs `Values=[10]; Index=1; Replacement=20`; raw return `void`; writebacks `Values=[10]`; exception `exact: "Array index out of bounds."`.

#### Current `global::Observe_InRangeBoundary` — `int Observe_InRangeBoundary()` (line 18)

Current findings: `missing-immediate-english-function-comment`, `legacy-or-generic-test-name`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0092-SC003` → `global::int32 ReadInRangeIntBoundary(const TArray<int32>&in Values, int32 Index)`
  - Status: declaration `candidate-source-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the valid boundary element directly.
  - Comment: `// CaseId TS-CONT-0092; subcase TS-CONT-0092-SC003; role Read. Return the valid boundary element directly. Inputs: const TArray<int32>&in Values (in), int32 Index (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[10]; Index=0`; raw return `10`; writebacks `none`; exception `none`.
  - Blocker: Current callable is a compound/self-check wrapper; replace its body with the proposed raw return/writeback behavior and move expected values into vectors.

### TS-CONT-0075 — `TestSource/Containers/TArray/Test_TArrayReserve.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayReserve :: block 1 :: lines 288-313 :: sha256=0aa0a79d59d493e96ee4eaaf60f5c3c2531bd27f1ca310d38ad15b6969d0f8f9`.

Finding: `capacity-oracle-missing: current source records values/Num but does not publish Max after Reserve`.

#### Current `ACoverageTArrayReserveActor::BeginPlay` — `void BeginPlay()` (line 14)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0075-SC001-A` → `global::int32 ReserveIntArray(TArray<int32>&inout Values, int32 ReservedSize)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Reserve capacity and return raw Max without changing Num or elements.
  - Comment: `// CaseId TS-CONT-0075; subcase TS-CONT-0075-SC001-A; role Act. Reserve capacity and return raw Max without changing Num or elements. Inputs: TArray<int32>&inout Values (inout), int32 ReservedSize (in). Raw return: int32; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; ReservedSize=100`; raw return `at least 100`; writebacks `Values=[]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0075-SC001-B` → `global::void AppendArithmeticIntRange(TArray<int32>&inout Values, int32 Start, int32 Count, int32 Step)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Append Count arithmetic values from explicit inputs.
  - Comment: `// CaseId TS-CONT-0075; subcase TS-CONT-0075-SC001-B; role Act. Append Count arithmetic values from explicit inputs. Inputs: TArray<int32>&inout Values (inout), int32 Start (in), int32 Count (in), int32 Step (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]; Start=0; Count=10; Step=10`; raw return `void`; writebacks `[0,10,20,30,40,50,60,70,80,90]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0087 — `TestSource/Containers/TArray/Test_TArraySetNumAndCapacity.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArraySetNumAndCapacity :: block 1 :: lines 1009-1070 :: sha256=6ed224b1d2f49df7557216cd826278c1ca20154886da255872b6bd6bc545a655`.

#### Current `ACoverageTArraySetNumActor::BeginPlay` — `void BeginPlay()` (line 20)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0087-SC001-A` → `global::void ResizeIntArray(TArray<int32>&inout Values, int32 NewNum)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Call SetNum and expose expanded defaults or ordered shrink state.
  - Comment: `// CaseId TS-CONT-0087; subcase TS-CONT-0087-SC001-A; role Act. Call SetNum and expose expanded defaults or ordered shrink state. Inputs: TArray<int32>&inout Values (inout), int32 NewNum (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[1,2,3]; NewNum=10`; raw return `void`; writebacks `Num=10; Values[9]=0`; exception `none`.
  - Vector 2: inputs `Values=[1,2,3]; NewNum=2`; raw return `void`; writebacks `[1,2]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0087-SC001-B` → `global::int32 ReadIntArrayValue(const TArray<int32>&in Values, int32 Index)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return a raw indexed value for zero-initialization checks.
  - Comment: `// CaseId TS-CONT-0087; subcase TS-CONT-0087-SC001-B; role Read. Return a raw indexed value for zero-initialization checks. Inputs: const TArray<int32>&in Values (in), int32 Index (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values after SetNum(10); Index=9`; raw return `0`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0087-SC001-C` → `global::void EmptyIntArray(TArray<int32>&inout Values, int32 ReservedSize)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Call Empty with explicit reserve and expose zero Num.
  - Comment: `// CaseId TS-CONT-0087; subcase TS-CONT-0087-SC001-C; role Act. Call Empty with explicit reserve and expose zero Num. Inputs: TArray<int32>&inout Values (inout), int32 ReservedSize (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=0..99; ReservedSize=0`; raw return `void`; writebacks `Values=[]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0087-SC001-D` → `global::void ResetIntArray(TArray<int32>&inout Values, int32 ReservedSize)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Call Reset with explicit reserve and expose zero Num.
  - Comment: `// CaseId TS-CONT-0087; subcase TS-CONT-0087-SC001-D; role Act. Call Reset with explicit reserve and expose zero Num. Inputs: TArray<int32>&inout Values (inout), int32 ReservedSize (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[1]; ReservedSize=0`; raw return `void`; writebacks `Values=[]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0072 — `TestSource/Containers/TArray/Test_TArraySortAndReverse.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArraySortAndReverse :: block 1 :: lines 71-90 :: sha256=da97324e266b578a56f98c059dcba8a94bdda0f2d9a9b2e4db18cac8fc20fc17`.

Finding: `misleading-case-title: source and binding exercise Sort only; Reverse is intentionally unsupported`.

#### Current `ACoverageTArraySortActor::BeginPlay` — `void BeginPlay()` (line 14)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0072-SC001-A` → `global::void SortIntArray(TArray<int32>&inout Values, bool bDescendingOrder)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Sort Values with the bound TArray Sort flag and expose the exact order.
  - Comment: `// CaseId TS-CONT-0072; subcase TS-CONT-0072-SC001-A; role Act. Sort Values with the bound TArray Sort flag and expose the exact order. Inputs: TArray<int32>&inout Values (inout), bool bDescendingOrder (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[5,2,8,1,9]; bDescendingOrder=false`; raw return `void`; writebacks `Values=[1,2,5,8,9]`; exception `none`.
  - Vector 2: inputs `Values=[]; bDescendingOrder=true`; raw return `void`; writebacks `Values=[]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0072-SC001-B` → `global::int32 ReadIntArrayCount(const TArray<int32>&in Values)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return the raw count before or after sorting.
  - Comment: `// CaseId TS-CONT-0072; subcase TS-CONT-0072-SC001-B; role Read. Return the raw count before or after sorting. Inputs: const TArray<int32>&in Values (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[]`; raw return `0`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Values=[1,2,5,8,9]`; raw return `5`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0088 — `TestSource/Containers/TArray/Test_TArraySwapElements.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArraySwapElements :: block 1 :: lines 1114-1169 :: sha256=1fd6519550e206b08b5cd3e2526e735a4b23b892cf281fab11e5786496bfb877`.

#### Current `ACoverageTArraySwapActor::BeginPlay` — `void BeginPlay()` (line 14)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0088-SC001-A` → `global::void SwapIntElements(TArray<int32>&inout Values, int32 FirstIndex, int32 SecondIndex)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Swap exact integer positions and expose order.
  - Comment: `// CaseId TS-CONT-0088; subcase TS-CONT-0088-SC001-A; role Act. Swap exact integer positions and expose order. Inputs: TArray<int32>&inout Values (inout), int32 FirstIndex (in), int32 SecondIndex (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[10,20,30,40,50]; FirstIndex=0; SecondIndex=4`; raw return `void`; writebacks `[50,20,30,40,10]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0088-SC001-B` → `global::void SwapStringElements(TArray<FString>&inout Values, int32 FirstIndex, int32 SecondIndex)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Swap exact string positions and expose order.
  - Comment: `// CaseId TS-CONT-0088; subcase TS-CONT-0088-SC001-B; role Act. Swap exact string positions and expose order. Inputs: TArray<FString>&inout Values (inout), int32 FirstIndex (in), int32 SecondIndex (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=['First','Second','Third']; 0;2`; raw return `void`; writebacks `['Third','Second','First']`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0095 — `TestSource/Containers/TArray/Test_TArrayUnsupportedAlgorithms.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayUnsupportedAlgorithms :: block 1 :: lines 1868-1889 :: sha256=eaf8c2cac354784f821147d128a824d84e90b05b5c4c1c80d026d670c47d3edc`.

#### Current `ACoverageTArrayUnsupportedAlgorithmsActor::BeginPlay` — `void BeginPlay()` (line 8)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0095-SC001-A` → `global::void TriggerUnsupportedStableSort(TArray<int32>&inout Values)`
  - Status: declaration `reviewed-diagnostic`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Call the unsupported StableSort algorithm.
  - Comment: `// CaseId TS-CONT-0095; subcase TS-CONT-0095-SC001-A; role NegativeTrigger. Call the unsupported StableSort algorithm. Inputs: TArray<int32>&inout Values (inout). Raw return: void; writebacks: Values. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `contains: "No matching signatures to 'TArray::StableSort()'"`.
- `TS-CONT-0095-SC001-B` → `global::void TriggerUnsupportedFilterByPredicate(const TArray<int32>&in Values, int32 PredicatePlaceholder)`
  - Status: declaration `reviewed-diagnostic`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Call the unsupported FilterByPredicate algorithm.
  - Comment: `// CaseId TS-CONT-0095; subcase TS-CONT-0095-SC001-B; role NegativeTrigger. Call the unsupported FilterByPredicate algorithm. Inputs: const TArray<int32>&in Values (in), int32 PredicatePlaceholder (in). Raw return: void; writebacks: none. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `contains: "No matching signatures to 'TArray::FilterByPredicate(const int)'"`.
- `TS-CONT-0095-SC001-C` → `global::void TriggerUnsupportedFindByKey(const TArray<int32>&in Values, int32 Key)`
  - Status: declaration `reviewed-diagnostic`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Call the unsupported FindByKey algorithm.
  - Comment: `// CaseId TS-CONT-0095; subcase TS-CONT-0095-SC001-C; role NegativeTrigger. Call the unsupported FindByKey algorithm. Inputs: const TArray<int32>&in Values (in), int32 Key (in). Raw return: void; writebacks: none. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `contains: "No matching signatures to 'TArray::FindByKey(const int)'"`.
- `TS-CONT-0095-SC001-D` → `global::void TriggerUnsupportedFindByPredicate(const TArray<int32>&in Values, int32 PredicatePlaceholder)`
  - Status: declaration `reviewed-diagnostic`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Call the unsupported FindByPredicate algorithm.
  - Comment: `// CaseId TS-CONT-0095; subcase TS-CONT-0095-SC001-D; role NegativeTrigger. Call the unsupported FindByPredicate algorithm. Inputs: const TArray<int32>&in Values (in), int32 PredicatePlaceholder (in). Raw return: void; writebacks: none. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `contains: "No matching signatures to 'TArray::FindByPredicate(const int)'"`.
- `TS-CONT-0095-SC001-E` → `global::void TriggerUnsupportedHeapify(TArray<int32>&inout Values)`
  - Status: declaration `reviewed-diagnostic`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Call the unsupported Heapify algorithm.
  - Comment: `// CaseId TS-CONT-0095; subcase TS-CONT-0095-SC001-E; role NegativeTrigger. Call the unsupported Heapify algorithm. Inputs: TArray<int32>&inout Values (inout). Raw return: void; writebacks: Values. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `contains: "No matching signatures to 'TArray::Heapify()'"`.
- `TS-CONT-0095-SC001-F` → `global::void TriggerUnsupportedHeapPop(TArray<int32>&inout Values)`
  - Status: declaration `reviewed-diagnostic`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Call the unsupported HeapPop algorithm.
  - Comment: `// CaseId TS-CONT-0095; subcase TS-CONT-0095-SC001-F; role NegativeTrigger. Call the unsupported HeapPop algorithm. Inputs: TArray<int32>&inout Values (inout). Raw return: void; writebacks: Values. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `contains: "No matching signatures to 'TArray::HeapPop()'"`.
- `TS-CONT-0095-SC001-G` → `global::void TriggerUnsupportedHeapPush(TArray<int32>&inout Values, int32 Value)`
  - Status: declaration `reviewed-diagnostic`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Call the unsupported HeapPush algorithm.
  - Comment: `// CaseId TS-CONT-0095; subcase TS-CONT-0095-SC001-G; role NegativeTrigger. Call the unsupported HeapPush algorithm. Inputs: TArray<int32>&inout Values (inout), int32 Value (in). Raw return: void; writebacks: Values. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `contains: "No matching signatures to 'TArray::HeapPush(const int)'"`.
- `TS-CONT-0095-SC001-H` → `global::void TriggerUnsupportedLowerBound(const TArray<int32>&in Values, int32 Value)`
  - Status: declaration `reviewed-diagnostic`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Call the unsupported LowerBound algorithm.
  - Comment: `// CaseId TS-CONT-0095; subcase TS-CONT-0095-SC001-H; role NegativeTrigger. Call the unsupported LowerBound algorithm. Inputs: const TArray<int32>&in Values (in), int32 Value (in). Raw return: void; writebacks: none. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `contains: "No matching signatures to 'TArray::LowerBound(const int)'"`.
- `TS-CONT-0095-SC001-I` → `global::void TriggerUnsupportedUpperBound(const TArray<int32>&in Values, int32 Value)`
  - Status: declaration `reviewed-diagnostic`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Call the unsupported UpperBound algorithm.
  - Comment: `// CaseId TS-CONT-0095; subcase TS-CONT-0095-SC001-I; role NegativeTrigger. Call the unsupported UpperBound algorithm. Inputs: const TArray<int32>&in Values (in), int32 Value (in). Raw return: void; writebacks: none. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `contains: "No matching signatures to 'TArray::UpperBound(const int)'"`.

### TS-CONT-0084 — `TestSource/Containers/TArray/Test_TArrayUnsupportedApiAliases.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayUnsupportedApiAliases :: block 1 :: lines 766-782 :: sha256=1b0a3919cb28f6446f70cfb289f8b30df5148b71b2125fffbc811c1d744330bf`.

#### Current `ACoverageTArrayUnsupportedApiActor::BeginPlay` — `void BeginPlay()` (line 8)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`.

- `TS-CONT-0084-SC001-A` → `global::void TriggerUnsupportedFindAlias(const TArray<int32>&in Values, int32 Value)`
  - Status: declaration `reviewed-diagnostic`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Call the unsupported Find alias.
  - Comment: `// CaseId TS-CONT-0084; subcase TS-CONT-0084-SC001-A; role NegativeTrigger. Call the unsupported Find alias. Inputs: const TArray<int32>&in Values (in), int32 Value (in). Raw return: void; writebacks: none. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `contains: "No matching signatures to 'TArray::Find(const int)'"`.
- `TS-CONT-0084-SC001-B` → `global::void TriggerUnsupportedFindLastAlias(const TArray<int32>&in Values, int32 Value)`
  - Status: declaration `reviewed-diagnostic`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Call the unsupported FindLast alias.
  - Comment: `// CaseId TS-CONT-0084; subcase TS-CONT-0084-SC001-B; role NegativeTrigger. Call the unsupported FindLast alias. Inputs: const TArray<int32>&in Values (in), int32 Value (in). Raw return: void; writebacks: none. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `contains: "No matching signatures to 'TArray::FindLast(const int)'"`.
- `TS-CONT-0084-SC001-C` → `global::void TriggerUnsupportedReverseAlias(TArray<int32>&inout Values)`
  - Status: declaration `reviewed-diagnostic`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Call the unsupported Reverse alias.
  - Comment: `// CaseId TS-CONT-0084; subcase TS-CONT-0084-SC001-C; role NegativeTrigger. Call the unsupported Reverse alias. Inputs: TArray<int32>&inout Values (inout). Raw return: void; writebacks: Values. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `contains: "No matching signatures to 'TArray::Reverse()'"`.
- `TS-CONT-0084-SC001-D` → `global::void TriggerUnsupportedRemoveAllAlias(TArray<int32>&inout Values, int32 Value)`
  - Status: declaration `reviewed-diagnostic`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `NegativeTrigger`; fixture `compile-diagnostic`.
  - Behavior: Call the unsupported RemoveAll alias.
  - Comment: `// CaseId TS-CONT-0084; subcase TS-CONT-0084-SC001-D; role NegativeTrigger. Call the unsupported RemoveAll alias. Inputs: TArray<int32>&inout Values (inout), int32 Value (in). Raw return: void; writebacks: Values. This is a compile-time negative contract; register the diagnostic before compilation and do not claim execution coverage. Ownership: Runner discards the failed module and resets expected diagnostics.`
  - Vector 1: inputs `compile-time trigger`; raw return `void`; writebacks `none`; exception `contains: "No matching signatures to 'TArray::RemoveAll(const int)'"`.

### TS-CONT-0079 — `TestSource/Containers/TArray/Test_TArrayUObjectReferences.as`

Batch: `B06-world-and-uobject-identity`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayUObjectReferences :: block 1 :: lines 623-662 :: sha256=371b875478bd8e6347f2172e184af3b646802db609bef785b65c6cac5c476268`.

#### Current `ACoverageTArrayActorRefsActor::BeginPlay` — `void BeginPlay()` (line 17)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0079-SC001-A` → `global::void BuildActorReferenceArray(AActor Self, AActor First, AActor Second, TArray<AActor>&out References)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `runner-owned world/UObject`.
  - Behavior: Publish runner-owned actor references in explicit order; do not spawn inside the source.
  - Comment: `// CaseId TS-CONT-0079; subcase TS-CONT-0079-SC001-A; role Act. Publish runner-owned actor references in explicit order; do not spawn inside the source. Inputs: AActor Self (in), AActor First (in), AActor Second (in), TArray<AActor>&out References (out). Raw return: void; writebacks: References. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `three live distinct actors`; raw return `void`; writebacks `References=[Self,First,Second]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0079-SC001-B` → `global::int32 CountActorReferences(const TArray<AActor>&in References)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `runner-owned world/UObject`.
  - Behavior: Return the raw reference count.
  - Comment: `// CaseId TS-CONT-0079; subcase TS-CONT-0079-SC001-B; role Read. Return the raw reference count. Inputs: const TArray<AActor>&in References (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `References=three actors`; raw return `3`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0079-SC001-C` → `global::bool ContainsActorReference(const TArray<AActor>&in References, AActor Candidate)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `runner-owned world/UObject`.
  - Behavior: Return raw Contains identity semantics.
  - Comment: `// CaseId TS-CONT-0079; subcase TS-CONT-0079-SC001-C; role Read. Return raw Contains identity semantics. Inputs: const TArray<AActor>&in References (in), AActor Candidate (in). Raw return: bool; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `References=[Self,A,B]; Candidate=Self`; raw return `true`; writebacks `none`; exception `none`.
  - Vector 2: inputs `Candidate=unlisted actor`; raw return `false`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0079-SC001-D` → `global::int32 FindActorReferenceIndex(const TArray<AActor>&in References, AActor Candidate)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `runner-owned world/UObject`.
  - Behavior: Return raw FindIndex identity semantics.
  - Comment: `// CaseId TS-CONT-0079; subcase TS-CONT-0079-SC001-D; role Read. Return raw FindIndex identity semantics. Inputs: const TArray<AActor>&in References (in), AActor Candidate (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `References=[Self,A,B]; Candidate=Self`; raw return `0`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0090 — `TestSource/Containers/TArray/Test_TArrayWithFName.as`

Batch: `B05-advanced-array-scenarios`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp :: FAngelscriptCoverageTArrayAdvancedTest :: TArrayWithFName :: block 1 :: lines 1328-1371 :: sha256=f04d26189791abaaa59334f5eca2a8fba1c8ba4cafbf0c5579354215aa36ec87`.

#### Current `ACoverageTArrayFNameActor::BeginPlay` — `void BeginPlay()` (line 17)

Current findings: `missing-immediate-english-function-comment`, `hard-coded-zero-argument-operation-inputs`, `incidental-beginplay-harness`, `oracle-collapsed-into-actor-member-state`.

- `TS-CONT-0090-SC001-A` → `global::void AddName(TArray<FName>&inout Values, FName Value)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Append one FName and expose the receiver.
  - Comment: `// CaseId TS-CONT-0090; subcase TS-CONT-0090-SC001-A; role Act. Append one FName and expose the receiver. Inputs: TArray<FName>&inout Values (inout), FName Value (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[Player]; Value=Enemy`; raw return `void`; writebacks `[Player,Enemy]`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0090-SC001-B` → `global::int32 FindFirstNameIndex(const TArray<FName>&in Values, FName Value)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Read`; fixture `pure-value`.
  - Behavior: Return raw first FindIndex for duplicate names.
  - Comment: `// CaseId TS-CONT-0090; subcase TS-CONT-0090-SC001-B; role Read. Return raw first FindIndex for duplicate names. Inputs: const TArray<FName>&in Values (in), FName Value (in). Raw return: int32; writebacks: none. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `Values=[Player,Enemy,Weapon,Item,Enemy]; Value=Enemy`; raw return `1`; writebacks `none`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.
- `TS-CONT-0090-SC001-C` → `global::void SortNames(TArray<FName>&inout Values, bool bDescendingOrder)`
  - Status: declaration `candidate-runner-refactor-required`; implementation `planned-not-materialized`; execution `not-run; C++ evidence is reference-only for this proposed signature`; role `Act`; fixture `pure-value`.
  - Behavior: Sort FNames and expose exact count/order.
  - Comment: `// CaseId TS-CONT-0090; subcase TS-CONT-0090-SC001-C; role Act. Sort FNames and expose exact count/order. Inputs: TArray<FName>&inout Values (inout), bool bDescendingOrder (in). Raw return: void; writebacks: Values. Nominal, empty, and boundary vectors are owned by the contract runner. Ownership: Source owns locals; runner releases the compiled module.`
  - Vector 1: inputs `five names; false`; raw return `void`; writebacks `five names in ascending order`; exception `none`.
  - Blocker: Existing C++ reference spawns an Actor and observes BeginPlay UPROPERTY state; the future runner must invoke the explicit callable(s) and compare typed returns/writebacks.

### TS-CONT-0106 — `TestSource/Containers/TArray/Test_TMapWithArrayValues.as`

Batch: `B01-compile-diagnostics`. C++ evidence: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTMapAdvancedTests.cpp :: FAngelscriptCoverageTMapAdvancedTest :: TMapWithArrayValues :: block 1 :: lines 888-895 :: sha256=ad3ecc7a37b3392138fe8d7159dfa616b722600f0c606a087256937b31b1f69e`.

Source-level contract (no callable): `TMap<int32,TArray<int32>> Groups` must fail compilation with a diagnostic containing `Containers cannot be nested in other containers`. Execution status is `compile-diagnostic-only`.
Required adjacent source comment: `// CaseId TS-CONT-0106; source-level negative contract. The declaration TMap<int32,TArray<int32>> Groups must fail compilation with a diagnostic containing 'Containers cannot be nested in other containers'. This source is compile-only; the runner owns expected-diagnostic registration and failed-module cleanup.`

## Validation

- 58/58 source coverage complete: `True`.
- 98/98 current callable coverage complete: `True`.
- Duplicate proposed owner-qualified identities: `0`.
- Duplicate subcase IDs: `0`.
- Forbidden legacy proposed declarations: `0`.
- Proposed `Expected*`/`bExpect*` parameters: `0`.
- Proposed references without explicit `&in`/`&out`/`&inout`: `0`.
- Every proposal has an immediate English comment: `True`.
- Every proposal has at least one typed vector: `True`.
- Every zero-argument proposal has a reason: `True`.
- Every source-level diagnostic has an adjacent English source comment: `True`.

The JSON companion is authoritative for source/body hashes, owner-qualified current identity, typed parameters, raw result, writebacks, exception contract, fixtures, cleanup, dependencies, blockers, exact comments, vectors, and deterministic batches.
