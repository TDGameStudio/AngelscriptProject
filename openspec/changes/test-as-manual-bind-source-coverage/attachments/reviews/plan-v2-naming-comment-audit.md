# Plan V2 naming and per-function comment audit

## Scope and baseline

This is a read-only quality audit of the normalized Contract V2 planning ledger. It evaluates only:

- `attachments/contracts/normalized/*.jsonl`
- proposal semantic names and declarations
- immediate per-function comment text
- `required-name` justification
- retirement-to-replacement traceability
- false-ready status caused by the preceding issues

It does not accept or implement any `TestSource`, runner, plugin, or product-code change.

The audited baseline is the stable `plan-v2` ledger generated on 2026-08-24:

- normalized rows: `12,624`
- proposal rows: `12,375`
- source-only rows: `249`
- current `review-ready` rows: `2,285`
- current `blocked` rows: `10,339`
- normalized manifest file SHA-256: `6DADC21FFC402B13163A14998A4A7B53FA344D5A3313694DFF8AE12795F259F4`
- manifest `semanticPlanSha256`: `7f0636643e3b66c1061bb63081252555261dac44ab63d8190b7e7a5cdb91c23a`
- manifest `manifestContentSha256`: `7b92e5cc8c2b17cb6f70eeb55f546c2ad5360c69407e7808cffa1f687354ca66`

All counts below refer to that exact baseline. Regeneration changes row hashes and requires re-running this audit.

## Audit method

The audit parsed every JSONL row and conservatively classified the following mechanically observable patterns:

1. A per-function comment is a scaffold comment when its exact text contains at least one of:
   - ` covers `
   - ` surface owned by `
   - `Boundary and expected values live in typed vectors`
2. A declaration or comment retains a generic observation channel when it contains `ObservedCondition`.
3. A semantic name has a numeric suffix when it matches `\d+$`.
4. A numeric suffix is conservatively classified as a test ordinal when its name matches one of:
   - `ForSubcase\d+`
   - `Run...\d+`
   - `Compile...\d+`
   - numbered handler/listener/RPC forms such as `Handler1`, `Listener2`, `ServerAction1`, or `ClientNotify2`
5. A hard rename is still generic when its final name is only `Get`, `Set`, `Create`, `Execute`, `Test`, `Handle`, or another equivalent bare operation verb.
6. A required name is incomplete when `requiredNameReason` is empty.
7. A required name is internally inconsistent when its semantic label is not a declaration name in the current source identity.
8. A retirement mapping is incomplete when its body plan contains neither a replacement task ID nor a replacement plan-row ID.
9. A proposed `void` return is contradictory when its exact proposed declaration visibly returns `bool`, an integer, a float, a string, or an object/value type.
10. A Gameplay boolean writeback violates the established Unreal/AngelScript spelling rule when it begins with uppercase `B` followed by an uppercase letter.

These searches are intentionally conservative. For example, all `440` trailing numeric names are reported, but only `299` are classified as definite test ordinals; type-width APIs such as `ReadInt64` are not automatically rejected as ordinals.

## Overall findings

### P0 — false-ready findings that must be fixed before user acceptance review

1. `12,161 / 12,375` proposal comments (`98.27%`) still match a scaffold-comment pattern.
2. Only `214` proposal comments avoid all three scaffold patterns, and `213` of those belong to the two TArray ledgers. The concrete TArray comment style has therefore not been propagated to the other domains.
3. `2,118` scaffold-comment rows remain `review-ready`, which is `92.69%` of all `2,285` review-ready rows.
4. `1,670` review-ready rows contain a vector whose `rawExpectations` is empty. This is `73.09%` of all review-ready rows and prevents a precise behavior/output comment.
5. All `48` `retire-with-replacement` rows lack explicit replacement task/plan-row IDs; `45` remain review-ready.
6. Six World rows declare a `bool` return while their normalized return field and comment say `void`; all six remain review-ready.
7. `440` semantic names end in digits. The conservative ordinal recognizer identifies `299`; `16` definite ordinal names remain review-ready.
8. `964` comments mention generic `ObservedCondition` outputs. Thirteen such comments remain review-ready because they belong to retirement rows.
9. Gameplay contains `101` uppercase `B*` boolean writebacks across `43` proposal rows. All `43` rows remain review-ready.
10. Three anonymous timer-lambda labels remain review-ready as `LambdaAtLine22`, `LambdaAtLine33`, and `LambdaAtLine38`; source line is not a stable semantic identity.

