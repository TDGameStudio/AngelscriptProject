/**
 * @version v1
 * @summary Observe color/float AddDefaultKey, UCurveFloat AddAutoCurveKey, and SetKeyInterpMode, including the namespace color helper and repeated calls.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe color/float AddDefaultKey, UCurveFloat AddAutoCurveKey, and SetKeyInterpMode, including the namespace color helper and repeated calls.
 * @topic Baseline
 */
// void FRuntimeFloatCurve.AddDefaultKey(float32 InTime, float32 InValue);
// FCurveKeyHandle UCurveFloat.AddAutoCurveKey(float32 InTime, float32 InValue);
// void UCurveFloat.SetKeyInterpMode(FCurveKeyHandle KeyHandle, ERichCurveInterpMode NewInterpMode, bool bAutoSetTangents);
// void URuntimeCurveLinearColorMixinLibrary::AddDefaultKey(FRuntimeCurveLinearColor& Target, float32 InTime, FLinearColor InColor);
// Inputs: Color keys at 0.0/(1,0,0,0.25) and 2.5/(0.125,0.5,0.75,1), float
// keys at 0.5/1.25 then 3.0/9.5, and a transient UCurveFloat auto key at
// 1.5/7.5 with RCIM_Constant.
// Expected observations: Float AddDefaultKey raises GetNumKeys from 0 to 1
// then 2. Color instance and namespace helpers accept repeated keys. AddAutoCurveKey
// returns a handle whose sample at 1.5 is 7.5, and SetKeyInterpMode keeps that
// sample while mutating interpolation.
// Boundary/ownership: Color AddDefaultKey writes all four component curves in
// native storage. UCurveFloat is created in the transient package; the handle
// is only valid for that asset.

namespace TS_FunctionLibraryMixins_MutationAndLifecycle_01
{
	bool Observe_AddDefaultKey_Nominal()
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

	bool Observe_AddAutoCurveKey_Nominal()
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

	bool Observe_SetKeyInterpMode_Nominal()
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
}
/** @end */
