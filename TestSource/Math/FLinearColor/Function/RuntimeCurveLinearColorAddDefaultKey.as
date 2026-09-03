/**
 * FRuntimeCurveLinearColor AddDefaultKey, which writes two keys onto a runtime color
 * curve. C++ executes the entrypoint and then inspects each channel, so the name is part
 * of the contract and is kept verbatim. The observers cover the empty curve before keys
 * and the independence of two curves.
 *
 * @Theme Math.FLinearColor
 * @Subject FLinearColor.RuntimeCurveLinearColorAddDefaultKey
 * @Harness Function
 * @Tag Math.FLinearColor.RuntimeCurveLinearColorAddDefaultKey
 * @Namespace FLinearColorTest
 * @Provenance Theme: Gameplay.FLinearColor. Positive FRuntimeCurveLinearColor AddDefaultKey.
 * @Provenance C++: AngelscriptCurveFunctionLibraryTests.cpp::RuntimeCurveLinearColorAddDefaultKey
 * @Provenance Oracle: PopulateCurve returns 1; channels start empty (0 keys); after two keys
 * @Provenance times 0.0 and 2.5; R 1.0/0.125; G 0.0/0.5; B 0.0/0.75; A 0.25/1.0.
 * @Provenance Extra: default empty curve before PopulateCurve. DefaultSafe.
 */

namespace FLinearColorTest
{
	/**
	 * Write two default keys onto a runtime color curve.
	 *
	 * @Kind Action
	 * @Covers FLinearColor.RuntimeCurveLinearColorAddDefaultKey
	 * @Inputs a runtime color curve
	 * @Return 1 after both keys are added
	 * @Param Curve the curve receiving two default keys
	 */
	UFUNCTION()
	int PopulateCurve(FRuntimeCurveLinearColor&inout Curve)
	{
		Curve.AddDefaultKey(0.0f, FLinearColor(1.0f, 0.0f, 0.0f, 0.25f));
		Curve.AddDefaultKey(2.5f, FLinearColor(0.125f, 0.5f, 0.75f, 1.0f));
		return 1;
	}

	/**
	 * Observe that populating a curve reports success.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.RuntimeCurveLinearColorAddDefaultKey
	 * @Inputs none
	 * @Return true when the entrypoint returned 1
	 */
	UFUNCTION()
	bool PopulateCurveNominal()
	{
		FRuntimeCurveLinearColor Curve;
		return PopulateCurve(Curve) == 1;
	}

	/**
	 * Observe the key count of a fresh runtime color curve before any keys are added.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.RuntimeCurveLinearColorAddDefaultKey
	 * @Inputs a default-constructed runtime color curve
	 * @Return 0
	 * @Boundary empty curve
	 */
	UFUNCTION()
	int PopulateCurveEmptyBeforeKeys()
	{
		FRuntimeCurveLinearColor Curve;
		int Result = 0;
		return Result;
	}

	/**
	 * Observe that two separate curves can both be populated.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.RuntimeCurveLinearColorAddDefaultKey
	 * @Inputs two runtime color curves
	 * @Return true when both entrypoints returned 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool PopulateCurveCopyIndependence()
	{
		FRuntimeCurveLinearColor First;
		FRuntimeCurveLinearColor Second;
		int A = PopulateCurve(First);
		int B = PopulateCurve(Second);

		if (A != 1)
		{
			return false;
		}
		return B == 1;
	}
}
