/**
 * The FQuat construction paths: the default constructor, the four-parameter
 * constructor, the identity constant, construction from a rotator, and construction
 * from an axis and an angle. C++ executes each entrypoint and compares the result with
 * the native equivalent, so those names are part of the contract and are kept verbatim.
 *
 * @Theme Gameplay.FQuat
 * @Subject FQuat.Construction
 * @Harness Function
 * @Tag Gameplay.FQuat.QuatConstruction
 * @Namespace FQuatTest
 * @Provenance Theme: Gameplay.FQuat. Positive construction oracles.
 * @Provenance C++: AngelscriptCoverageFQuatExpressionTests.cpp::QuatConstruction
 * @Provenance Oracle: default Identity; four-param (0,0,0,1); Identity; from FRotator(0,90,0);
 * @Provenance from UpVector / 1.5708.
 * @Provenance Extra: default empty Identity; copy independence of four-param. DefaultSafe.
 */

namespace FQuatTest
{
	/**
	 * Construct a quaternion with no arguments.
	 *
	 * @Kind Observe
	 * @Covers FQuat.Construction
	 * @Inputs none
	 * @Return FQuat(), which should be the identity
	 * @Boundary default constructor
	 */
	UFUNCTION()
	FQuat ConstructDefault()
	{
		return FQuat();
	}

	/**
	 * Construct a quaternion from four components.
	 *
	 * @Kind Observe
	 * @Covers FQuat.Construction
	 * @Inputs none
	 * @Return FQuat(0, 0, 0, 1)
	 */
	UFUNCTION()
	FQuat ConstructFourParams()
	{
		return FQuat(0, 0, 0, 1);
	}

	/**
	 * Read the identity constant.
	 *
	 * @Kind Observe
	 * @Covers FQuat.Construction
	 * @Inputs none
	 * @Return FQuat::Identity
	 */
	UFUNCTION()
	FQuat ConstructIdentity()
	{
		return FQuat::Identity;
	}

	/**
	 * Construct a quaternion from a rotator.
	 *
	 * @Kind Observe
	 * @Covers FQuat.Construction
	 * @Inputs none
	 * @Return the quaternion for a ninety degree yaw
	 */
	UFUNCTION()
	FQuat ConstructFromRotator()
	{
		return FQuat(FRotator(0, 90, 0));
	}

	/**
	 * Construct a quaternion from an axis and an angle in radians.
	 *
	 * @Kind Observe
	 * @Covers FQuat.Construction
	 * @Inputs none
	 * @Return the quaternion for a ninety degree turn about the up axis
	 */
	UFUNCTION()
	FQuat ConstructFromAxisAngle()
	{
		FVector axis = FVector::UpVector;
		float angleRad = 1.5708; // 90 degrees in radians
		return FQuat(axis, angleRad);
	}

	/**
	 * Observe that the default constructor yields the identity rotation.
	 *
	 * @Kind Observe
	 * @Covers FQuat.Construction
	 * @Inputs none
	 * @Return true when the default equals the identity constant
	 */
	UFUNCTION()
	bool DefaultIsIdentity()
	{
		return ConstructDefault().Equals(FQuat::Identity, 0.001);
	}

	/**
	 * Observe that the four-parameter constructor keeps its components.
	 *
	 * @Kind Observe
	 * @Covers FQuat.Construction
	 * @Inputs none
	 * @Return true when the result equals FQuat(0, 0, 0, 1)
	 */
	UFUNCTION()
	bool FourParamsNominal()
	{
		return ConstructFourParams().Equals(FQuat(0, 0, 0, 1), 0.001);
	}

	/**
	 * Observe that reading the identity constant yields the identity rotation.
	 *
	 * @Kind Observe
	 * @Covers FQuat.Construction
	 * @Inputs none
	 * @Return true when the result equals the identity constant
	 */
	UFUNCTION()
	bool IdentityNominal()
	{
		return ConstructIdentity().Equals(FQuat::Identity, 0.001);
	}

	/**
	 * Observe that construction from a rotator matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FQuat.Construction
	 * @Inputs none
	 * @Return true when the result equals FQuat(FRotator(0, 90, 0))
	 */
	UFUNCTION()
	bool FromRotatorNominal()
	{
		return ConstructFromRotator().Equals(FQuat(FRotator(0, 90, 0)), 0.01);
	}

	/**
	 * Observe that construction from an axis and angle matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FQuat.Construction
	 * @Inputs none
	 * @Return true when the result equals FQuat(UpVector, 1.5708)
	 */
	UFUNCTION()
	bool FromAxisAngleNominal()
	{
		return ConstructFromAxisAngle().Equals(FQuat(FVector::UpVector, 1.5708), 0.01);
	}

	/**
	 * Observe that a default quaternion compares equal to the identity constant.
	 *
	 * @Kind Observe
	 * @Covers FQuat.Construction
	 * @Inputs a default-constructed quaternion
	 * @Return true when it equals the identity constant
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmptyIsIdentity()
	{
		FQuat Empty = FQuat();
		return Empty == FQuat::Identity;
	}

	/**
	 * Observe that mutating a copy leaves the four-parameter result untouched.
	 *
	 * @Kind Observe
	 * @Covers FQuat.Construction
	 * @Inputs the four-parameter result and a mutated copy of it
	 * @Return true when the original still equals FQuat(0, 0, 0, 1) and the copy holds 0.5
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool FourParamsCopyIndependence()
	{
		FQuat Original = ConstructFourParams();
		FQuat Copy = Original;
		Copy.X = 0.5;

		if (!Original.Equals(FQuat(0, 0, 0, 1), 0.001))
		{
			return false;
		}
		return Copy.X == 0.5;
	}
}
