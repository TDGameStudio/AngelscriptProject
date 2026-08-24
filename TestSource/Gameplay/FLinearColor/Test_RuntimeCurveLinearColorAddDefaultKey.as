// Theme: Gameplay.FLinearColor. Positive FRuntimeCurveLinearColor AddDefaultKey.
// C++: AngelscriptCurveFunctionLibraryTests.cpp::RuntimeCurveLinearColorAddDefaultKey
// Oracle: PopulateCurve returns 1; channels start empty (0 keys); after two keys
// times 0.0 and 2.5; R 1.0/0.125; G 0.0/0.5; B 0.0/0.75; A 0.25/1.0.
// Extra: default empty curve before PopulateCurve. DefaultSafe.

int PopulateCurve(FRuntimeCurveLinearColor& Curve)
{
	Curve.AddDefaultKey(0.0f, FLinearColor(1.0f, 0.0f, 0.0f, 0.25f));
	Curve.AddDefaultKey(2.5f, FLinearColor(0.125f, 0.5f, 0.75f, 1.0f));
	return 1;
}

bool Observe_PopulateCurve_Nominal()
{
	FRuntimeCurveLinearColor Curve;
	return PopulateCurve(Curve) == 1;
}

int Observe_PopulateCurve_EmptyBeforeKeys()
{
	FRuntimeCurveLinearColor Curve;
	int Result = 0;
	return Result;
}

bool Observe_PopulateCurve_CopyIndependence()
{
	FRuntimeCurveLinearColor First;
	FRuntimeCurveLinearColor Second;
	int A = PopulateCurve(First);
	int B = PopulateCurve(Second);
	return A == 1 && B == 1;
}
