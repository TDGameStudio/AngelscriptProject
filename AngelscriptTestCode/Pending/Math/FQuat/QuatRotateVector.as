/**
 * @version v1
 * @summary RotateVector and UnrotateVector against a ninety degree yaw. C++ executes each entrypoint and compares the result with the native equivalent, so those names are part of the contract and are kept verbatim. The observers.
 * @topic Math
 */
/**
 * @version root
 * @summary RotateVector and UnrotateVector against a ninety degree yaw. C++ executes each entrypoint and compares the result with the native equivalent, so those names are part of the contract and are kept verbatim. The observers.
 * @topic Baseline
 */
namespace FQuatTest
{
	/**
	 * Rotate a forward vector by a ninety degree yaw.
	 *
	 * @Kind Observe
	 * @Covers FQuat.RotateVector
	 * @Inputs none
	 * @Return FVector(1, 0, 0) rotated by a ninety degree yaw
	 */
	UFUNCTION()
	FVector RotateForwardBy90()
	{
		FQuat q = FQuat(FRotator(0, 90, 0));
		FVector v = FVector(1, 0, 0);
		return q.RotateVector(v);
	}

	/**
	 * Unrotate an up vector by a ninety degree yaw.
	 *
	 * @Kind Observe
	 * @Covers FQuat.RotateVector
	 * @Inputs none
	 * @Return FVector(0, 1, 0) unrotated by a ninety degree yaw
	 */
	UFUNCTION()
	FVector UnrotateVector()
	{
		FQuat q = FQuat(FRotator(0, 90, 0));
		FVector v = FVector(0, 1, 0);
		return q.UnrotateVector(v);
	}

	/**
	 * Observe that the rotation matches the native RotateVector result.
	 *
	 * @Kind Observe
	 * @Covers FQuat.RotateVector
	 * @Inputs none
	 * @Return true when the result equals q.RotateVector(FVector(1, 0, 0))
	 */
	UFUNCTION()
	bool RotateForwardBy90Nominal()
	{
		FQuat q = FQuat(FRotator(0, 90, 0));
		return RotateForwardBy90().Equals(q.RotateVector(FVector(1, 0, 0)), 0.01);
	}

	/**
	 * Observe that the unrotation matches the native UnrotateVector result.
	 *
	 * @Kind Observe
	 * @Covers FQuat.RotateVector
	 * @Inputs none
	 * @Return true when the result equals q.UnrotateVector(FVector(0, 1, 0))
	 */
	UFUNCTION()
	bool UnrotateVectorNominal()
	{
		FQuat q = FQuat(FRotator(0, 90, 0));
		return UnrotateVector().Equals(q.UnrotateVector(FVector(0, 1, 0)), 0.01);
	}

	/**
	 * Observe that an identity rotation leaves the zero vector at the origin.
	 *
	 * @Kind Observe
	 * @Covers FQuat.RotateVector
	 * @Inputs a default quaternion and the zero vector
	 * @Return true when the result is still the zero vector
	 * @Boundary zero vector
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		FQuat Empty = FQuat();
		return Empty.RotateVector(FVector::ZeroVector).Equals(FVector::ZeroVector, 0.001);
	}

	/**
	 * Observe that rotating takes a copy of the input, leaving the caller's vector alone.
	 *
	 * @Kind Observe
	 * @Covers FQuat.RotateVector
	 * @Inputs a forward vector and its rotated copy
	 * @Return true when the input still equals FVector(1, 0, 0)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		FVector V = FVector(1, 0, 0);
		FQuat q = FQuat(FRotator(0, 90, 0));
		FVector Rotated = q.RotateVector(V);
		Rotated.X = 0.0;
		return V.Equals(FVector(1, 0, 0));
	}
}
/** @end */