### P1 — correctly blocked, but not yet a predesigned final contract

1. `949` proposed callable declarations contain generic `FirstObservedCondition`, `SecondObservedCondition`, or equivalent outputs. They represent `2,824` generic writeback names across `964` rows when retirement planning rows are included. The `949` actual callable rows are now blocked, which is correct.
2. `14` Bindings hard renames still end in bare semantic names such as `Get`, `Set`, `Create`, `Execute`, `Handle`, or `Test`. All are blocked.
3. `14` Bindings rows use `required-name` without a reason. All are blocked, but each needs a blocker that specifically requests name-preservation evidence.
4. `62` required-name semantic labels are not declaration names in their current identity. Fifty-nine are blocked; the remaining three are the source-line lambda labels described above.
5. `283 / 299` definite test-ordinal names are already blocked. They still need semantic replacements before their source tasks can be accepted.

## Exact counts by normalized domain

In the table:

- `Scaffold comments (ready)` gives all matching comments and, in parentheses, the subset still marked review-ready.
- `Observed declaration/comment` separates callable declarations from all comments, including retirement comments.
- `Numeric suffix/definite ordinal` separates the broad numeric scan from the conservative ordinal scan.
- `Required missing/not-current` separates missing reasons from labels absent from current declarations.
- `Retire no map` counts retirement rows without a replacement task or plan-row ID.

| Domain | Proposal rows | Scaffold comments (ready) | Observed declaration/comment | Numeric suffix/definite ordinal | Required missing/not-current | Retire no map | Bool/void conflict |
|---|---:|---:|---:|---:|---:|---:|---:|
| Bindings | 2,782 | 2,782 (8) | 0 / 0 | 58 / 0 | 14 / 0 | 0 | 0 |
| Bindings/TArray | 68 | 0 (0) | 0 / 0 | 0 / 0 | 0 / 0 | 0 | 0 |
| Containers | 383 | 382 (18) | 0 / 0 | 0 / 0 | 0 / 0 | 1 | 0 |
| Containers/TArray | 145 | 0 (0) | 0 / 0 | 0 / 0 | 0 / 0 | 0 | 0 |
| Debugger | 4 | 4 (0) | 0 / 0 | 0 / 0 | 0 / 0 | 0 | 0 |
| Definitions | 2,077 | 2,077 (15) | 360 / 362 | 46 / 20 | 0 / 34 | 15 | 0 |
| Feature | 1,955 | 1,955 (20) | 193 / 196 | 52 / 49 | 0 / 3 | 21 | 0 |
| Gameplay | 1,463 | 1,463 (1,461) | 0 / 0 | 14 / 9 | 0 / 3 | 0 | 0 |
| HotReload | 273 | 273 (0) | 0 / 0 | 0 / 0 | 0 / 0 | 0 | 0 |
| Language | 2,255 | 2,255 (10) | 396 / 406 | 256 / 214 | 0 / 22 | 11 | 0 |
| Optional | 382 | 382 (0) | 0 / 0 | 0 / 0 | 0 / 0 | 0 | 0 |
| TestFramework | 212 | 212 (211) | 0 / 0 | 7 / 0 | 0 / 0 | 0 | 0 |
| World | 376 | 376 (375) | 0 / 0 | 7 / 7 | 0 / 0 | 0 | 6 |
| **Total** | **12,375** | **12,161 (2,118)** | **949 / 964** | **440 / 299** | **14 / 62** | **48** | **6** |

Gameplay additionally has `101` uppercase-`B` boolean writebacks across `43` review-ready proposal rows.

## Concrete corrections supported by existing normalized evidence

These rows already contain enough normalized evidence to improve their name, signature, or comment direction. Independent vector/runtime blockers may remain where noted.

### Input-event raw return helpers

#### `W05.B01.F0101.C0001`

