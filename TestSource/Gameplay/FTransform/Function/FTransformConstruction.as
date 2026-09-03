/**
 * The FTransform construction and accessor paths from the geometric-struct coverage:
 * default, identity, location-only and full construction, plus GetLocation, GetRotation,
 * GetScale3D, SetLocation and SetScale3D. C++ executes each entrypoint and compares the
 * result with the native equivalent, so those names are part of the contract and are kept
 * verbatim. The observers cover the empty identity and the independence of a copy.
 *
 * @Theme Gameplay.FTransform
 * @Subject FTransform.GeometricConstruction
 * @Harness Function
 * @Tag Gameplay.FTransform.FTransformConstruction
 * @Namespace FTransformTest
 * @Provenance Theme: Gameplay.FTransform. Positive construction and accessor oracles.
 * @Provenance C++: AngelscriptCoverageMathGeometricStructs.cpp::FTransformConstruction
 * @Provenance Oracle: default/Identity Equals Identity; location-only (100,200,300);
 * @Provenance full construction location (100,200,300) scale (2,2,2); GetLocation
 * @Provenance (100,200,300); GetRotation != Identity; GetScale (2,3,4);
 * @Provenance SetLocation (50,100,150); SetScale (3,3,3). Extra: empty Identity;
 * @Provenance copy independence of location-only. DefaultSafe.
 */

namespace FTransformTest
{
	/**
	 * Construct a transform with no arguments.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return FTransform()
	 * @Boundary default constructor
	 */
	UFUNCTION()
	FTransform TestDefaultConstruction()
	{
		return FTransform();
	}

	/**
	 * Read the identity constant.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return FTransform::Identity
	 */
	UFUNCTION()
	FTransform TestIdentity()
	{
		return FTransform::Identity;
	}

	/**
	 * Construct a transform from a translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return FTransform(FVector(100, 200, 300))
	 */
	UFUNCTION()
	FTransform TestLocationOnly()
	{
		return FTransform(FVector(100, 200, 300));
	}

	/**
	 * Construct a transform from a yaw, a location and a uniform scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return FTransform(yaw 90, (100, 200, 300), (2, 2, 2))
	 */
	UFUNCTION()
	FTransform TestFullConstruction()
	{
		FQuat rot = FQuat(FRotator(0, 90, 0));
		FVector loc = FVector(100, 200, 300);
		FVector scale = FVector(2, 2, 2);
		return FTransform(rot, loc, scale);
	}

	/**
	 * Read the translation of a known transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return (100, 200, 300)
	 */
	UFUNCTION()
	FVector TestGetLocation()
	{
		FTransform t = FTransform(FVector(100, 200, 300));
		return t.GetLocation();
	}

	/**
	 * Read the rotation of a yaw-90 transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return the quaternion for a ninety degree yaw
	 */
	UFUNCTION()
	FQuat TestGetRotation()
	{
		FQuat rot = FQuat(FRotator(0, 90, 0));
		FTransform t = FTransform(rot, FVector::ZeroVector, FVector(1,1,1));
		return t.GetRotation();
	}

	/**
	 * Read the scale of a known transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return (2, 3, 4)
	 */
	UFUNCTION()
	FVector TestGetScale()
	{
		FTransform t = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 3, 4));
		return t.GetScale3D();
	}

	/**
	 * Write a translation onto the identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return identity with location (50, 100, 150)
	 */
	UFUNCTION()
	FTransform TestSetLocation()
	{
		FTransform t = FTransform::Identity;
		t.SetLocation(FVector(50, 100, 150));
		return t;
	}

	/**
	 * Write a uniform scale onto the identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return identity with scale (3, 3, 3)
	 */
	UFUNCTION()
	FTransform TestSetScale()
	{
		FTransform t = FTransform::Identity;
		t.SetScale3D(FVector(3, 3, 3));
		return t;
	}

	/**
	 * Observe that the default constructor yields the identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return true when the default equals identity
	 */
	UFUNCTION()
	bool DefaultConstructionIsIdentity()
	{
		return TestDefaultConstruction().Equals(FTransform::Identity, 0.001);
	}

	/**
	 * Observe that the identity constant equals identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return true when TestIdentity equals identity
	 */
	UFUNCTION()
	bool IdentityConstantHolds()
	{
		return TestIdentity().Equals(FTransform::Identity, 0.001);
	}

	/**
	 * Observe that the location-only constructor keeps its translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return true when the location is (100, 200, 300)
	 */
	UFUNCTION()
	bool LocationOnlyNominal()
	{
		return TestLocationOnly().GetLocation().Equals(FVector(100, 200, 300), 0.001);
	}

	/**
	 * Observe that full construction keeps location and scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return true when location is (100, 200, 300) and scale is (2, 2, 2)
	 */
	UFUNCTION()
	bool FullConstructionNominal()
	{
		FTransform Result = TestFullConstruction();

		if (!Result.GetLocation().Equals(FVector(100, 200, 300), 0.001))
		{
			return false;
		}
		return Result.GetScale3D().Equals(FVector(2, 2, 2), 0.001);
	}

	/**
	 * Observe that GetLocation reads the constructed translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return true when GetLocation is (100, 200, 300)
	 */
	UFUNCTION()
	bool GeometricGetLocationNominal()
	{
		return TestGetLocation().Equals(FVector(100, 200, 300), 0.001);
	}

	/**
	 * Observe that GetRotation of a yaw-90 transform is not identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return true when GetRotation is not identity
	 */
	UFUNCTION()
	bool GetRotationNotIdentity()
	{
		return !TestGetRotation().Equals(FQuat::Identity, 0.001);
	}

	/**
	 * Observe that GetScale3D reads the constructed scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return true when the scale is (2, 3, 4)
	 */
	UFUNCTION()
	bool GeometricGetScaleNominal()
	{
		return TestGetScale().Equals(FVector(2, 3, 4), 0.001);
	}

	/**
	 * Observe that SetLocation writes the translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return true when the location is (50, 100, 150)
	 */
	UFUNCTION()
	bool GeometricSetLocationNominal()
	{
		return TestSetLocation().GetLocation().Equals(FVector(50, 100, 150), 0.001);
	}

	/**
	 * Observe that SetScale3D writes the scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs none
	 * @Return true when the scale is (3, 3, 3)
	 */
	UFUNCTION()
	bool GeometricSetScaleNominal()
	{
		return TestSetScale().GetScale3D().Equals(FVector(3, 3, 3), 0.001);
	}

	/**
	 * Observe that a default transform is identity with a zero location.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs a default-constructed transform
	 * @Return true when it equals identity and its location is zero
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultConstructionEmptyIdentity()
	{
		FTransform Empty = FTransform();

		if (!Empty.Equals(FTransform::Identity, 0.001))
		{
			return false;
		}
		return Empty.GetLocation().Equals(FVector::ZeroVector, 0.001);
	}

	/**
	 * Observe that mutating a copy leaves the location-only result untouched.
	 *
	 * @Kind Observe
	 * @Covers FTransform.GeometricConstruction
	 * @Inputs the location-only result and a mutated copy of it
	 * @Return true when the original still reads (100, 200, 300) and the copy is zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool LocationOnlyCopyIndependence()
	{
		FTransform Original = TestLocationOnly();
		FTransform Copy = Original;
		Copy.SetLocation(FVector::ZeroVector);

		if (!Original.GetLocation().Equals(FVector(100, 200, 300), 0.001))
		{
			return false;
		}
		return Copy.GetLocation().Equals(FVector::ZeroVector, 0.001);
	}
}
