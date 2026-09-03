/**
 * The FVector measurement methods: Size, SizeSquared, GetSafeNormal, IsZero,
 * IsNearlyZero, Distance, DotProduct and CrossProduct. C++ executes each entrypoint and
 * compares the result with the native equivalent, so those names are part of the contract
 * and are kept verbatim. The observers cover the empty vector, the independence of the
 * normalization input and the non-zero boundary.
 *
 * @Theme Gameplay.FVector
 * @Subject FVector.Methods
 * @Harness Function
 * @Tag Gameplay.FVector.FVectorMethods
 * @Namespace FVectorTest
 * @Provenance Theme: Gameplay.FVector. Positive Size/GetSafeNormal/IsZero/Distance oracles.
 * @Provenance C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorMethods
 * @Provenance Oracle: Size 5.0; SizeSquared 25.0; GetSafeNormal (1,0,0); IsZero true;
 * @Provenance IsNearlyZero true; Distance 5.0; DotProduct 32.0; CrossProduct (0,0,1).
 * @Provenance Extra: empty ZeroVector Size 0; copy independence of GetSafeNormal input.
 * @Provenance DefaultSafe.
 */

namespace FVectorTest
{
	/**
	 * Measure the length of a 3-4-5 triangle's hypotenuse.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return 5
	 */
	UFUNCTION()
	float VectorLength()
	{
		FVector v = FVector(3, 4, 0);
		return v.Size();
	}

	/**
	 * Measure the squared length of a 3-4-5 triangle's hypotenuse.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return 25
	 */
	UFUNCTION()
	float VectorSquaredLength()
	{
		FVector v = FVector(3, 4, 0);
		return v.SizeSquared();
	}

	/**
	 * Normalize a vector that already lies on an axis.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return FVector(1, 0, 0)
	 */
	UFUNCTION()
	FVector VectorNormalize()
	{
		FVector v = FVector(5, 0, 0);
		return v.GetSafeNormal();
	}

	/**
	 * Ask whether the zero vector is zero.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool VectorIsZero()
	{
		FVector v = FVector::ZeroVector;
		return v.IsZero();
	}

	/**
	 * Ask whether a vector of tiny components is nearly zero.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool VectorIsNearlyZero()
	{
		FVector v = FVector(0.00001, 0.00001, 0.00001);
		return v.IsNearlyZero();
	}

	/**
	 * Measure the distance between the origin and a point.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return 5
	 */
	UFUNCTION()
	float VectorDistance()
	{
		FVector a = FVector(0, 0, 0);
		FVector b = FVector(3, 4, 0);
		return a.Distance(b);
	}

	/**
	 * Take the dot product of two populated vectors.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return 32
	 */
	UFUNCTION()
	float VectorDot()
	{
		FVector a = FVector(1, 2, 3);
		FVector b = FVector(4, 5, 6);
		return a.DotProduct(b);
	}

	/**
	 * Take the cross product of the forward and right axes.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return FVector(0, 0, 1)
	 */
	UFUNCTION()
	FVector VectorCross()
	{
		FVector a = FVector(1, 0, 0);
		FVector b = FVector(0, 1, 0);
		return a.CrossProduct(b);
	}

	/**
	 * Observe that the measured length matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return true when the length is 5
	 */
	UFUNCTION()
	bool VectorLengthNominal()
	{
		return Math::IsNearlyEqual(VectorLength(), 5.0);
	}

	/**
	 * Observe that the measured squared length matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return true when the squared length is 25
	 */
	UFUNCTION()
	bool VectorSquaredLengthNominal()
	{
		return Math::IsNearlyEqual(VectorSquaredLength(), 25.0);
	}

	/**
	 * Observe that normalization lands on the unit vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return true when the result equals FVector(1, 0, 0)
	 */
	UFUNCTION()
	bool VectorNormalizeNominal()
	{
		return VectorNormalize().Equals(FVector(1, 0, 0));
	}

	/**
	 * Observe that the zero vector reports itself as zero.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return true when the flag is set
	 */
	UFUNCTION()
	bool VectorIsZeroNominal()
	{
		return VectorIsZero();
	}

	/**
	 * Observe that a vector of tiny components reports itself as nearly zero.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return true when the flag is set
	 */
	UFUNCTION()
	bool VectorIsNearlyZeroNominal()
	{
		return VectorIsNearlyZero();
	}

	/**
	 * Observe that the measured distance matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return true when the distance is 5
	 */
	UFUNCTION()
	bool VectorDistanceNominal()
	{
		return Math::IsNearlyEqual(VectorDistance(), 5.0);
	}

	/**
	 * Observe that the dot product matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return true when the dot product is 32
	 */
	UFUNCTION()
	bool VectorDotNominal()
	{
		return Math::IsNearlyEqual(VectorDot(), 32.0);
	}

	/**
	 * Observe that the cross product matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs none
	 * @Return true when the result equals FVector(0, 0, 1)
	 */
	UFUNCTION()
	bool VectorCrossNominal()
	{
		return VectorCross().Equals(FVector(0, 0, 1));
	}

	/**
	 * Observe that an empty vector measures zero and reports itself as zero.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs a default-constructed vector
	 * @Return true when the size is 0 and the flag is set
	 * @Boundary default value
	 */
	UFUNCTION()
	bool VectorLengthDefaultEmpty()
	{
		FVector Empty = FVector();

		if (!Math::IsNearlyEqual(Empty.Size(), 0.0))
		{
			return false;
		}
		return Empty.IsZero();
	}

	/**
	 * Observe that normalizing takes a copy, leaving the caller's vector alone.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs a vector and its mutated normalized copy
	 * @Return true when the source still reads FVector(5, 0, 0)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool VectorNormalizeCopyIndependence()
	{
		FVector V = FVector(5, 0, 0);
		FVector Normal = V.GetSafeNormal();
		Normal.X = 0.0;
		return V.Equals(FVector(5, 0, 0));
	}

	/**
	 * Observe that a populated vector does not report itself as zero.
	 *
	 * @Kind Observe
	 * @Covers FVector.Methods
	 * @Inputs a vector along the X axis
	 * @Return true when the flag is clear
	 * @Boundary non-zero
	 */
	UFUNCTION()
	bool VectorIsZeroFalseBoundary()
	{
		return !FVector(1, 0, 0).IsZero();
	}
}