- Source: `TestSource/Bindings/InputEvents/Test_NamespaceAndGlobalFunctions_01.as`
- Current name: `Observe_Handled_Nominal`
- Planned name: `Handled`
- Recommended declaration:

```angelscript
FEventReply MakeHandledEventReply()
```

- Recommended comment core:

```cpp
// Return the raw handled reply produced by FEventReply::Handled; the runner verifies its handled state.
```

#### `W05.B01.F0101.C0002`

- Source: `TestSource/Bindings/InputEvents/Test_NamespaceAndGlobalFunctions_01.as`
- Current name: `Observe_Unhandled_Nominal`
- Planned name: `Unhandled`
- Recommended declaration:

```angelscript
FEventReply MakeUnhandledEventReply()
```

- The comment must state that the function returns the raw result of `FEventReply::Unhandled`, not merely that it “covers Unhandled.”

### World-collision value surfaces

#### `W05.B05.F0211.C0001`

- Source: `TestSource/Bindings/WorldCollision/Test_Behavior_01.as`
- Current name: `Observe_Handle_Nominal`
- Planned name: `Handle`
- Recommended declaration:

```angelscript
FTraceHandle MakeDefaultTraceHandle()
```

- The comment should state that this exposes the default-constructed invalid handle; zero/invalid expectations belong to the runner vector.

#### `W05.B05.F0215.C0001`

- Source: `TestSource/Bindings/WorldCollision/Test_NamespaceAndGlobalFunctions_01.as`
- Current name: `Observe_Surface002_Nominal`
- Planned name: `Test`
- Recommended declaration:

```angelscript
EAsyncTraceType ReadAsyncTraceTestEnumerator()
```

- The comment should identify the exact `EAsyncTraceType::Test` raw enum channel.

### Compile-negative semantic names

#### `W09.B04.F0028.C0001`

- Source: `TestSource/Definitions/UFunction/Test_Params_Negative_01.as`
- Current name: `Foo`
- Planned name: `CompileParamsNegative01`
- Recommended declaration:

```angelscript
UFUNCTION()
void RejectUnknownUFunctionParameterType(FNonExistentType Param)
```

- Comment purpose: declare an unknown UFUNCTION parameter type and require the exact compile diagnostic.

#### `W09.B04.F0030.C0001`

- Source: `TestSource/Definitions/UFunction/Test_Params_Negative_03.as`
- Current declaration uses duplicate parameter name `X`.
- Planned name: `CompileParamsNegative03`
- Recommended declaration:

```angelscript
UFUNCTION()
void RejectDuplicateUFunctionParameterNames(int X, float X)
```

- Comment purpose: deliberately reuse `X`; the runner verifies the exact duplicate-parameter diagnostic.

#### `W09.B04.F0046.C0001`

- Source: `TestSource/Definitions/UFunction/Test_Specifiers_Negative_01.as`
- Current name: `Foo`
- Planned name: `CompileSpecifiersNegative01`
- Recommended declaration:

```angelscript
UFUNCTION(InvalidSpecifier)
void RejectUnknownUFunctionSpecifier()
```

#### `W09.B04.F0048.C0001`

- Source: `TestSource/Definitions/UFunction/Test_Specifiers_Negative_03.as`
- Current name: `Foo`
- Planned name: `CompileSpecifiersNegative03`
- Recommended declaration:

```angelscript
UFUNCTION(Server, Client)
void RejectCombinedServerAndClientSpecifiers()
```

### Raw observation channels instead of generic booleans

#### `W09.B01.F0001.C0003`

- Source: `TestSource/Definitions/Meta/Test_AddFileEmitsGameVirtualPathMetadata.as`
- Current name: `Observe_AddFile_RepeatCall`
- Planned declaration uses two generic `ObservedCondition` outputs.
- Existing evidence says `Entry() == 9` and repeated calls are stable.
- Recommended declaration:

```angelscript
int ReadAddFileEntryValue()
```

- The runner should invoke the function twice and compare both raw returns with `9`; the source does not need two boolean out parameters.

#### `W09.B01.F0007.C0003`

