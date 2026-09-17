/**
 * @version v1
 * @summary The FVector2D dot product: an orthogonal pair, a parallel pair, and a general pair. C++ executes each entrypoint and compares the result with the native equivalent, so those names are part of the contract and are kept.
 * @topic Math
 */
/**
 * @version root
 * @summary The FVector2D dot product: an orthogonal pair, a parallel pair, and a general pair. C++ executes each entrypoint and compares the result with the native equivalent, so those names are part of the contract and are kept.
 * @topic Baseline
 */
namespace FVector2DTest
{
	/**
	 * Take the dot product of two orthogonal axes.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.DotProduct
	 * @Inputs none
	 * @Return 0
	 */
	UFUNCTION()
	float DotProductOrthogonal()
	{
		FVector2D a = FVector2D(1.0, 0.0);
		FVector2D b = FVector2D(0.0, 1.0);
		return a.DotProduct(b);
	}

	/**
	 * Take the dot product of two parallel vectors.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.DotProduct
	 * @Inputs none
	 * @Return 50
	 */
	UFUNCTION()
	float DotProductParallel()
	{
		FVector2D a = FVector2D(3.0, 4.0);
		FVector2D b = FVector2D(6.0, 8.0);
		return a.DotProduct(b);
	}

	/**
	 * Take the dot product of two general vectors.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.DotProduct
	 * @Inputs none
	 * @Return 23
	 */
	UFUNCTION()
	float DotProductGeneral()
	{
		FVector2D a = FVector2D(2.0, 3.0);
		FVector2D b = FVector2D(4.0, 5.0);
		return a.DotProduct(b);
	}

	/**
	 * Observe that orthogonal vectors have a zero dot product.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.DotProduct
	 * @Inputs none
	 * @Return true when the dot product is 0
	 */
	UFUNCTION()
	bool DotProductOrthogonalNominal()
	{
		return Math::IsNearlyEqual(DotProductOrthogonal(), 0.0);
	}

	/**
	 * Observe that the parallel dot product matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.DotProduct
	 * @Inputs none
	 * @Return true when the dot product is 50
	 */
	UFUNCTION()
	bool DotProductParallelNominal()
	{
		return Math::IsNearlyEqual(DotProductParallel(), 50.0);
	}

	/**
	 * Observe that the general dot product matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.DotProduct
	 * @Inputs none
	 * @Return true when the dot product is 23
	 */
	UFUNCTION()
	bool DotProductGeneralNominal()
	{
		return Math::IsNearlyEqual(DotProductGeneral(), 23.0);
	}

	/**
	 * Observe that dotting an empty vector with the zero vector gives zero.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.DotProduct
	 * @Inputs a default-constructed vector
	 * @Return true when the dot product is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DotProductDefaultEmpty()
	{
		FVector2D Empty = FVector2D();
		return Math::IsNearlyEqual(Empty.DotProduct(FVector2D::ZeroVector), 0.0);
	}

	/**
	 * Observe that mutating one operand after a parallel dot leaves the stored product
	 * and the other operand untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.DotProduct
	 * @Inputs two vectors and their stored parallel dot product
	 * @Return true when the stored product is 50 and the second operand is unchanged
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool DotProductParallelCopyIndependence()
	{
		FVector2D A = FVector2D(3.0, 4.0);
		FVector2D B = FVector2D(6.0, 8.0);
		float Dot = A.DotProduct(B);
		A.X = 0.0;

		if (!Math::IsNearlyEqual(Dot, 50.0))
		{
			return false;
		}
		return B.Equals(FVector2D(6.0, 8.0));
	}
}
/** @end */
