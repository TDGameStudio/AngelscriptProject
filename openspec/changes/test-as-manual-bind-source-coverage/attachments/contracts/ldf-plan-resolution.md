# Language / Definitions / Feature Contract V2 Plan Resolution

> Plan-only evidence. No TestSource, OpenSpec, plugin, or product file was modified by this audit.

## Outcome

Canonical identity reconciliation is numerically complete, but semantic execution remains blocked until scanner-gap rows and diagnostic evidence blockers are resolved. The machine ledger is ldf-plan-resolution.json.

| Measure | Count |
| --- | ---: |
| Source files | 1528 |
| Original audit rows | 6248 |
| Canonical current identities | 6240 |
| Audit rows mapped | 6227 |
| Excluded audit rows | 21 |
| Canonical supplemental identities | 13 |
| Net audit excess | 8 |
| Null-owner rows resolved | 4425 |
| Void/raw-return conflicts | 972 |
| High-risk replacements | 47 |
| High-risk merged overlays | 6 |
| Final planned projection | 6240 |
| Canonical scanner gaps | 11 |
| Compile failures missing matcher | 85 |
| Duplicate scanner identity groups | 4 |

Equations: 6,227 mapped + 21 excluded = 6,248 audit rows; 6,227 mapped + 13 supplemental = 6,240 canonical identities; 6,240 - 47 legacy + 47 replacement with six merged overlays = 6,240 planned rows; 970 retained + 2 eliminated = 972 void/raw-return conflicts.

## Canonical supplemental identities (13)

| Source | Line | Owner | Kind | Current identity | Planned name | Status |
| --- | ---: | --- | --- | --- | --- | --- |
| TestSource/Definitions/UFunction/Test_Specifiers_Negative_09.as | 9 | AUFuncGarbageActor | method | AUFuncGarbageActor<br>UFUNCTION() garbage void Foo() | CompileTrailingGarbageAfterUFunction | blocking-diagnostic-evidence |
| TestSource/Feature/Default/Test_DefaultsOnlyAccess_01.as | 13 | UDefaultsOnlyOkTarget | method | UDefaultsOnlyOkTarget<br>int BuildDefaultValue() defaults | BuildDefaultValue | reviewed-required-name |
| TestSource/Feature/Default/Test_DefaultsOnlyAccess_02.as | 12 | UDefaultsOnlyRejectTarget | method | UDefaultsOnlyRejectTarget<br>int BuildDefaultValue() defaults | BuildDefaultValue | reviewed-required-name |
| TestSource/Feature/Default/Test_UnsafeDuringConstructionRejectsDefaultAndConstructor_01.as | 12 | UUnsafeDefaultTarget | method | UUnsafeDefaultTarget<br>int UnsafeValue() unsafe_during_construction | UnsafeValue | reviewed-required-name |
| TestSource/Feature/Default/Test_UnsafeDuringConstructionRejectsDefaultAndConstructor_02.as | 10 | UnsafeConstructorCarrier | method | UnsafeConstructorCarrier<br>int UnsafeValue() unsafe_during_construction | UnsafeValue | reviewed-required-name |
| TestSource/Feature/Default/Test_UnsafeDuringConstructionRejectsDefaultAndConstructor_03.as | 13 | UUnsafeOrdinaryTarget | method | UUnsafeOrdinaryTarget<br>int UnsafeValue() unsafe_during_construction | UnsafeValue | reviewed-required-name |
| TestSource/Feature/Delegates/Test_TimerDelegateLambdaSetTimerBoundary.as | 19 | ACoverageTimerDelegateLambdaActor::BeginPlay@L15#lambda-01@L19C56 | lambda | ACoverageTimerDelegateLambdaActor::BeginPlay@L15#lambda-01@L19C56<br>function() | UnsupportedSetTimerDelegateLambda | reviewed-required-anonymous |
| TestSource/Feature/Delegates/Test_TimerDelegateLambdaSingleShotBoundary.as | 27 | ACoverageTimerDelegateLambdaActor::BeginPlay@L24#lambda-01@L27C56 | lambda | ACoverageTimerDelegateLambdaActor::BeginPlay@L24#lambda-01@L27C56<br>function() | UnsupportedSingleShotTimerDelegateLambda | reviewed-required-anonymous |
| TestSource/Language/Preprocessor/Test_RejectUnsupportedConditionalPlacement_02.as | 14 | UBadPropertyConditionalCarrier | method | UBadPropertyConditionalCarrier<br>#ifndef UNKNOWN_FLAG<br>	UPROPERTY()<br>	int BadValue | BadValueConditionalPropertyScannerArtifact | blocking-canonical-scanner-artifact |
| TestSource/Language/Preprocessor/Test_RejectUnsupportedConditionalPlacement_03.as | 14 | UEditorConditionalCarrier | method | UEditorConditionalCarrier<br>#if EDITOR<br>	UPROPERTY()<br>	int EditorValue | EditorValueConditionalPropertyScannerArtifact | blocking-canonical-scanner-artifact |
| TestSource/Language/Syntax/EdgeCases/Test_DeclaredFunctionImportRebindsAfterProviderReload_03.as | 7 | :: | import | ::<br>import int SharedValue() from "Tests.Compiler.ImportReloadSource" | SharedValue | reviewed-required-name |
| TestSource/Language/Syntax/EdgeCases/Test_DeclaredFunctionImportRoundTrip_02.as | 7 | :: | import | ::<br>import int SharedValue() from "Tests.Compiler.ImportSource" | SharedValue | reviewed-required-name |
| TestSource/Language/Syntax/EdgeCases/Test_EventNonScriptFacingBoundaries_02.as | 13 | ACoverageEventTimerLambdaBoundaryActor::TryTimerLambda@L10#lambda-01@L13C26 | lambda | ACoverageEventTimerLambdaBoundaryActor::TryTimerLambda@L10#lambda-01@L13C26<br>[]() | UnsupportedTimerLambdaExpression | reviewed-required-anonymous |