- Source: `TestSource/Definitions/Meta/Test_ComponentDestroyComponentPromoteChildrenAndK2Metadata.as`
- Current name: `Observe_DestroyPromote_DefaultsFalse`
- Planned declaration uses three generic `ObservedCondition` outputs.
- Existing evidence already names all three channels.
- Recommended declaration:

```angelscript
void ReadDestroyPromotionState(
    ACoverageComponentDestroyPromoteActor Actor,
    bool&out bDestroyReturned,
    bool&out bParentBeingDestroyedAfterCall,
    bool&out bChildReattachedToRoot)
```

- The comment must explain each out channel and state that the runner owns the real destruction path and World cleanup.

### RepNotify state readers and boolean spelling

#### `W12.B01.F0001.C0003`

- Source: `TestSource/Gameplay/Anim/Test_EventRepNotifyExecutesStateChange.as`
- Current name: `Observe_RepNotify_DefaultEmpty`
- Planned name: `ReadRepNotifyDefaultEmptyState`
- Recommended declaration:

```angelscript
void ReadRepNotifyInitialState(
    ACoverageEventRepNotifyActor Actor,
    int&out TrackedHealth,
    int&out RepNotifyCount,
    int&out LastReplicatedHealth,
    bool&out bRepNotifyExecuted)
```

- Recommended comment core:

```cpp
// Expose the four RepNotify state channels before any replicated health update; the runner expects 0, 0, 0, and false.
```

#### `W12.B01.F0001.C0004`

- Source: `TestSource/Gameplay/Anim/Test_EventRepNotifyExecutesStateChange.as`
- Current name: `Observe_RepNotify_Apply87`
- Planned name: `ReadRepNotifyApply87State`
- Move the value `87` into the vector and use:

```angelscript
void ReadRepNotifyStateAfterHealthUpdate(
    ACoverageEventRepNotifyActor Actor,
    int&out TrackedHealth,
    int&out RepNotifyCount,
    int&out LastReplicatedHealth,
    bool&out bRepNotifyExecuted)
```

- The comment must describe engine-dispatched state after a health update; the vector owns `87`, notification count, and expected state.

#### `W12.B01.F0006.C0002`

- Source: `TestSource/Gameplay/Debug/Test_ConditionalLogging.as`
- Planned out name: `BDebugMode`
- Recommended signature spelling:

```angelscript
void ReadConditionalLogDefaultsState(
    AConditionalLogTestActor Actor,
    bool&out bDebugMode,
    int&out LogLevel)
```

#### `W12.B01.F0227.C0003`

- Source: `TestSource/Gameplay/Timer/Test_TimerClearAndInvalidate.as`
- Planned out names use uppercase `B`.
- Recommended spellings:

```angelscript
bool&out bActiveBeforeClear
bool&out bActiveAfterClear
bool&out bValidBeforeClear
bool&out bValidAfterClear
```

- The same mechanical correction must update declaration, writeback metadata, body plan, comment, raw expectations, and row hash for all `101` affected Gameplay outputs.

### Soft reference and component raw returns

#### `W05.B05.F0178.C0010`

- Source: `TestSource/Bindings/TSoftObjectPtr/Test_Queries_01.as`
- Current name: `Observe_Get_Nominal`
- Planned name: `Get`
- Recommended declaration:

```angelscript
UObject ResolveSoftObjectWithoutLoading(
    const TSoftObjectPtr<UObject>&in SoftObject)
```

- Empty, loaded, and missing-path behavior should be separate vectors.

#### `W05.B05.F0181.C0006`

- Source: `TestSource/Bindings/UActorComponent/Test_MutationAndLifecycle_01.as`
- Current name: `Observe_Create_Nominal`
- Planned declaration: `bool Create(AActor Actor)`
- Candidate declaration:

```angelscript
USceneComponent CreateSceneComponentWithDefaultName(AActor Actor)
```

- The production component type must remain `signature-unresolved` until exact binding evidence confirms whether `USceneComponent` is the correct type; a synthesized `bCreated` return is not acceptable.

#### `W05.B05.F0182.C0009`

- Source: `TestSource/Bindings/UActorComponent/Test_Queries_01.as`
- Current name: `Observe_Get_Nominal`
- Planned name: `Get`
- Recommended declaration direction:

