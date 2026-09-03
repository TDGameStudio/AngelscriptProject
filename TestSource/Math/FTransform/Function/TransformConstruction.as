/**
 * The FTransform construction paths: the default constructor, the identity constant,
 * construction from a location, construction from rotation location and scale, and
 * construction from a rotator and a location. C++ executes each entrypoint and compares
 * the result with the native equivalent, so those names are part of the contract and are
 * kept verbatim. The observers cover the empty default and the independence of a copy.
 *
 * @Theme Math.FTransform
 * @Subject FTransform.Construction
 * @Harness Function
 * @Tag Math.FTransform.TransformConstruction
 * @Namespace FTransformTest
 * @Provenance Theme: Gameplay.FTransform. Positive construction oracles.
 * @Provenance C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformConstruction
 * @Provenance Oracle: default Identity; Identity; Location (100,200,300);
 * @Provenance Full (Identity, (10,20,30), (2,2,2)); Rotator+Location (0,90,0)+(50,100,150).
 * @Provenance Extra: default GetLocation Zero; copy independence of location ctor. DefaultSafe.
 */

namespace FTransformTest
{
	/**
	 * Construct a transform with no arguments.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Construction
	 * @Inputs none
	 * @Return FTransform(), which should be the identity
	 * @Boundary default constructor
	 */
	UFUNCTION()
	FTransform ConstructDefault()
	{
		return FTransform();
	}

	/**
	 * Read the identity constant.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Construction
	 * @Inputs none
	 * @Return FTransform::Identity
	 */
	UFUNCTION()
	FTransform ConstructIdentity()
	{
		return FTransform::Identity;
	}

	/**
	 * Construct a transform from a translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Construction
	 * @Inputs none
	 * @Return FTransform(FVector(100, 200, 300))
	 */
	UFUNCTION()
	FTransform ConstructLocation()
	{
		return FTransform(FVector(100, 200, 300));
	}

	/**
	 * Construct a transform from rotation, location and scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Construction
	 * @Inputs none
	 * @Return FTransform(Identity, (10, 20, 30), (2, 2, 2))
	 */
	UFUNCTION()
	FTransform ConstructFull()
	{
		return FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 2, 2));
	}

	/**
	 * Construct a transform from a rotator and a location.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Construction
	 * @Inputs none
	 * @Return the transform for a ninety degree yaw at (50, 100, 150)
	 */
	UFUNCTION()
	FTransform ConstructRotationAndLocation()
	{
		FRotator Rot = FRotator(0, 90, 0);  // Yaw 90 degrees
		return FTransform(Rot, FVector(50, 100, 150));
	}

	/**
	 * Observe that the default constructor yields the identity transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Construction
	 * @Inputs none
	 * @Return true when the default equals the identity constant
	 */
	UFUNCTION()
	bool DefaultIsIdentity()
	{
		return ConstructDefault().Equals(FTransform::Identity, 0.001);
	}

	/**
	 * Observe that reading the identity constant yields the identity transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Construction
	 * @Inputs none
	 * @Return true when the result equals the identity constant
	 */
	UFUNCTION()
	bool IdentityNominal()
	{
		return ConstructIdentity().Equals(FTransform::Identity, 0.001);
	}

	/**
	 * Observe that the location constructor keeps its translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Construction
	 * @Inputs none
	 * @Return true when the result equals FTransform(FVector(100, 200, 300))
	 */
	UFUNCTION()
	bool LocationNominal()
	{
		return ConstructLocation().Equals(FTransform(FVector(100, 200, 300)), 0.001);
	}

	/**
	 * Observe that the full constructor keeps rotation, location and scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Construction
	 * @Inputs none
	 * @Return true when the result equals FTransform(Identity, (10, 20, 30), (2, 2, 2))
	 */
	UFUNCTION()
	bool FullNominal()
	{
		return ConstructFull().Equals(FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 2, 2)), 0.001);
	}

	/**
	 * Observe that construction from a rotator and a location matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Construction
	 * @Inputs none
	 * @Return true when the result equals FTransform(Rotator(0, 90, 0), (50, 100, 150))
	 */
	UFUNCTION()
	bool RotationAndLocationNominal()
	{
		FRotator Rot = FRotator(0, 90, 0);
		return ConstructRotationAndLocation().Equals(FTransform(Rot, FVector(50, 100, 150)), 0.001);
	}

	/**
	 * Observe that a default transform has a zero translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Construction
	 * @Inputs a default-constructed transform
	 * @Return true when GetLocation equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmptyLocation()
	{
		return ConstructDefault().GetLocation().Equals(FVector::ZeroVector, 0.001);
	}

	/**
	 * Observe that mutating a copy leaves the location-constructed result untouched.
	 *
	 * @Kind Observe
	 * @Covers FTransform.Construction
	 * @Inputs the location result and a mutated copy of it
	 * @Return true when the original still reads (100, 200, 300)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool LocationCopyIndependence()
	{
		FTransform Original = ConstructLocation();
		FTransform Copy = Original;
		Copy.SetLocation(FVector::ZeroVector);
		return Original.GetLocation().Equals(FVector(100, 200, 300), 0.001);
	}
}
