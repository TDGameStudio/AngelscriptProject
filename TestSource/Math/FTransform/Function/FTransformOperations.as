/**
 * The FTransform operation paths from the geometric-struct coverage: composition,
 * TransformPosition, TransformVector, inverse transforms, ScaleTranslation, Blend,
 * EqualsNoScale, translation helpers, SetTranslationAndScale3D, Rotator conversion,
 * validity helpers and axis-scale sums. C++ executes each entrypoint and checks the
 * value it produces, so those names are part of the contract and are kept verbatim.
 *
 * @Theme Math.FTransform
 * @Subject FTransform.GeometricOperations
 * @Harness Function
 * @Tag Math.FTransform.FTransformOperations
 * @Namespace FTransformTest
 * @Provenance Theme: Gameplay.FTransform. Positive transform operation oracles.
 * @Provenance C++: AngelscriptCoverageMathGeometricStructs.cpp::FTransformOperations
 * @Provenance Oracle vectors: multiply (10,20,0); TransformPosition (12,24,36);
 * @Provenance TransformVector (2,6,12); InverseTransformPosition (1,2,3);
 * @Provenance InverseTransformRoundTrip (3,4,5); TransformPositionNoScale (11,22,33);
 * @Provenance InverseTransformVector (2,2,2); InverseTransformVectorNoScale (4,8,10);
 * @Provenance ScaleTranslationAndAdd (21,42,63); BlendLocation (5,10,15).
 * @Provenance Bools true; TestAxisScale 7.0. Extra: empty Identity location (0,0,0);
 * @Provenance copy independence of Blend inputs. DefaultSafe.
 */

namespace FTransformTest
{
	/**
	 * Compose two translations and read the product location.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return (10, 20, 0)
	 */
	UFUNCTION()
	FVector TestMultiplyTransformLocation()
	{
		FTransform First = FTransform(FVector(10, 0, 0));
		FTransform Second = FTransform(FVector(0, 20, 0));
		FTransform Combined = First * Second;
		return Combined.GetLocation();
	}