Two supplements are UPROPERTY scanner artifacts, two imports and three lambdas are genuine V2 identities, and six modifier or invalid-declaration surfaces are newly recognized.

## Excluded audit rows (21)

| Source | Line | Legacy symbol | Planned name | Resolution | Blocks exhaustiveness |
| --- | ---: | --- | --- | --- | --- |
| TestSource/Definitions/Meta/Test_MacroExpansionIgnoresCommentsStringsAndInactiveBranches.as | 20 | ACoverageMacrosExpansionBoundaryActor::GetLiteralLength | GetLiteralLength | blocking-canonical-scanner-gap | yes |
| TestSource/Definitions/Meta/Test_MacroMetadataStringsWithClosingParen.as | 19 | UMETA | UMETA | eliminated-audit-false-positive | no |
| TestSource/Definitions/Meta/Test_ReflectionMacroCombination.as | 9 | UMETA | UMETA | eliminated-audit-false-positive | no |
| TestSource/Definitions/Meta/Test_ReflectionMacroCombination.as | 10 | UMETA | UMETA | eliminated-audit-false-positive | no |
| TestSource/Definitions/UFunction/Test_Params_UnnamedParameter.as | 11 | AUFuncPNoNameActor::Foo | RunParamsUnnamedParameter | blocking-canonical-scanner-gap | yes |
| TestSource/Feature/Delegates/Test_Declaration_Negative_MissingSemicolon.as | 8 | FOnActionNoSemi | FOnActionNoSemi | eliminated-invalid-program-noncallable | no |
| TestSource/Feature/Delegates/Test_Declaration_Negative_NoName.as | 8 | void | void | eliminated-invalid-program-noncallable | no |
| TestSource/Feature/PropertyAccess/Test_BlueprintGetterRemainsCallableWithoutSyntheticAlias.as | 12 | AAutoAccessorGetterScriptActor::CheckGetterAccess | CheckGetterAccess | blocking-canonical-scanner-gap | yes |
| TestSource/Feature/PropertyAccess/Test_BlueprintGetterSyntheticAliasDoesNotCompile.as | 11 | AAutoAccessorGetterScriptActorFailure::CheckSyntheticGetterAlias | CheckSyntheticGetterAlias | blocking-canonical-scanner-gap | yes |
| TestSource/Feature/PropertyAccess/Test_RawFieldAccessCompilesAndRuns.as | 12 | AAutoAccessorRawFieldScriptActor::CheckRawFieldAccess | CheckRawFieldAccess | blocking-canonical-scanner-gap | yes |
| TestSource/Feature/PropertyAccess/Test_RawFieldSyntheticGetterDoesNotCompile.as | 11 | AAutoAccessorRawFieldScriptActorFailure::CheckSyntheticGetter | CheckSyntheticGetter | blocking-canonical-scanner-gap | yes |
| TestSource/Language/Literals/FString/Test_Negative_01.as | 8 | Test | CompileNegative01 | eliminated-invalid-program-noncallable | no |
| TestSource/Language/Preprocessor/Test_ExplicitContextControlsFlagsAndDefaults.as | 16 | UExplicitContextCarrier::ImplicitFunction | ImplicitFunction | blocking-canonical-scanner-gap | yes |
| TestSource/Language/Preprocessor/Test_MissingSemicolonReportsSyntax_02.as | 8 | UseShared | UseShared | eliminated-invalid-program-noncallable | no |
| TestSource/Language/Preprocessor/Test_RejectUnsupportedConditionalPlacement_01.as | 16 | UBadFunctionConditionalCarrier::BadFunction | BadFunction | blocking-canonical-scanner-gap | yes |
| TestSource/Language/Preprocessor/Test_RestrictUsageAllowPattern.as | 9 | Entry | Entry | blocking-canonical-scanner-gap | yes |
| TestSource/Language/Preprocessor/Test_RestrictUsageInactiveBranchIgnored_01.as | 10 | Entry | Entry | blocking-canonical-scanner-gap | yes |
| TestSource/Language/Preprocessor/Test_RestrictUsageInactiveBranchIgnored_02.as | 10 | Entry | Entry | blocking-canonical-scanner-gap | yes |
| TestSource/Language/Syntax/EdgeCases/Test_EdgeCases_Negative_01.as | 7 | Test | CompileEdgeCasesNegative01 | eliminated-invalid-program-noncallable | no |
| TestSource/Language/Syntax/EdgeCases/Test_Enum_Negative_06.as | 10 | Foo | CompileEnumNegative06 | eliminated-invalid-program-noncallable | no |
| TestSource/Language/Syntax/EdgeCases/Test_Interface_Mixed_04.as | 10 | Foo | CompileInterfaceMixed04 | eliminated-invalid-program-noncallable | no |

