/**
 * FRuntimeFloatCurve and UCurveFloat instance helpers: adding default keys,
 * reading the time range, and adding an auto key to a curve asset found by path.
 * The one-argument form keeps the C++ ReplaceInline marker; the two-argument
 * overload is its substituted form.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.RuntimeFloatCurveInstanceSurface
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.RuntimeFloatCurveInstanceSurface
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCurveFunctionLibraryTests.cpp::RuntimeFloatCurveInstanceSurface
 * @Provenance sha256=8a1aa2c9bb9b6303ca0e8583d5d8c04c876a30ab19b661526d45ed808c8bdcdd; lines 189-222.
 * @Provenance Oracle: PopulateCurve returns 1 after two default keys and a UCurveFloat auto key at 1.5/7.5.
 * @Provenance C++ ReplaceInline of __CURVE_PATH__ becomes the CurvePath runner parameter on the overload.
 * @Provenance Extra: empty FRuntimeFloatCurve GetNumKeys()==0; empty CurvePath FindObject misses -> 30.
 * @Provenance DefaultSafe. Original 1-arg body is preserved; 2-arg overload is the substitution form.
 */

namespace SyntaxTest
{
	/**
	 * Populates a runtime curve and its curve asset, with the ReplaceInline marker.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a runtime curve to populate
	 * @Return 1 on success, otherwise 10/20/30/40 naming the failed step
	 * @param RuntimeCurve the curve receiving two default keys
	 */
	int PopulateCurve(FRuntimeFloatCurve&inout RuntimeCurve)
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

	/**
	 * Populates a runtime curve and its curve asset found by an explicit path.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a runtime curve and the curve asset's object path
	 * @Return 1 on success, otherwise 10/20/30/40 naming the failed step
	 * @param RuntimeCurve the curve receiving two default keys
	 * @param CurvePath the object path to find the curve asset
	 */
	int PopulateCurve(FRuntimeFloatCurve&inout RuntimeCurve, const FString&in CurvePath)
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

	/**
	 * Observe the empty-path boundary of the substituted form.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a runtime curve and an empty path
	 * @Return 30, since FindObject on an empty path misses
	 * @Boundary empty path
	 * @param RuntimeCurve the curve receiving the two default keys
	 */
	UFUNCTION()
	int PopulateCurveEmptyPath(FRuntimeFloatCurve&inout RuntimeCurve)
	{
		return PopulateCurve(RuntimeCurve, "");
	}

	/**
	 * Observe the key count of a fresh runtime curve.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed runtime curve
	 * @Return 0
	 * @Boundary empty curve
	 */
	UFUNCTION()
	int RuntimeFloatCurveEmptyKeyCount()
	{
		FRuntimeFloatCurve Empty;
		return Empty.GetNumKeys();
	}
}
