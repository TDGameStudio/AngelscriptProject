/**
 * The FVector dot and cross products: an orthogonal pair, a general pair, and the cross
 * of the forward and right axes. C++ executes each entrypoint and compares the result
 * with the native equivalent, so those names are part of the contract and are kept
 * verbatim. The observers cover the empty vector and the independence of the inputs.
 *
 * @Theme Gameplay.FVector
 * @Subject FVector.DotAndCross
 * @Harness Function
 * @Tag Gameplay.FVector.FVectorDotAndCross
 * @Namespace FVectorTest
 * @Provenance Theme: Gameplay.FVector. Positive DotProduct/CrossProduct oracles.
 * @Provenance C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorDotAndCross
 * @Provenance Oracle: DotProduct orthogonal 0.0; DotProductGeneral 56.0;
 * @Provenance CrossProduct (0,0,1). Extra: empty ZeroVector dot 0; copy independence of
 * @Provenance CrossProduct inputs. DefaultSafe.
 */

namespace FVectorTest
{
	/**
	 * Take the dot product of two orthogonal axes.
	 *
	 * @Kind Observe
	 * @Covers FVector.DotAndCross
	 * @Inputs none
	 * @Return 0
	 */
	UFUNCTION()
	float DotProduct()
	{
		FVector a = FVector(1, 0, 0);
		FVector b = FVector(0, 1, 0);
		return a.DotProduct(b);
	}

	/**
	 * Take the dot product of two general vectors.
	 *
	 * @Kind Observe
	 * @Covers FVector.DotAndCross
	 * @Inputs none
	 * @Return 56
	 */
	UFUNCTION()
	float DotProductGeneral()
	{
		FVector a = FVector(2, 3, 4);
		FVector b = FVector(5, 6, 7);
		return a.DotProduct(b);
	}

	/**
	 * Take the cross product of the forward and right axes.
	 *
	 * @Kind Observe
	 * @Covers FVector.DotAndCross
	 * @Inputs none
	 * @Return FVector(0, 0, 1)
	 */
	UFUNCTION()
	FVector CrossProduct()
	{
		FVector a = FVector(1, 0, 0);
		FVector b = FVector(0, 1, 0);
		return a.CrossProduct(b);
	}

	/**
	 * Observe that orthogonal vectors have a zero dot product.
	 *
	 * @Kind Observe
	 * @Covers FVector.DotAndCross
	 * @Inputs none
	 * @Return true when the dot product is 0
	 */
	UFUNCTION()
	bool DotProductNominal()
	{
		return Math::IsNearlyEqual(DotProduct(), 0.0);
	}

	/**
	 * Observe that the general dot product matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.DotAndCross
	 * @Inputs none
	 * @Return true when the dot product is 56
	 */
	UFUNCTION()
	bool DotProductGeneralNominal()
	{
		return Math::IsNearlyEqual(DotProductGeneral(), 56.0);
	}

	/**
	 * Observe that the cross product matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.DotAndCross
	 * @Inputs none
	 * @Return true when the result equals FVector(0, 0, 1)
	 */
	UFUNCTION()
	bool CrossProductNominal()
	{
		return CrossProduct().Equals(FVector(0, 0, 1));
	}

	/**
	 * Observe that dotting an empty vector with the zero vector gives zero.
	 *
	 * @Kind Observe
	 * @Covers FVector.DotAndCross
	 * @Inputs a default-constructed vector
	 * @Return true when the dot product is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DotProductDefaultEmpty()
	{
		FVector Empty = FVector();
		return Math::IsNearlyEqual(Empty.DotProduct(FVector::ZeroVector), 0.0);
	}

	/**
	 * Observe that mutating a cross product leaves both operands untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector.DotAndCross
	 * @Inputs two axes and their mutated cross product
	 * @Return true when both operands still hold their original values
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CrossProductCopyIndependence()
	{
		FVector A = FVector(1, 0, 0);
		FVector B = FVector(0, 1, 0);
		FVector Cross = A.CrossProduct(B);
		Cross.Z = 0.0;

		if (!A.Equals(FVector(1, 0, 0)))
		{
			return false;
		}
		return B.Equals(FVector(0, 1, 0));
	}
}