Each excluded row keeps its exact suggested declaration and evidence in JSON. Scanner-gap rows must be fixed or accepted before implementation.

## High-risk 47 to 53 resolution

Six fixed callbacks are merged onto current identities; 47 exact rows replace 47 aggregate observers.

| Source | Owner | Exact overlay | Current identity |
| --- | --- | --- | --- |
| TestSource/Definitions/UClass/Test_ActorLifecycle.as | ALifecycleActor | UFUNCTION(BlueprintOverride)<br>void Tick(float DeltaTime) | ALifecycleActor<br>UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)@L30 |
| TestSource/Definitions/UClass/Test_ComponentLifecycle_03.as | ULifecycleComponent | UFUNCTION(BlueprintOverride)<br>void Tick(float DeltaTime) | ULifecycleComponent<br>UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)@L27 |
| TestSource/Feature/Inheritance/Test_InheritanceProcessEventDispatchesToChildOverride.as | ATestInhHealthPickup3 | UFUNCTION(BlueprintOverride)<br>void OnPickedUp(int CollectorHash) | ATestInhHealthPickup3<br>UFUNCTION(BlueprintOverride)
	void OnPickedUp(int CollectorHash)@L30 |
| TestSource/Feature/Inheritance/Test_NativeUFunctionCanBeInvoked.as | ATestScriptActorNativeUFunctionCanBeInvoked | UFUNCTION()<br>void ReceiveNativeValue(int Value) | ATestScriptActorNativeUFunctionCanBeInvoked<br>UFUNCTION()
	void ReceiveNativeValue(int Value)@L16 |
