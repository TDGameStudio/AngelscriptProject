/**
 * @version v1
 * @summary FunctionLibraryMixins host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FunctionLibraryMixins
 *
 * add-default-key
 * add-auto-curve-key
 * set-key-interp-mode
 * get-should-be-visible-in-editor
 * get-num-keys
 * get-time-range
 */
/**
 * @begin add-default-key
 * @summary is only valid for that asset.
 * @topic Unreal
 */
/**
 * @function ObserveAddDefaultKeyNominal
 * @summary is only valid for that asset.
 * @covers FunctionLibraryMixins.add-default-key
 * @inputs FunctionLibraryMixins values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddDefaultKeyNominal()
{
	FRuntimeCurveLinearColor ColorCurve;
	ColorCurve.AddDefaultKey(0.0f, FLinearColor(1.0f, 0.0f, 0.0f, 0.25f));
	ColorCurve.AddDefaultKey(2.5f, FLinearColor(0.125f, 0.5f, 0.75f, 1.0f));

	FRuntimeCurveLinearColor NamespaceColor;
	URuntimeCurveLinearColorMixinLibrary::AddDefaultKey(NamespaceColor, 0.0f, FLinearColor(1.0f, 0.0f, 0.0f, 0.25f));
	URuntimeCurveLinearColorMixinLibrary::AddDefaultKey(NamespaceColor, 2.5f, FLinearColor(0.125f, 0.5f, 0.75f, 1.0f));

	FRuntimeFloatCurve FloatCurve;
	int EmptyCount = FloatCurve.GetNumKeys();
	FloatCurve.AddDefaultKey(0.5f, 1.25f);
	int AfterFirst = FloatCurve.GetNumKeys();
	FloatCurve.AddDefaultKey(3.0f, 9.5f);
	int AfterSecond = FloatCurve.GetNumKeys();
	return EmptyCount == 0 && AfterFirst == 1 && AfterSecond == 2;
}
/** @end */
/**
 * @begin add-auto-curve-key
 * @summary is only valid for that asset.
 * @topic Unreal
 */
/**
 * @function ObserveAddAutoCurveKeyNominal
 * @summary is only valid for that asset.
 * @covers FunctionLibraryMixins.add-auto-curve-key
 * @inputs FunctionLibraryMixins values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAutoCurveKeyNominal()
{
	UCurveFloat Curve = Cast<UCurveFloat>(
		NewObject(GetTransientPackage(), UCurveFloat::StaticClass(), n"TSFunctionLibraryMixinsAutoCurve", true));
	if (Curve is null)
	{
		throw("TS_FunctionLibraryMixins_MutationAndLifecycle_01 setup: required Curve is null");
	}
	FCurveKeyHandle Handle = Curve.AddAutoCurveKey(1.5f, 7.5f);
	float32 Sample = Curve.GetFloatValue(1.5f);
	FCurveKeyHandle Second = Curve.AddAutoCurveKey(3.0f, 9.5f);
	float32 SecondSample = Curve.GetFloatValue(3.0f);
	return Sample == 7.5f && SecondSample == 9.5f;
}
/** @end */
/**
 * @begin set-key-interp-mode
 * @summary is only valid for that asset.
 * @topic Unreal
 */
/**
 * @function ObserveSetKeyInterpModeNominal
 * @summary is only valid for that asset.
 * @covers FunctionLibraryMixins.set-key-interp-mode
 * @inputs FunctionLibraryMixins values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetKeyInterpModeNominal()
{
	UCurveFloat Curve = Cast<UCurveFloat>(
		NewObject(GetTransientPackage(), UCurveFloat::StaticClass(), n"TSFunctionLibraryMixinsInterpCurve", true));
	if (Curve is null)
	{
		throw("TS_FunctionLibraryMixins_MutationAndLifecycle_01 setup: required Curve is null");
	}
	FCurveKeyHandle Handle = Curve.AddAutoCurveKey(1.5f, 7.5f);
	Curve.SetKeyInterpMode(Handle, ERichCurveInterpMode::RCIM_Constant, false);
	float32 AfterConstant = Curve.GetFloatValue(1.5f);
	Curve.SetKeyInterpMode(Handle, ERichCurveInterpMode::RCIM_Linear, true);
	float32 AfterLinear = Curve.GetFloatValue(1.5f);
	return AfterConstant == 7.5f && AfterLinear == 7.5f;
}
/** @end */
/**
 * @begin get-should-be-visible-in-editor
 * @summary access and lives in ExerciseExpectedFailure.
 * @topic Unreal
 */