	/**
	 * Transform a local point through translation and uniform scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return TransformPosition of (1, 2, 3)
	 */
	UFUNCTION()
	FVector TestTransformPosition()
	{
		FTransform Transform = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 2, 2));
		return Transform.TransformPosition(FVector(1, 2, 3));
	}

	/**
	 * Transform a local vector through a non-uniform scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return TransformVector of (1, 2, 3)
	 */
	UFUNCTION()
	FVector TestTransformVector()
	{
		FTransform Transform = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
		return Transform.TransformVector(FVector(1, 2, 3));
	}

	/**
	 * Inverse-transform a world point through translation and uniform scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return InverseTransformPosition of (12, 24, 36)
	 */
	UFUNCTION()
	FVector TestInverseTransformPosition()
	{
		FTransform Transform = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 2, 2));
		return Transform.InverseTransformPosition(FVector(12, 24, 36));
	}

	/**
	 * Round-trip a local point through TransformPosition and Inverse.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return the original local point (3, 4, 5)
	 */
	UFUNCTION()
	FVector TestInverseTransformRoundTrip()
	{
		FTransform Transform = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
		FVector Local = FVector(3, 4, 5);
		return Transform.Inverse().TransformPosition(Transform.TransformPosition(Local));
	}

	/**
	 * Transform a local point ignoring scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return TransformPositionNoScale of (1, 2, 3)
	 */
	UFUNCTION()
	FVector TestTransformPositionNoScale()
	{
		FTransform Transform = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 3, 4));
		return Transform.TransformPositionNoScale(FVector(1, 2, 3));
	}

	/**
	 * Inverse-transform a world vector through a non-uniform scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return InverseTransformVector of (4, 8, 10)
	 */
	UFUNCTION()
	FVector TestInverseTransformVector()
	{
		FTransform Transform = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 4, 5));
		return Transform.InverseTransformVector(FVector(4, 8, 10));
	}

	/**
	 * Inverse-transform a world vector ignoring scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return InverseTransformVectorNoScale of (4, 8, 10)
	 */
	UFUNCTION()
	FVector TestInverseTransformVectorNoScale()
	{
		FTransform Transform = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 4, 5));
		return Transform.InverseTransformVectorNoScale(FVector(4, 8, 10));
	}

	/**
	 * Scale a translation then add an offset.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return (21, 42, 63)
	 */
	UFUNCTION()
	FVector TestScaleTranslationAndAdd()
	{
		FTransform Transform = FTransform(FVector(10, 20, 30));
		Transform.ScaleTranslation(2.0);
		Transform.AddToTranslation(FVector(1, 2, 3));
		return Transform.GetTranslation();
	}

	/**
	 * Blend two translations at alpha 0.5.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return (5, 10, 15)
	 */
	UFUNCTION()
	FVector TestBlendLocation()
	{
		FTransform A = FTransform(FVector(0, 0, 0));
		FTransform B = FTransform(FVector(10, 20, 30));
		FTransform Result;
		Result.Blend(A, B, 0.5f);
		return Result.GetTranslation();
	}

	/**
	 * Compare two transforms that share rotation and translation but differ in scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool TestEqualsNoScale()
	{
		FTransform A = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(1, 1, 1));
		FTransform B = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(4, 5, 6));
		return A.EqualsNoScale(B, 0.001);
	}

	/**
	 * Compare translations and subtract them.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when TranslationEquals holds and the difference is (7, 15, 23)
	 */
	UFUNCTION()
	bool TestTranslationEqualsAndSubtract()
	{
		FTransform A = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(1, 1, 1));
		FTransform B = FTransform(FQuat::Identity, FVector(3, 5, 7), FVector(9, 9, 9));
		FVector Difference = A.SubtractTranslations(B);

		if (!A.TranslationEquals(FTransform(FVector(10, 20, 30)), 0.001))
		{
			return false;
		}
		return Difference.Equals(FVector(7, 15, 23), 0.001);
	}

	/**
	 * Write translation and scale together, then read the determinant.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when translation, scale and determinant match
	 */
	UFUNCTION()
	bool TestSetTranslationScaleAndDeterminant()
	{
		FTransform Transform = FTransform::Identity;
		Transform.SetTranslationAndScale3D(FVector(1, 2, 3), FVector(2, 3, 4));

		if (!Transform.GetTranslation().Equals(FVector(1, 2, 3), 0.001))
		{
			return false;
		}
		if (!Transform.GetScale3D().Equals(FVector(2, 3, 4), 0.001))
		{
			return false;
		}
		return Math::IsNearlyEqual(Transform.GetDeterminant(), 24.0, 0.001);
	}

	/**
	 * Convert a rotator-constructed transform back to a rotator.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when Pitch, Yaw and Roll read 10, 20 and 30
	 */
	UFUNCTION()
	bool TestRotatorConversion()
	{
		FTransform Transform = FTransform(FRotator(10, 20, 30));
		FRotator Rotator = Transform.Rotator();

		if (!Math::IsNearlyEqual(Rotator.Pitch, 10.0, 0.001))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(Rotator.Yaw, 20.0, 0.001))
		{
			return false;
		}
		return Math::IsNearlyEqual(Rotator.Roll, 30.0, 0.001);
	}

	/**
	 * Check IsValid and ContainsNaN on a well-formed transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when IsValid and not ContainsNaN
	 */
	UFUNCTION()
	bool TestValidityHelpers()
	{
		FTransform Transform = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(2, 2, 2));

		if (!Transform.IsValid())
		{
			return false;
		}
		return !Transform.ContainsNaN();
	}

	/**
	 * Sum the maximum and minimum axis scales.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return 7.0
	 */
	UFUNCTION()
	float TestAxisScale()
	{
		FTransform Transform = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 5, 3));
		return Transform.GetMaximumAxisScale() + Transform.GetMinimumAxisScale();
	}

	/**
	 * Observe that the composed location is (10, 20, 0).
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when the location is (10, 20, 0)
	 */
	UFUNCTION()
	bool MultiplyTransformLocationNominal()
	{
		return TestMultiplyTransformLocation().Equals(FVector(10, 20, 0), 0.001);
	}

	/**
	 * Observe that TransformPosition yields (12, 24, 36).
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when the result is (12, 24, 36)
	 */
	UFUNCTION()
	bool GeometricTransformPositionNominal()
	{
		return TestTransformPosition().Equals(FVector(12, 24, 36), 0.001);
	}

	/**
	 * Observe that TransformVector yields (2, 6, 12).
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when the result is (2, 6, 12)
	 */
	UFUNCTION()
	bool GeometricTransformVectorNominal()
	{
		return TestTransformVector().Equals(FVector(2, 6, 12), 0.001);
	}

	/**
	 * Observe that InverseTransformPosition recovers (1, 2, 3).
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when the result is (1, 2, 3)
	 */
	UFUNCTION()
	bool GeometricInverseTransformPositionNominal()
	{
		return TestInverseTransformPosition().Equals(FVector(1, 2, 3), 0.001);
	}

	/**
	 * Observe that the inverse round-trip recovers (3, 4, 5).
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when the result is (3, 4, 5)
	 */
	UFUNCTION()
	bool InverseTransformRoundTripNominal()
	{
		return TestInverseTransformRoundTrip().Equals(FVector(3, 4, 5), 0.001);
	}

	/**
	 * Observe that TransformPositionNoScale yields (11, 22, 33).
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when the result is (11, 22, 33)
	 */
	UFUNCTION()
	bool GeometricTransformPositionNoScaleNominal()
	{
		return TestTransformPositionNoScale().Equals(FVector(11, 22, 33), 0.001);
	}

	/**
	 * Observe that InverseTransformVector yields (2, 2, 2).
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when the result is (2, 2, 2)
	 */
	UFUNCTION()
	bool GeometricInverseTransformVectorNominal()
	{
		return TestInverseTransformVector().Equals(FVector(2, 2, 2), 0.001);
	}

	/**
	 * Observe that InverseTransformVectorNoScale yields (4, 8, 10).
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when the result is (4, 8, 10)
	 */
	UFUNCTION()
	bool GeometricInverseTransformVectorNoScaleNominal()
	{
		return TestInverseTransformVectorNoScale().Equals(FVector(4, 8, 10), 0.001);
	}

	/**
	 * Observe that ScaleTranslation then AddToTranslation yields (21, 42, 63).
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when the result is (21, 42, 63)
	 */
	UFUNCTION()
	bool ScaleTranslationAndAddNominal()
	{
		return TestScaleTranslationAndAdd().Equals(FVector(21, 42, 63), 0.001);
	}

	/**
	 * Observe that Blend at 0.5 yields (5, 10, 15).
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when the result is (5, 10, 15)
	 */
	UFUNCTION()
	bool BlendLocationNominal()
	{
		return TestBlendLocation().Equals(FVector(5, 10, 15), 0.001);
	}

	/**
	 * Observe that EqualsNoScale holds for matching translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when TestEqualsNoScale is true
	 */
	UFUNCTION()
	bool EqualsNoScaleHolds()
	{
		return TestEqualsNoScale() == true;
	}

	/**
	 * Observe that translation equality and subtraction hold.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when TestTranslationEqualsAndSubtract is true
	 */
	UFUNCTION()
	bool TranslationEqualsAndSubtractHolds()
	{
		return TestTranslationEqualsAndSubtract() == true;
	}

	/**
	 * Observe that SetTranslationAndScale3D and the determinant hold.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when TestSetTranslationScaleAndDeterminant is true
	 */
	UFUNCTION()
	bool SetTranslationScaleAndDeterminantHolds()
	{
		return TestSetTranslationScaleAndDeterminant() == true;
	}

	/**
	 * Observe that Rotator conversion keeps pitch, yaw and roll.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when TestRotatorConversion is true
	 */
	UFUNCTION()
	bool RotatorConversionHolds()
	{
		return TestRotatorConversion() == true;
	}

	/**
	 * Observe that validity helpers accept a well-formed transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when TestValidityHelpers is true
	 */
	UFUNCTION()
	bool ValidityHelpersHold()
	{
		return TestValidityHelpers() == true;
	}

	/**
	 * Observe that the axis-scale sum is 7.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs none
	 * @Return true when TestAxisScale is nearly 7
	 */
	UFUNCTION()
	bool AxisScaleNominal()
	{
		return Math::IsNearlyEqual(TestAxisScale(), 7.0, 0.001);
	}

	/**
	 * Observe that a default blend result has a zero translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs a default-constructed transform
	 * @Return true when the translation is zero
	 * @Boundary default value
	 */
	UFUNCTION()
	bool BlendLocationDefaultEmpty()
	{
		FTransform Result;
		return Result.GetTranslation().Equals(FVector::ZeroVector, 0.001);
	}

	/**
	 * Observe that mutating the blend leaves the inputs untouched.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs A, B and a mutated blend
	 * @Return true when A is still zero and B is still (10, 20, 30)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BlendLocationCopyIndependence()
	{
		FTransform A = FTransform(FVector(0, 0, 0));
		FTransform B = FTransform(FVector(10, 20, 30));
		FTransform Result;
		Result.Blend(A, B, 0.5f);
		Result.SetLocation(FVector::ZeroVector);

		if (!A.GetTranslation().Equals(FVector(0, 0, 0), 0.001))
		{
			return false;
		}
		return B.GetTranslation().Equals(FVector(10, 20, 30), 0.001);
	}

	/**
	 * Observe that EqualsNoScale is false when translations differ.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricOperations
	 * @Inputs two transforms with different translations
	 * @Return true when EqualsNoScale is false
	 * @Boundary differing translation
	 */
	UFUNCTION()
	bool EqualsNoScaleFalseBoundary()
	{
		FTransform A = FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(1, 1, 1));
		FTransform B = FTransform(FQuat::Identity, FVector(9, 9, 9), FVector(1, 1, 1));
		return A.EqualsNoScale(B, 0.001) == false;
	}
}