| TestSource/Language/Syntax/EdgeCases/Test_GCCrossFrameHold.as | ACoverageGCCrossFrameHoldActor | UFUNCTION(BlueprintOverride)<br>void BeginPlay() | ACoverageGCCrossFrameHoldActor<br>UFUNCTION(BlueprintOverride)
	void BeginPlay()@L22 |
| TestSource/Language/Syntax/EdgeCases/Test_GCCrossFrameHold.as | ACoverageGCCrossFrameHoldActor | UFUNCTION(BlueprintOverride)<br>void Tick(float DeltaSeconds) | ACoverageGCCrossFrameHoldActor<br>UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)@L30 |

The 47 replacements resolve owners as UFUNCTION fixture methods for stateful phases or global accessors when an object is an explicit parameter.

## Metadata, diagnostics, and line sensitivity

proposedReturnType is authoritative; auditRawReturnType is history. The 970 retained conflicts carry an explicit override. Two malformed UMETA rows are excluded.

Evidence classifies 531 files as compile failures. 85 lack a recorded exact matcher and carry a C++-reference blocker; no diagnostic string is invented. 321 files are line-sensitive.

## Status distribution

Current canonical rows (including 47 superseded legacy aggregates):

| Status | Rows |
| --- | ---: |
| blocking-canonical-scanner-artifact | 2 |
| blocking-diagnostic-evidence | 1 |
| blocking-plan-evidence | 1162 |
| reviewed-exact | 3454 |
| reviewed-required-anonymous | 3 |
| reviewed-required-name | 1571 |
| superseded-by-high-risk-replacement-group | 47 |

## Typed vector normalization

All 6240 final planned rows now satisfy an explicit vector gate. 5351 rows carry recorded or evidence-derived typed vectors; the remaining 889 rows carry a field-level `vector-unresolved` blocker with exact `reason` and `evidenceNeeded`, and their status is `blocking-plan-evidence`. There are zero execution-ready rows with an empty `typedInputVectors` array.

| Vector resolution | Rows |
| --- | ---: |
| Existing typed parameter vectors | 2793 |
| Exact diagnostic vectors generated | 273 |
| Exact raw-observation/writeback vectors generated | 462 |
| Exact declaration-contract vectors generated | 137 |
| Exact source-Oracle vectors generated | 1686 |
| Evidence-unresolved vectors blocked | 889 |

A source-Oracle vector is generated only when the evidence contains a literal/comparison Oracle or Extra statement and the evidence maps to the callable by stable/current name (or sole-case ownership). High-risk replacement phases are not inferred from case-wide prose; without direct raw observations they remain blocked for field-level runner evidence.

## Consumer rules

1. Build from currentRows; canonical owner and identity win.
2. Replace remove rows with matching highRiskReplacementRows; never emit aliases.
3. Merge highRiskOverlays by overridesCurrentQualifiedIdentity; do not count them as new.
4. Emit proposedExactDeclaration, including annotations.
5. Use proposedReturnType and parsed writebacks; historical return metadata is not ABI.
6. Stop when status starts blocking or blockers are non-empty.
7. Do not claim semantic exhaustiveness while scanner gaps or UPROPERTY artifacts remain.

## Self-validation

- Canonical identity coverage: 6240/6240, unique within source path.
- Four duplicate scanner identity groups are disambiguated by exact current declaration line.
- Null-owner mapped rows resolved: 4425/4425.
- Planned declarations, comments, and body plans contain no ellipsis or generic diagnostic placeholder.
- High-risk accounting: 47 removals, 47 replacements, six overlays.
- Typed-vector gate: 5351 rows have concrete/recorded vectors; 889 unresolved rows are explicitly blocked; zero empty-vector rows are execution-ready.
- JSON SHA-256: eee110c43ac3c034eda395bea204f490ed5e3b8f8661828d566f61715e3c22f1.
- Input audit SHA-256: 62f433fcc9432db913346c762abbbcf8de613e7e6ff2daf8ee5b79fa5d1d32ad.
- Scanner SHA-256: 388467e6c051c7a985947b9fdc53cbdbbb17c7b40142fa69486635ff869b361f.
