/**
 * The FQuat multiplication operator, both for composing two rotations and for rotating a
 * vector. C++ executes each entrypoint and compares the result with the native
 * equivalent, so those names are part of the contract and are kept verbatim.
 *
 * @Theme Math.FQuat
 * @Subject FQuat.MultiplicationOperator
 * @Harness Function
 * @Tag Math.FQuat.QuatMultiplicationOperator
 * @Namespace FQuatTest
 * @Provenance Theme: Gameplay.FQuat. Positive multiplication operator oracles.
 * @Provenance C++: AngelscriptCoverageFQuatExpressionTests.cpp::QuatMultiplicationOperator
 * @Provenance Oracle: MultiplyQuats Equals q1*q2 of two yaw-45; RotateVectorWithOperator Equals
 * @Provenance FQuat(FRotator(0,90,0)).RotateVector(FVector(1,0,0)).
 * @Provenance Extra: Identity * Identity; copy independence of q1/q2. DefaultSafe.
 */

namespace FQuatTest
{
	/**
	 * Compose two forty-five degree yaws.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MultiplicationOperator
	 * @Inputs none
	 * @Return the product of two yaw-45 quaternions
	 */
	UFUNCTION()
	FQuat MultiplyQuats()
	{
		FQuat q1 = FQuat(FRotator(0, 45, 0));
		FQuat q2 = FQuat(FRotator(0, 45, 0));
		return q1 * q2;
	}

	/**
	 * Rotate a vector with the multiplication operator.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MultiplicationOperator
	 * @Inputs none
	 * @Return a unit X vector rotated by a ninety degree yaw
	 */
	UFUNCTION()
	FVector RotateVectorWithOperator()
	{
		FQuat q = FQuat(FRotator(0, 90, 0));
		FVector v = FVector(1, 0, 0);
		return q * v;
	}

	/**
	 * Observe that composing two rotations matches the native product.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MultiplicationOperator
	 * @Inputs none
	 * @Return true when the result equals q1 * q2
	 */
	UFUNCTION()
	bool MultiplyQuatsNominal()
	{
		FQuat q1 = FQuat(FRotator(0, 45, 0));
		FQuat q2 = FQuat(FRotator(0, 45, 0));
		return MultiplyQuats().Equals(q1 * q2, 0.01);
	}

	/**
	 * Observe that rotating with the operator matches RotateVector.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MultiplicationOperator
	 * @Inputs none
	 * @Return true when the result equals q.RotateVector(FVector(1, 0, 0))
	 */
	UFUNCTION()
	bool RotateVectorWithOperatorNominal()
	{
		FQuat q = FQuat(FRotator(0, 90, 0));
		return RotateVectorWithOperator().Equals(q.RotateVector(FVector(1, 0, 0)), 0.01);
	}

	/**
	 * Observe that multiplying a default quaternion by the identity stays the identity.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MultiplicationOperator
	 * @Inputs a default-constructed quaternion
	 * @Return true when the product equals the identity constant
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultIdentity()
	{
		FQuat Empty = FQuat();
		return (Empty * FQuat::Identity).Equals(FQuat::Identity, 0.001);
	}

	/**
	 * Observe that mutating a product leaves both factors untouched.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MultiplicationOperator
	 * @Inputs two yaw-45 quaternions and their mutated product
	 * @Return true when both factors still equal a yaw-45 quaternion
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		FQuat q1 = FQuat(FRotator(0, 45, 0));
		FQuat q2 = FQuat(FRotator(0, 45, 0));
		FQuat Product = q1 * q2;
		Product.X = 0.0;

		if (!q1.Equals(FQuat(FRotator(0, 45, 0)), 0.01))
		{
			return false;
		}
		return q2.Equals(FQuat(FRotator(0, 45, 0)), 0.01);
	}
}