```angelscript
USceneComponent GetSceneComponentByDefaultName(AActor Actor)
```

- Named lookup must be a separate callable/vector instead of combining AnyName, Named, and NoneName results.

## Concrete rows that must remain evidence-blocked

The rows below require source, runner, binding, fixture, or lifecycle evidence before a final name/signature can be frozen. The plan must name the missing evidence rather than let an implementation agent invent the answer.

### Delegate and input dispatch

#### `W05.B01.F0024.C0009`

- Source: `TestSource/Bindings/Delegates/Test_MutationAndLifecycle_01.as`
- Current/planned: `Observe_Execute_Nominal -> Execute`
- Required blockers:
  - `semantic-name-unresolved`
  - `signature-unresolved`
  - `delegate-dispatch-role-unresolved`
- After evidence, split into behavior-specific rows such as `ExecuteBoundComputeDelegate` and the corresponding notify/broadcast operation. The current expected-result booleans must not remain source inputs.

#### `W05.B01.F0048.C0001`

- Source: `TestSource/Bindings/FInputBindingHandle/Test_MutationAndLifecycle_01.as`
- Current/planned: `Observe_Execute_Nominal -> Execute`
- Required resolution: split action-event and debug-key execution into distinct rows, such as `ExecuteActionEventBinding` and `ExecuteDebugKeyBinding`, and expose actual callback side effects. Zero handles do not prove dispatch.

#### `W10.B06.F0046.C0003` and `W10.B06.F0046.C0004`

- Source: `TestSource/Feature/Delegates/Test_DelegateRebinding.as`
- Current/planned names: `Handler1`, `Handler2`
- Required resolution: determine which callback represents the original binding and which represents the rebound binding, then use behavior names such as `HandleOriginalBinding` and `HandleReboundBinding` and update every FName binding site.

### Compound binding rows

#### `W05.B01.F0035.C0001`

- Source: `TestSource/Bindings/FCommandLine/Test_Queries_01.as`
- Current/planned: `Observe_Get_Nominal -> Get`
- Candidate name: `ReadCurrentCommandLine`
- Blocker: the current body combines append mutation, first read, and repeated-read stability. Separate environment mutation and invocation vectors before freezing the declaration.

#### `W05.B01.F0046.C0002`

- Source: `TestSource/Bindings/FInputActionValue/Test_Queries_01.as`
- Current/planned: `Observe_Get_Nominal -> Get`
- Candidate declaration:

```angelscript
bool ReadBooleanActionValue(const FInputActionValue&in Value)
```

- Blocker: Empty, One, and Zero must become exact input vectors rather than one compound comparison.

#### `W05.B04.F0009.C0001`

- Source: `TestSource/Bindings/TOptional/Test_MutationAndLifecycle_01.as`
- Current/planned: `Observe_Set_Nominal -> Set`
- Required split:

```angelscript
void SetIntOptionalValue(TOptional<int32>&inout Optional, int32 Value)
void SetNameOptionalValue(TOptional<FName>&inout Optional, FName Value)
```

- Exact before/after writebacks are still required.

#### `W05.B04.F0011.C0004`

- Source: `TestSource/Bindings/TOptional/Test_Queries_01.as`
- Current/planned: `Observe_Get_Nominal -> Get`
- Required split: separate `ReadIntOptionalOrDefault` from the string/name fallback behavior; do not keep two template instantiations in one raw return row.

#### `W05.B05.F0018.C0001`

- Source: `TestSource/Bindings/BlueprintType/Test_MutationAndLifecycle_01.as`
- Current/planned: `Observe_Set_Nominal -> Set`
- Candidate declaration:

```angelscript
void SetActorSubclass(
    TSubclassOf<AActor>&inout Class,
    UClass NewClass)
```

- Blocker: the current proposal declares a mutation target as `const &in` and has no writeback. Exact binding marshalling support must be proven.

#### `W05.B05.F0170.C0007`

- Source: `TestSource/Bindings/Subsystems/Test_Queries_01.as`
- Current/planned: `Observe_Get_Nominal -> Get`
- Required split:
  - `GetEngineSubsystem`
  - `GetWorldSubsystem`
  - `GetLocalPlayerSubsystemFromPlayer`
  - `GetLocalPlayerSubsystemFromController`