/**
 * @function ObserveGetShouldBeVisibleInEditorNominal
 * @summary access and lives in ExerciseExpectedFailure.
 * @covers FunctionLibraryMixins.get-should-be-visible-in-editor
 * @inputs FunctionLibraryMixins values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetShouldBeVisibleInEditorNominal()
{
	ULevelStreamingDynamic First = Cast<ULevelStreamingDynamic>(
		NewObject(GetTransientPackage(), ULevelStreamingDynamic::StaticClass(), n"TSFunctionLibraryMixinsStreamingLevelA", true));
	ULevelStreamingDynamic Second = Cast<ULevelStreamingDynamic>(
		NewObject(GetTransientPackage(), ULevelStreamingDynamic::StaticClass(), n"TSFunctionLibraryMixinsStreamingLevelB", true));
	if (First is null || Second is null)
	{
		throw("TS_FunctionLibraryMixins_Queries_01 setup: required LevelStreaming is null");
	}
	return First.GetShouldBeVisibleInEditor() == Second.GetShouldBeVisibleInEditor();
}
/** @end */
/**
 * @begin get-num-keys
 * @summary access and lives in ExerciseExpectedFailure.
 * @topic Unreal
 */
/**
 * @function ObserveGetNumKeysNominal
 * @summary access and lives in ExerciseExpectedFailure.
 * @covers FunctionLibraryMixins.get-num-keys
 * @inputs FunctionLibraryMixins values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNumKeysNominal()
{
	FRuntimeFloatCurve Empty;
	FRuntimeFloatCurve Seeded;
	Seeded.AddDefaultKey(0.5f, 1.25f);
	Seeded.AddDefaultKey(3.0f, 9.5f);
	return Empty.GetNumKeys() == 0 && Seeded.GetNumKeys() == 2;
}
/** @end */
/**
 * @begin get-time-range
 * @summary access and lives in ExerciseExpectedFailure.
 * @topic Unreal
 */
/**
 * @function ObserveGetTimeRangeNominal
 * @summary access and lives in ExerciseExpectedFailure.
 * @covers FunctionLibraryMixins.get-time-range
 * @inputs FunctionLibraryMixins values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTimeRangeNominal()
{
	FRuntimeFloatCurve Empty;
	float32 EmptyMinBefore = -1.0f;
	float32 EmptyMaxBefore = -1.0f;
	float32 EmptyMin = EmptyMinBefore;
	float32 EmptyMax = EmptyMaxBefore;
	URuntimeFloatCurveMixinLibrary::GetTimeRange(Empty, EmptyMin, EmptyMax);

	FRuntimeFloatCurve Seeded;
	Seeded.AddDefaultKey(0.5f, 1.25f);
	Seeded.AddDefaultKey(3.0f, 9.5f);
	float32 SeededMinBefore = -1.0f;
	float32 SeededMaxBefore = -1.0f;
	float32 SeededMin = SeededMinBefore;
	float32 SeededMax = SeededMaxBefore;
	URuntimeFloatCurveMixinLibrary::GetTimeRange(Seeded, SeededMin, SeededMax);
	return EmptyMin == 0.0f &&
		EmptyMax == 0.0f &&
		EmptyMin != EmptyMinBefore &&
		EmptyMax != EmptyMaxBefore &&
		SeededMin == 0.5f &&
		SeededMax == 3.0f &&
		SeededMin != SeededMinBefore &&
		SeededMax != SeededMaxBefore;
}
/** @end */
