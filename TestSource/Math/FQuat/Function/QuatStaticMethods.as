/**
 * The static FQuat helpers: Slerp, MakeFromEuler and FindBetweenVectors. C++ executes
 * each entrypoint and compares the result with the native equivalent, so those names are
 * part of the contract and are kept verbatim. The observers cover the zero-alpha case
 * and the independence of the Slerp endpoints.
 *
 * @Theme Math.FQuat
 * @Subject FQuat.StaticMethods
 * @Harness Function
 * @Tag Math.FQuat.QuatStaticMethods
 * @Namespace FQuatTest
 * @Provenance Theme: Gameplay.FQuat. Positive Slerp / MakeFromEuler / FindBetweenVectors.
 * @Provenance C++: AngelscriptCoverageFQuatExpressionTests.cpp::QuatStaticMethods
 * @Provenance Oracle: Slerp Identity->yaw90 at 0.5; MakeFromEuler(10,20,30);
 * @Provenance FindBetweenVectors Forward->Right.
 * @Provenance Extra: Slerp at 0 is Identity; copy independence of endpoints. DefaultSafe.
 */

namespace FQuatTest
{
	/**
	 * Interpolate halfway from the identity to a ninety degree yaw.
	 *
	 * @Kind Observe
	 * @Covers FQuat.StaticMethods
	 * @Inputs none
	 * @Return the Slerp of the identity and a yaw-90 quaternion at alpha 0.5
	 */
	UFUNCTION()
	FQuat SlerpQuats()
	{
		FQuat q1 = FQuat::Identity;
		FQuat q2 = FQuat(FRotator(0, 90, 0));
		return FQuat::Slerp(q1, q2, 0.5);
	}

	/**
	 * Build a quaternion from Euler angles in degrees.
	 *
	 * @Kind Observe
	 * @Covers FQuat.StaticMethods
	 * @Inputs none
	 * @Return the quaternion for a (10, 20, 30) degree Euler triple
	 */
	UFUNCTION()
	FQuat MakeFromEuler()
	{
		FVector euler = FVector(10, 20, 30);
		return FQuat::MakeFromEuler(euler);
	}

	/**
	 * Find the rotation taking the forward axis onto the right axis.
	 *
	 * @Kind Observe
	 * @Covers FQuat.StaticMethods
	 * @Inputs none
	 * @Return the quaternion between the forward and right vectors
	 */
	UFUNCTION()
	FQuat FindBetweenVectors()
	{
		FVector v1 = FVector::ForwardVector;
		FVector v2 = FVector::RightVector;
		return FQuat::FindBetweenVectors(v1, v2);
	}

	/**
	 * Observe that the interpolation matches the native Slerp result.
	 *
	 * @Kind Observe
	 * @Covers FQuat.StaticMethods
	 * @Inputs none
	 * @Return true when the result equals FQuat::Slerp(q1, q2, 0.5)
	 */
	UFUNCTION()
	bool SlerpQuatsNominal()
	{
		FQuat q1 = FQuat::Identity;
		FQuat q2 = FQuat(FRotator(0, 90, 0));
		return SlerpQuats().Equals(FQuat::Slerp(q1, q2, 0.5), 0.01);
	}

	/**
	 * Observe that the Euler conversion matches the native result.
	 *
	 * @Kind Observe
	 * @Covers FQuat.StaticMethods
	 * @Inputs none
	 * @Return true when the result equals FQuat::MakeFromEuler(FVector(10, 20, 30))
	 */
	UFUNCTION()
	bool MakeFromEulerNominal()
	{
		return MakeFromEuler().Equals(FQuat::MakeFromEuler(FVector(10, 20, 30)), 0.01);
	}

	/**
	 * Observe that the between-vectors lookup matches the native result.
	 *
	 * @Kind Observe
	 * @Covers FQuat.StaticMethods
	 * @Inputs none
	 * @Return true when the result equals FQuat::FindBetweenVectors(Forward, Right)
	 */
	UFUNCTION()
	bool FindBetweenVectorsNominal()
	{
		return FindBetweenVectors().Equals(
			FQuat::FindBetweenVectors(FVector::ForwardVector, FVector::RightVector), 0.01);
	}

	/**
	 * Observe that interpolating at zero alpha returns the first endpoint.
	 *
	 * @Kind Observe
	 * @Covers FQuat.StaticMethods
	 * @Inputs none
	 * @Return true when the result equals the identity
	 * @Boundary zero alpha
	 */
	UFUNCTION()
	bool SlerpQuatsAtZeroIsIdentity()
	{
		FQuat q1 = FQuat::Identity;
		FQuat q2 = FQuat(FRotator(0, 90, 0));
		return FQuat::Slerp(q1, q2, 0.0).Equals(FQuat::Identity, 0.01);
	}

	/**
	 * Observe that mutating an interpolated result leaves both endpoints untouched.
	 *
	 * @Kind Observe
	 * @Covers FQuat.StaticMethods
	 * @Inputs the two endpoints and their mutated midpoint
	 * @Return true when both endpoints still hold their original rotation
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool SlerpQuatsCopyIndependence()
	{
		FQuat q1 = FQuat::Identity;
		FQuat q2 = FQuat(FRotator(0, 90, 0));
		FQuat Mid = FQuat::Slerp(q1, q2, 0.5);
		Mid.X = 0.0;

		if (!q1.Equals(FQuat::Identity, 0.001))
		{
			return false;
		}
		return q2.Equals(FQuat(FRotator(0, 90, 0)), 0.01);
	}
}
