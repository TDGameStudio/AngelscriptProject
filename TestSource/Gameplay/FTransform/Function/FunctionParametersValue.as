/**
 * FTransforms passed by value, where the callee receives its own copy. C++ executes each
 * entrypoint and checks the value it produces, so those names are part of the contract
 * and are kept verbatim. The observers cover the empty argument and the independence of
 * the caller's transform.
 *
 * @Theme Gameplay.FTransform
 * @Subject FTransform.FunctionParametersValue
 * @Harness Function
 * @Tag Gameplay.FTransform.FunctionParametersValue
 * @Namespace FTransformTest
 * @Provenance Theme: Gameplay.FTransform. Positive value-parameter oracles.
 * @Provenance C++: AngelscriptCoverageFTransformFunctionTests.cpp::FunctionParametersValue
 * @Provenance Oracle: AcceptTransform((10,20,30)) location (110,20,30);
 * @Provenance AcceptTwoTransforms((100,0,0),(400,0,0)) Equals (300,0,0).
 * @Provenance Extra: AcceptTransform of Identity location (100,0,0); copy independence. DefaultSafe.
 */

namespace FTransformTest
{
	/**
	 * Add a fixed translation to a transform passed by value.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersValue
	 * @Inputs a transform
	 * @Return the transform with (100, 0, 0) added to its translation
	 * @Param t the transform to offset
	 */
	UFUNCTION()
	FTransform AcceptTransform(FTransform t)
	{
		FTransform Modified = t;
		Modified.AddToTranslation(FVector(100, 0, 0));
		return Modified;
	}

	/**
	 * Measure the world-space gap between two transforms passed by value.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersValue
	 * @Inputs two transforms
	 * @Return the difference of their transformed origins
	 * @Param a the first transform
	 * @Param b the second transform
	 */
	UFUNCTION()
	FVector AcceptTwoTransforms(FTransform a, FTransform b)
	{
		FVector PosA = a.TransformPosition(FVector::ZeroVector);
		FVector PosB = b.TransformPosition(FVector::ZeroVector);
		return PosB - PosA;
	}

	/**
	 * Observe that the offset matches the expected translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the result location is (110, 20, 30)
	 */
	UFUNCTION()
	bool AcceptTransformNominal()
	{
		FTransform Input = FTransform(FVector(10, 20, 30));
		return AcceptTransform(Input).GetLocation().Equals(FVector(110, 20, 30), 0.01);
	}

	/**
	 * Observe that the gap between two origins matches the expected vector.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the gap is (300, 0, 0)
	 */
	UFUNCTION()
	bool AcceptTwoTransformsNominal()
	{
		FTransform A = FTransform(FVector(100, 0, 0));
		FTransform B = FTransform(FVector(400, 0, 0));
		return AcceptTwoTransforms(A, B).Equals(FVector(300, 0, 0), 0.01);
	}

	/**
	 * Observe that offsetting an identity yields a translation of (100, 0, 0).
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersValue
	 * @Inputs a default-constructed transform
	 * @Return true when the result location is (100, 0, 0)
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptTransformDefaultIdentity()
	{
		return AcceptTransform(FTransform()).GetLocation().Equals(FVector(100, 0, 0), 0.01);
	}

	/**
	 * Observe that mutating the returned transform leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FTransform.FunctionParametersValue
	 * @Inputs a transform and the mutated result of passing it in
	 * @Return true when the argument still reads (10, 20, 30)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptTransformCopyIndependence()
	{
		FTransform Input = FTransform(FVector(10, 20, 30));
		FTransform Result = AcceptTransform(Input);
		Result.SetLocation(FVector::ZeroVector);
		return Input.GetLocation().Equals(FVector(10, 20, 30), 0.01);
	}
}
