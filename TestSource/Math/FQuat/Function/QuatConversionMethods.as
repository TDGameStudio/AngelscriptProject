/**
 * The FQuat conversion surface: to a rotator, to Euler angles, and out along each of the
 * three axes. C++ executes each entrypoint and compares the result with the native
 * equivalent, so those names are part of the contract and are kept verbatim. The
 * observers cover the identity conversion and the independence of the axis results.
 *
 * @Theme Math.FQuat
 * @Subject FQuat.ConversionMethods
 * @Harness Function
 * @Tag Math.FQuat.QuatConversionMethods
 * @Namespace FQuatTest
 * @Provenance Theme: Gameplay.FQuat. Positive Rotator / Euler / axis conversion oracles.
 * @Provenance C++: AngelscriptCoverageFQuatExpressionTests.cpp::QuatConversionMethods
 * @Provenance Oracle: QuatToRotator (0,90,0); QuatEuler native Euler of (10,20,30);
 * @Provenance GetAxisX Forward; GetAxisY Right; GetAxisZ Up.
 * @Provenance Extra: Identity rotator ZeroRotator; copy independence of Euler source. DefaultSafe.
 */

namespace FQuatTest
{
	/**
	 * Convert a ninety degree yaw back into a rotator.
	 *
	 * @Kind Observe
	 * @Covers FQuat.ConversionMethods
	 * @Inputs none
	 * @Return the rotator form of a yaw-90 quaternion
	 */
	UFUNCTION()
	FRotator QuatToRotator()
	{
		FQuat q = FQuat(FRotator(0, 90, 0));
		return q.Rotator();
	}

	/**
	 * Read a quaternion as Euler angles in degrees.
	 *
	 * @Kind Observe
	 * @Covers FQuat.ConversionMethods
	 * @Inputs none
	 * @Return the Euler triple of a (10, 20, 30) degree rotation
	 */
	UFUNCTION()
	FVector QuatEuler()
	{
		FQuat q = FQuat(FRotator(10, 20, 30));
		return q.Euler();
	}

	/**
	 * Read the forward axis of an unrotated quaternion.
	 *
	 * @Kind Observe
	 * @Covers FQuat.ConversionMethods
	 * @Inputs none
	 * @Return the X axis, which should be the forward vector
	 */
	UFUNCTION()
	FVector GetForwardAxis()
	{
		FQuat q = FQuat(FRotator(0, 0, 0));
		return q.GetAxisX();
	}

	/**
	 * Read the right axis of an unrotated quaternion.
	 *
	 * @Kind Observe
	 * @Covers FQuat.ConversionMethods
	 * @Inputs none
	 * @Return the Y axis, which should be the right vector
	 */
	UFUNCTION()
	FVector GetRightAxis()
	{
		FQuat q = FQuat(FRotator(0, 0, 0));
		return q.GetAxisY();
	}

	/**
	 * Read the up axis of an unrotated quaternion.
	 *
	 * @Kind Observe
	 * @Covers FQuat.ConversionMethods
	 * @Inputs none
	 * @Return the Z axis, which should be the up vector
	 */
	UFUNCTION()
	FVector GetUpAxis()
	{
		FQuat q = FQuat(FRotator(0, 0, 0));
		return q.GetAxisZ();
	}

	/**
	 * Observe that the rotator conversion round-trips a ninety degree yaw.
	 *
	 * @Kind Observe
	 * @Covers FQuat.ConversionMethods
	 * @Inputs none
	 * @Return true when the result equals FRotator(0, 90, 0)
	 */
	UFUNCTION()
	bool QuatToRotatorNominal()
	{
		return QuatToRotator().Equals(FRotator(0, 90, 0), 0.1);
	}

	/**
	 * Observe that the Euler conversion matches the native result.
	 *
	 * @Kind Observe
	 * @Covers FQuat.ConversionMethods
	 * @Inputs none
	 * @Return true when the result equals q.Euler()
	 */
	UFUNCTION()
	bool QuatEulerNominal()
	{
		FQuat q = FQuat(FRotator(10, 20, 30));
		return QuatEuler().Equals(q.Euler(), 0.1);
	}

	/**
	 * Observe that the forward axis matches the forward vector.
	 *
	 * @Kind Observe
	 * @Covers FQuat.ConversionMethods
	 * @Inputs none
	 * @Return true when the result equals FVector::ForwardVector
	 */
	UFUNCTION()
	bool GetForwardAxisNominal()
	{
		return GetForwardAxis().Equals(FVector::ForwardVector, 0.01);
	}

	/**
	 * Observe that the right axis matches the right vector.
	 *
	 * @Kind Observe
	 * @Covers FQuat.ConversionMethods
	 * @Inputs none
	 * @Return true when the result equals FVector::RightVector
	 */
	UFUNCTION()
	bool GetRightAxisNominal()
	{
		return GetRightAxis().Equals(FVector::RightVector, 0.01);
	}

	/**
	 * Observe that the up axis matches the up vector.
	 *
	 * @Kind Observe
	 * @Covers FQuat.ConversionMethods
	 * @Inputs none
	 * @Return true when the result equals FVector::UpVector
	 */
	UFUNCTION()
	bool GetUpAxisNominal()
	{
		return GetUpAxis().Equals(FVector::UpVector, 0.01);
	}

	/**
	 * Observe that a default quaternion converts to the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FQuat.ConversionMethods
	 * @Inputs a default-constructed quaternion
	 * @Return true when the rotator equals FRotator::ZeroRotator
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultIdentity()
	{
		return FQuat().Rotator().Equals(FRotator::ZeroRotator, 0.1);
	}

	/**
	 * Observe that mutating an axis result leaves the quaternion's own axis alone.
	 *
	 * @Kind Observe
	 * @Covers FQuat.ConversionMethods
	 * @Inputs an unrotated quaternion and a mutated copy of its forward axis
	 * @Return true when reading the axis again yields the forward vector
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool GetAxesCopyIndependence()
	{
		FQuat q = FQuat(FRotator(0, 0, 0));
		FVector Forward = q.GetAxisX();
		Forward.X = 0.0;
		return q.GetAxisX().Equals(FVector::ForwardVector, 0.01);
	}
}
