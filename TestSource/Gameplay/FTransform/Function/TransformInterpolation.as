/**
 * The FTransform Blend interpolation paths: a mid-point blend, Blend at zero, Blend at
 * one, and a blend that also interpolates scale. Math::Lerp is a separate compile-fail
 * file. C++ executes each entrypoint and compares the result with the native equivalent,
 * so those names are part of the contract and are kept verbatim. The observers cover
 * identity blending and the independence of the inputs.
 *
 * @Theme Gameplay.FTransform
 * @Subject FTransform.Interpolation
 * @Harness Function
 * @Tag Gameplay.FTransform.TransformInterpolation
 * @Namespace FTransformTest
 * @Provenance Theme: Gameplay.FTransform. Positive Blend interpolation oracles.
 * @Provenance C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformInterpolation (compiling block)
 * @Provenance CSV Positive; C++ compiles Blend. Math::Lerp is a separate CompileAndExpectFailure file (_02).
 * @Provenance Oracle: Blend 0.5 of (0,0,0)/(100,100,100); BlendAtZero (100,200,300);
 * @Provenance BlendAtOne (400,500,600); BlendWithScale native Blend at 0.5.
 * @Provenance Extra: Blend of Identity with itself; copy independence of A. DefaultSafe.
 */

namespace FTransformTest
{
	/**
	 * Blend two translations at alpha 0.5.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Interpolation
	 * @Inputs none
	 * @Return Blend of (0,0,0) and (100,100,100) at 0.5
	 */
	UFUNCTION()
	FTransform BlendTransforms()
	{
		FTransform A = FTransform(FVector(0, 0, 0));
		FTransform B = FTransform(FVector(100, 100, 100));
		FTransform Result;
		Result.Blend(A, B, 0.5f);
		return Result;
	}

	/**
	 * Blend two translations at alpha 0, which should keep A.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Interpolation
	 * @Inputs none
	 * @Return Blend of (100,200,300) and (400,500,600) at 0
	 */
	UFUNCTION()
	FTransform BlendAtZero()
	{
		FTransform A = FTransform(FVector(100, 200, 300));
		FTransform B = FTransform(FVector(400, 500, 600));
		FTransform Result;
		Result.Blend(A, B, 0.0f);
		return Result;
	}

	/**
	 * Blend two translations at alpha 1, which should keep B.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Interpolation
	 * @Inputs none
	 * @Return Blend of (100,200,300) and (400,500,600) at 1
	 */
	UFUNCTION()
	FTransform BlendAtOne()
	{
		FTransform A = FTransform(FVector(100, 200, 300));
		FTransform B = FTransform(FVector(400, 500, 600));
		FTransform Result;
		Result.Blend(A, B, 1.0f);
		return Result;
	}

	/**
	 * Blend two transforms that also differ in scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Interpolation
	 * @Inputs none
	 * @Return Blend of identity scale and (100,0,0) scale 3 at 0.5
	 */
	UFUNCTION()
	FTransform BlendWithScale()
	{
		FTransform A = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(1, 1, 1));
		FTransform B = FTransform(FQuat::Identity, FVector(100, 0, 0), FVector(3, 3, 3));
		FTransform Result;
		Result.Blend(A, B, 0.5f);
		return Result;
	}

	/**
	 * Observe that the mid-point blend matches the native Blend.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Interpolation
	 * @Inputs none
	 * @Return true when BlendTransforms equals the native Blend at 0.5
	 */
	UFUNCTION()
	bool BlendTransformsNominal()
	{
		FTransform A = FTransform(FVector(0, 0, 0));
		FTransform B = FTransform(FVector(100, 100, 100));
		FTransform Expected;
		Expected.Blend(A, B, 0.5f);
		return BlendTransforms().Equals(Expected, 0.01);
	}

	/**
	 * Observe that Blend at zero keeps the first transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Interpolation
	 * @Inputs none
	 * @Return true when BlendAtZero equals (100, 200, 300)
	 */
	UFUNCTION()
	bool BlendAtZeroNominal()
	{
		return BlendAtZero().Equals(FTransform(FVector(100, 200, 300)), 0.01);
	}

	/**
	 * Observe that Blend at one keeps the second transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Interpolation
	 * @Inputs none
	 * @Return true when BlendAtOne equals (400, 500, 600)
	 */
	UFUNCTION()
	bool BlendAtOneNominal()
	{
		return BlendAtOne().Equals(FTransform(FVector(400, 500, 600)), 0.01);
	}

	/**
	 * Observe that the scaled blend matches the native Blend.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Interpolation
	 * @Inputs none
	 * @Return true when BlendWithScale equals the native Blend at 0.5
	 */
	UFUNCTION()
	bool BlendWithScaleNominal()
	{
		FTransform A = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(1, 1, 1));
		FTransform B = FTransform(FQuat::Identity, FVector(100, 0, 0), FVector(3, 3, 3));
		FTransform Expected;
		Expected.Blend(A, B, 0.5f);
		return BlendWithScale().Equals(Expected, 0.01);
	}

	/**
	 * Observe that blending identity with itself stays at identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Interpolation
	 * @Inputs two identity transforms
	 * @Return true when the blend equals identity
	 * @Boundary default value
	 */
	UFUNCTION()
	bool BlendTransformsDefaultIdentity()
	{
		FTransform A = FTransform();
		FTransform B = FTransform::Identity;
		FTransform Result;
		Result.Blend(A, B, 0.5f);
		return Result.Equals(FTransform::Identity, 0.01);
	}

	/**
	 * Observe that mutating the blend leaves the inputs untouched.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Interpolation
	 * @Inputs A, B and a mutated blend
	 * @Return true when A still reads (0,0,0) and B still reads (100,100,100)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BlendTransformsCopyIndependence()
	{
		FTransform A = FTransform(FVector(0, 0, 0));
		FTransform B = FTransform(FVector(100, 100, 100));
		FTransform Result;
		Result.Blend(A, B, 0.5f);
		Result.SetLocation(FVector::ZeroVector);

		if (!A.GetLocation().Equals(FVector(0, 0, 0), 0.001))
		{
			return false;
		}
		return B.GetLocation().Equals(FVector(100, 100, 100), 0.001);
	}
}
