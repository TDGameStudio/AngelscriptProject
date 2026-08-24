// Theme: Language.Syntax.EdgeCases. Positive FRuntimeFloatCurve/UCurveFloat instance helpers.
// C++: AngelscriptCurveFunctionLibraryTests.cpp::RuntimeFloatCurveInstanceSurface
// sha256=8a1aa2c9bb9b6303ca0e8583d5d8c04c876a30ab19b661526d45ed808c8bdcdd; lines 189-222.
// Oracle: PopulateCurve returns 1 after two default keys and a UCurveFloat auto key at 1.5/7.5.
// C++ ReplaceInline of __CURVE_PATH__ becomes the CurvePath runner parameter on the overload.
// Extra: empty FRuntimeFloatCurve GetNumKeys()==0; empty CurvePath FindObject misses -> 30.
// DefaultSafe. Original 1-arg body is preserved; 2-arg overload is the substitution form.

int PopulateCurve(FRuntimeFloatCurve& RuntimeCurve)
{
	RuntimeCurve.AddDefaultKey(0.5f, 1.25f);
	RuntimeCurve.AddDefaultKey(3.0f, 9.5f);
	if (RuntimeCurve.GetNumKeys() != 2)
	{
		return 10;
	}

	float32 MinTime = -1.0f;
	float32 MaxTime = -1.0f;
	RuntimeCurve.GetTimeRange(MinTime, MaxTime);
	if (MinTime != 0.5f || MaxTime != 3.0f)
	{
		return 20;
	}

	UObject CurveObject = FindObject("__CURVE_PATH__");
	UCurveFloat CurveAsset = Cast<UCurveFloat>(CurveObject);
	if (CurveAsset == null)
	{
		return 30;
	}

	FCurveKeyHandle Handle = CurveAsset.AddAutoCurveKey(1.5f, 7.5f);
	if (CurveAsset.GetFloatValue(1.5f) != 7.5f)
	{
		return 40;
	}
	CurveAsset.SetKeyInterpMode(Handle, ERichCurveInterpMode::RCIM_Constant, false);
	return 1;
}

int PopulateCurve(FRuntimeFloatCurve& RuntimeCurve, const FString& CurvePath)
{
	RuntimeCurve.AddDefaultKey(0.5f, 1.25f);
	RuntimeCurve.AddDefaultKey(3.0f, 9.5f);
	if (RuntimeCurve.GetNumKeys() != 2)
	{
		return 10;
	}

	float32 MinTime = -1.0f;
	float32 MaxTime = -1.0f;
	RuntimeCurve.GetTimeRange(MinTime, MaxTime);
	if (MinTime != 0.5f || MaxTime != 3.0f)
	{
		return 20;
	}

	UObject CurveObject = FindObject(CurvePath);
	UCurveFloat CurveAsset = Cast<UCurveFloat>(CurveObject);
	if (CurveAsset == null)
	{
		return 30;
	}

	FCurveKeyHandle Handle = CurveAsset.AddAutoCurveKey(1.5f, 7.5f);
	if (CurveAsset.GetFloatValue(1.5f) != 7.5f)
	{
		return 40;
	}
	CurveAsset.SetKeyInterpMode(Handle, ERichCurveInterpMode::RCIM_Constant, false);
	return 1;
}

int Observe_PopulateCurve_EmptyPath(FRuntimeFloatCurve& RuntimeCurve)
{
	return PopulateCurve(RuntimeCurve, "");
}

int Observe_RuntimeFloatCurve_EmptyKeyCount()
{
	FRuntimeFloatCurve Empty;
	return Empty.GetNumKeys();
}