- Blocker: each row needs the exact native subsystem return type.

#### `W05.B05.F0179.C0002`

- Source: `TestSource/Bindings/TSoftObjectPtr/Test_Queries_02.as`
- Current/planned: `Observe_Get_Nominal -> bool Get(...)`
- Candidate declaration:

```angelscript
TSubclassOf<AActor> ResolveSoftClassWithoutLoading(
    const TSoftClassPtr<AActor>&in SoftClass)
```

- Blocker: confirm exact AngelScript return spelling and empty/loaded/missing behavior by binding evidence.

### World and component rows with ordinal names

#### `W11.B01.F0079.C0003`

- Source: `TestSource/World/Component/Test_DestroyComponentUnregistersRuntimeComponent.as`
- Current/planned: `Observe_DestroyComponent_CopyIndependence -> GetDestroyProbeForSubcase003`
- Problems:
  - unstable ordinal name
  - declaration returns `bool`
  - normalized return field/comment say `void`
  - two-object comparison wrapper instead of one raw probe channel
- Required resolution: determine the exact probe property type and expose one actor’s raw destroy probe; keep `signature-unresolved` until then.

#### `W11.B01.F0085.C0009`

- Source: `TestSource/World/Component/Test_GetComponent.as`
- Current/planned: `Observe_GetComponent_MissingAndWrongClassNull -> ReadGetComponentFixtureForSubcase009`
- Required split:
  - `GetComponentByMissingName`
  - `GetComponentByWrongClass`
- Return the raw component/null channel. Do not retain the bool wrapper or the `ForSubcase009` name.

#### `W12.B01.F0179.C0003`

- Source: `TestSource/Gameplay/Material/Test_ScriptCompilesDynamicMaterialAPI.as`
- Current/planned: `Observe_DynamicMaterial_NullMeshBoundary -> GetMaterialMeshForSubcase003`
- Candidate name: `GetDynamicMaterialMesh`
- Blocker: `primaryApis` and `rawExpectations` are empty, so the exact mesh/component return type is not yet proven.

### RPC and lambda semantic identities

#### `W12.B01.F0184.C0001` through `W12.B01.F0184.C0009`

- Source: `TestSource/Gameplay/Net/Test_MultipleRPCsInSingleClass.as`
- Affected names include:
  - `ServerAction1`, `ServerAction2`
  - `ClientNotify1`, `ClientNotify2`
  - `MulticastEvent1`, `MulticastEvent2`
  - `ServerValidated1`, `ServerValidated2`
- All eight numbered RPC rows remain review-ready and have empty raw expectations.
- Required blocker: `rpc-role-unresolved`.
- Each RPC must be renamed from its actual side effect and verified through real RPC/ProcessEvent routing, never by direct AngelScript invocation.

#### `W12.B01.F0236.C0002`, `W12.B01.F0236.C0003`, and `W12.B01.F0236.C0004`

- Source: `TestSource/Gameplay/Timer/Test_TimerLambdaCapture.as`
- Plan labels: `LambdaAtLine22`, `LambdaAtLine33`, `LambdaAtLine38`
- Required blocker: `lambda-role-unresolved`.
- Use a separate lexical label field or a behavior name after evidence identifies each lambda’s timer role. Source line must not be the semantic identity.

### Required-name evidence

#### `W05.B01.F0010.C0003`

- Source: `TestSource/Bindings/BlueprintEvent/Test_MutationAndLifecycle_01.as`
- Name: `OnMutation`
- Problem: `required-name` has no reason.
- Resolution: record the concrete delegate, Blueprint event, or FName dispatch consumer that fixes `OnMutation`; otherwise use ordinary semantic keep/rename disposition.

#### `W05.B01.F0065.C0001`

- Source: `TestSource/Bindings/FMemoryReader/Test_Behavior_01.as`
- Name: `MakeCursorProbeData`
- Problem: `required-name` has no external-name evidence.
- Resolution: use `semantic-keep` for a normal helper, or identify the exact C++/FName consumer before preserving required-name.

### Retirement-to-replacement traceability

