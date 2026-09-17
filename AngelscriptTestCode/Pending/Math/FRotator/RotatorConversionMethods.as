/**
 * @version v1
 * @summary The FRotator conversion and rotate paths: Vector, Quaternion, Euler, RotateVector and UnrotateVector. C++ executes each entrypoint and compares the result with the native equivalent, so those names are part of the.
 * @topic Math
 */
/**
 * @version root
 * @summary The FRotator conversion and rotate paths: Vector, Quaternion, Euler, RotateVector and UnrotateVector. C++ executes each entrypoint and compares the result with the native equivalent, so those names are part of the.
 * @topic Baseline
 */
namespace FRotatorTest
{
	/**
	 * Convert a zero rotator to a direction vector.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ConversionMethods
	 * @Inputs none
	 * @Return the forward vector
	 */
	UFUNCTION()
	FVector RotatorToVector()
	{
		FRotator r = FRotator(0, 0, 0);
		return r.Vector();
	}

	/**
	 * Convert a yaw-90 rotator to a quaternion.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ConversionMethods
	 * @Inputs none
	 * @Return FRotator(0, 90, 0).Quaternion()
	 */
	UFUNCTION()
	FQuat RotatorToQuaternion()
	{
		FRotator r = FRotator(0, 90, 0);
		return r.Quaternion();
	}

	/**
	 * Read the Euler vector of a known rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ConversionMethods
	 * @Inputs none
	 * @Return FRotator(10, 20, 30).Euler()
	 */
	UFUNCTION()
	FVector RotatorEuler()
	{
		FRotator r = FRotator(10, 20, 30);
		return r.Euler();
	}

	/**
	 * Rotate a vector by a yaw-90 rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ConversionMethods
	 * @Inputs none
	 * @Return RotateVector of (1, 0, 0)
	 */
	UFUNCTION()
	FVector RotateVector()
	{
		FRotator r = FRotator(0, 90, 0);
		FVector v = FVector(1, 0, 0);
		return r.RotateVector(v);
	}

	/**
	 * Unrotate a vector by a yaw-90 rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ConversionMethods
	 * @Inputs none
	 * @Return UnrotateVector of (0, 1, 0)
	 */
	UFUNCTION()
	FVector UnrotateVector()
	{
		FRotator r = FRotator(0, 90, 0);
		FVector v = FVector(0, 1, 0);
		return r.UnrotateVector(v);
	}

	/**
	 * Observe that a zero rotator converts to the forward vector.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ConversionMethods
	 * @Inputs none
	 * @Return true when RotatorToVector equals ForwardVector
	 */
	UFUNCTION()
	bool RotatorToVectorNominal()
	{
		return RotatorToVector().Equals(FVector::ForwardVector, 0.01);
	}

	/**
	 * Observe that Quaternion matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ConversionMethods
	 * @Inputs none
	 * @Return true when the result equals the native Quaternion
	 */
	UFUNCTION()
	bool RotatorToQuaternionNominal()
	{
		return RotatorToQuaternion().Equals(FRotator(0, 90, 0).Quaternion(), 0.001);
	}

	/**
	 * Observe that Euler matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ConversionMethods
	 * @Inputs none
	 * @Return true when the result equals the native Euler
	 */
	UFUNCTION()
	bool RotatorEulerNominal()
	{
		return RotatorEuler().Equals(FRotator(10, 20, 30).Euler(), 0.001);
	}

	/**
	 * Observe that RotateVector matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ConversionMethods
	 * @Inputs none
	 * @Return true when the result equals the native RotateVector
	 */
	UFUNCTION()
	bool RotateVectorNominal()
	{
		return RotateVector().Equals(FRotator(0, 90, 0).RotateVector(FVector(1, 0, 0)), 0.01);
	}

	/**
	 * Observe that UnrotateVector matches the native conversion.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ConversionMethods
	 * @Inputs none
	 * @Return true when the result equals the native UnrotateVector
	 */
	UFUNCTION()
	bool UnrotateVectorNominal()
	{
		return UnrotateVector().Equals(FRotator(0, 90, 0).UnrotateVector(FVector(0, 1, 0)), 0.01);
	}

	/**
	 * Observe that a default rotator converts to the forward vector.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ConversionMethods
	 * @Inputs a default-constructed rotator
	 * @Return true when Vector equals ForwardVector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool RotatorToVectorDefaultEmpty()
	{
		return FRotator().Vector().Equals(FVector::ForwardVector, 0.01);
	}

	/**
	 * Observe that mutating the rotated vector leaves the original untouched.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ConversionMethods
	 * @Inputs a vector rotated and then mutated
	 * @Return true when the original still equals (1, 0, 0)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool RotateVectorCopyIndependence()
	{
		FVector V = FVector(1, 0, 0);
		FVector Rotated = FRotator(0, 90, 0).RotateVector(V);
		Rotated.X = 0.0;
		return V.Equals(FVector(1, 0, 0));
	}
}
/** @end */
