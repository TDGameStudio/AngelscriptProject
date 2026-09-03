/**
 * The FTransform accessor and mutator methods: GetLocation, GetScale3D, SetLocation,
 * SetScale3D and SetRotation. Direct members are a separate compile-fail file. C++
 * executes each entrypoint and checks the value it produces, so those names are part of
 * the contract and are kept verbatim. The observers cover the empty default and the
 * independence of a copy.
 *
 * @Theme Gameplay.FTransform
 * @Subject FTransform.MemberAccess
 * @Harness Function
 * @Tag Gameplay.FTransform.TransformMemberAccess
 * @Namespace FTransformTest
 * @Provenance Theme: Gameplay.FTransform. Positive accessor/mutator oracles.
 * @Provenance C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformMemberAccess (compiling block)
 * @Provenance CSV Positive; C++ compiles GetLocation/GetScale/SetLocation/SetScale/SetRotation.
 * @Provenance Direct members are a separate CompileAndExpectFailure file (_02).
 * @Provenance Oracle: GetLocation (100,200,300); GetScale (2,3,4);
 * @Provenance SetLocation (10,20,30); SetScale Identity+(5,5,5); SetRotation yaw-90.
 * @Provenance Extra: default GetLocation Zero; copy independence of SetLocation. DefaultSafe.
 */

namespace FTransformTest
{
	/**
	 * Read the translation of a known transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs none
	 * @Return (100, 200, 300)
	 */
	UFUNCTION()
	FVector GetLocation()
	{
		FTransform T = FTransform(FVector(100, 200, 300));
		return T.GetLocation();
	}

	/**
	 * Read the scale of a known transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs none
	 * @Return (2, 3, 4)
	 */
	UFUNCTION()
	FVector GetScale()
	{
		FTransform T = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 3, 4));
		return T.GetScale3D();
	}

	/**
	 * Write a translation onto the identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs none
	 * @Return identity with location (10, 20, 30)
	 */
	UFUNCTION()
	FTransform SetLocation()
	{
		FTransform T = FTransform::Identity;
		T.SetLocation(FVector(10, 20, 30));
		return T;
	}

	/**
	 * Write a uniform scale onto the identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs none
	 * @Return identity with scale (5, 5, 5)
	 */
	UFUNCTION()
	FTransform SetScale()
	{
		FTransform T = FTransform::Identity;
		T.SetScale3D(FVector(5, 5, 5));
		return T;
	}

	/**
	 * Write a yaw-90 rotation onto the identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs none
	 * @Return identity with a ninety degree yaw
	 */
	UFUNCTION()
	FTransform SetRotation()
	{
		FTransform T = FTransform::Identity;
		T.SetRotation(FQuat(FRotator(0, 90, 0)));
		return T;
	}

	/**
	 * Observe that GetLocation reads the constructed translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs none
	 * @Return true when GetLocation equals (100, 200, 300)
	 */
	UFUNCTION()
	bool GetLocationNominal()
	{
		return GetLocation() == FVector(100, 200, 300);
	}

	/**
	 * Observe that GetScale3D reads the constructed scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs none
	 * @Return true when GetScale equals (2, 3, 4)
	 */
	UFUNCTION()
	bool GetScaleNominal()
	{
		return GetScale() == FVector(2, 3, 4);
	}

	/**
	 * Observe that SetLocation writes the translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs none
	 * @Return true when the result equals FTransform((10, 20, 30))
	 */
	UFUNCTION()
	bool SetLocationNominal()
	{
		return SetLocation().Equals(FTransform(FVector(10, 20, 30)), 0.001);
	}

	/**
	 * Observe that SetScale3D writes the scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs none
	 * @Return true when the result equals identity with scale (5, 5, 5)
	 */
	UFUNCTION()
	bool SetScaleNominal()
	{
		return SetScale().Equals(FTransform(FQuat::Identity, FVector::ZeroVector, FVector(5, 5, 5)), 0.001);
	}

	/**
	 * Observe that SetRotation writes the yaw.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs none
	 * @Return true when the result equals FTransform(Rotator(0, 90, 0), ZeroVector)
	 */
	UFUNCTION()
	bool SetRotationNominal()
	{
		return SetRotation().Equals(FTransform(FRotator(0, 90, 0), FVector::ZeroVector), 0.001);
	}

	/**
	 * Observe that a default transform has a zero translation.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs a default-constructed transform
	 * @Return true when GetLocation is the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool GetLocationDefaultEmpty()
	{
		return FTransform().GetLocation().Equals(FVector::ZeroVector, 0.001);
	}

	/**
	 * Observe that mutating a copy leaves the source transform untouched.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs an identity transform and a mutated copy of it
	 * @Return true when the source is still zero and the copy reads (10, 20, 30)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool SetLocationCopyIndependence()
	{
		FTransform T = FTransform::Identity;
		FTransform Mutated = T;
		Mutated.SetLocation(FVector(10, 20, 30));

		if (!T.GetLocation().Equals(FVector::ZeroVector, 0.001))
		{
			return false;
		}
		return Mutated.GetLocation().Equals(FVector(10, 20, 30), 0.001);
	}
}