#### `W09.B02.F0008.C0006` through `W09.B02.F0008.C0008`

- Source: `TestSource/Definitions/UClass/Test_ActorLifecycle.as`
- Problem: all three retirements say only “resolved high-risk replacement group.”
- Minimum structural mapping:

```text
replacedByTaskIds:
  - W09.B02.F0008.C0001
```

- Each retired observer must additionally map its old raw channel/vector to a named field in `ReadActorLifecycleState`.

#### `W10.B07.F0016.C0004` through `W10.B07.F0016.C0007`

- Source: `TestSource/Feature/Inheritance/Test_DefaultStatementsAffectComponentCDOs.as`
- Required replacement targets:
  - `W10.B07.F0016.C0001 ReadDefaultComponentValues`
  - `W10.B07.F0016.C0002 GetDefaultSphere`
  - `W10.B07.F0016.C0003 GetDefaultMesh`
- Each retirement must state whether coverage transfers to the state reader, a raw component getter, or both.

#### `W06.B01.F0048.C0007`

- Source: `TestSource/Containers/TSet/Test_SoftPathStringIdentityAndMissingClassBoundaries.as`
- Problem: the retirement has no replacement IDs.
- Required mapping: list the exact object-path identity, class-path identity, and missing-class resolve/load task IDs and the old aggregate channel each one replaces.

## False-ready acceptance rules

Before any row may be `review-ready`, the normalizer/validator should fail closed on the following rules.

### Comment rules

1. The exact comment must not contain:

```text
 covers 
is the function surface owned by
is the method surface owned by
Role: semantic operation/reader
Boundary and expected values live in typed vectors
ObservedCondition
```

2. The comment must state the behavior or phase, raw inputs, raw returns/writebacks/side effects, important boundary, and cleanup/dispatch owner that are specific to the callable.
3. A required lifecycle/callback comment must say how the engine/framework dispatches it and what state/output proves dispatch; “required engine-dispatched callable” alone is insufficient.
4. A semantic reader with empty `rawExpectations` cannot be review-ready.

### Semantic-name rules

1. Reject bare hard-rename results such as `Get`, `Set`, `Create`, `Execute`, `Test`, or `Handle` unless the exact spelling is externally required and justified.
2. Reject unreviewed semantic names matching:

```text
ForSubcaseNNN
Run...NN
Compile...NN
HandlerNN
ListenerNN
ServerActionNN
ClientNotifyNN
MulticastEventNN
ServerValidatedNN
LambdaAtLineNN
```

3. Values such as `87` belong in typed vectors unless the value is part of a real API/protocol name.
4. Required-name rows must have a non-empty reason and a concrete external consumer or protocol.
5. Anonymous lexical constructs need a separate stable lexical-label field; a plan label must not masquerade as a callable declaration name.

### Signature and writeback rules

1. Parsed declaration return and normalized `returnType` must agree.
2. Commented return/writeback channels must exactly match the declaration and proposal metadata.
3. Reject `FirstObservedCondition`, `SecondObservedCondition`, and other ordinal observation outputs.
4. Reject Gameplay/Unreal boolean writebacks beginning with uppercase `B`; use lowercase `b` and synchronize every dependent field.
5. A mutating API may not present its target as immutable input without an explicit ABI/fallback decision.

### Retirement rules

Every `retire-with-replacement` row must contain:

- at least one replacement task ID
- at least one replacement plan-row ID after row hashes are stable
- explicit coverage-transfer channels/vectors
- a blocker when the mapping is ambiguous

A retirement with only “replacement group” prose cannot be review-ready.

## Review decision

The TArray ledgers are the useful naming/comment reference because their comments describe concrete behavior, return/writeback channels, boundary conditions, and failure behavior. The other domain ledgers predominantly render planning metadata into grammatically complete but semantically generic comments.

The `plan-v2` ledger is suitable for blocker discovery, but not yet for user acceptance as an exhaustive predesigned function-name/signature/comment contract. Before acceptance review, the false-ready rows listed above must either receive concrete semantic corrections or be downgraded to an explicit evidence blocker. Blocked rows may remain in the plan for review, but they must not enter accepted row hashes or source implementation until their exact evidence is recorded.
