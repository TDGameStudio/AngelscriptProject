/**
 * @version v1
 * @summary FRotator and FQuat factories plus the FTransform Blend, BlendWith and SetRotation mutators. C++ runs ExecuteAndExtractStruct against each Get* entrypoint and compares the result with the native equivalent, so those names.
 * @topic World
 */
/**
 * @version root
 * @summary FRotator and FQuat factories plus the FTransform Blend, BlendWith and SetRotation mutators. C++ runs ExecuteAndExtractStruct against each Get* entrypoint and compares the result with the native equivalent, so those names.
 * @topic Baseline
 */
namespace ActorTest
{
	/**
	 * Build a rotator from three orthonormal axes.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the X, Y and Z axes of an identity basis
	 * @Return FRotator::MakeFromAxes of the identity basis
	 */
	UFUNCTION()
	FRotator GetAxesRotator()
	{
		return FRotator::MakeFromAxes(FVector(1.0f, 0.0f, 0.0f), FVector(0.0f, 1.0f, 0.0f), FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Read the forward vector straight off the factory result.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the identity axes rotator
	 * @Return its forward vector
	 */
	UFUNCTION()
	FVector GetAxesForward()
	{
		return GetAxesRotator().GetForwardVector();
	}

	/**
	 * Read the forward vector through a named rotator instead of the temporary.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the identity axes rotator held in a local
	 * @Return its forward vector
	 */
	UFUNCTION()
	FVector GetAxesForwardMember()
	{
		const FRotator Rotator = GetAxesRotator();
		return Rotator.GetForwardVector();
	}

	/**
	 * Read the right vector straight off the factory result.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the identity axes rotator
	 * @Return its right vector
	 */
	UFUNCTION()
	FVector GetAxesRight()
	{
		return GetAxesRotator().GetRightVector();
	}

	/**
	 * Read the right vector through a named rotator instead of the temporary.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the identity axes rotator held in a local
	 * @Return its right vector
	 */
	UFUNCTION()
	FVector GetAxesRightMember()
	{
		const FRotator Rotator = GetAxesRotator();
		return Rotator.GetRightVector();
	}

	/**
	 * Read the up vector straight off the factory result.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the identity axes rotator
	 * @Return its up vector
	 */
	UFUNCTION()
	FVector GetAxesUp()
	{
		return GetAxesRotator().GetUpVector();
	}

	/**
	 * Read the up vector through a named rotator instead of the temporary.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the identity axes rotator held in a local
	 * @Return its up vector
	 */
	UFUNCTION()
	FVector GetAxesUpMember()
	{
		const FRotator Rotator = GetAxesRotator();
		return Rotator.GetUpVector();
	}

	/**
	 * Compose two rotators.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs rotator A yaw 90 and rotator B pitch 45
	 * @Return A.Compose(B)
	 */
	UFUNCTION()
	FRotator GetComposedRotator()
	{
		const FRotator A = FRotator(0.0f, 90.0f, 0.0f);
		const FRotator B = FRotator(45.0f, 0.0f, 0.0f);
		return A.Compose(B);
	}

	/**
	 * Measure the angular distance between two rotators.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs an identity rotator and one yawed 90 degrees
	 * @Return the angular distance between them
	 */
	UFUNCTION()
	double GetRotatorAngularDistance()
	{
		const FRotator A = FRotator(0.0f, 0.0f, 0.0f);
		const FRotator B = FRotator(0.0f, 90.0f, 0.0f);
		return A.AngularDistance(B);
	}

	/**
	 * Build a quaternion with X as the forward axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the X axis direction
	 * @Return FQuat::MakeFromX
	 */
	UFUNCTION()
	FQuat GetQuatFromX()
	{
		return FQuat::MakeFromX(FVector(1.0f, 1.0f, 0.0f));
	}

	/**
	 * Build a quaternion with Y as the forward axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the Y axis direction
	 * @Return FQuat::MakeFromY
	 */
	UFUNCTION()
	FQuat GetQuatFromY()
	{
		return FQuat::MakeFromY(FVector(-1.0f, 1.0f, 0.0f));
	}

	/**
	 * Build a quaternion with Z as the forward axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the Z axis direction
	 * @Return FQuat::MakeFromZ
	 */
	UFUNCTION()
	FQuat GetQuatFromZ()
	{
		return FQuat::MakeFromZ(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Build a quaternion from an X forward and a Y right axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the X forward and Y right directions
	 * @Return FQuat::MakeFromXY
	 */
	UFUNCTION()
	FQuat GetQuatFromXY()
	{
		return FQuat::MakeFromXY(FVector(1.0f, 1.0f, 0.0f), FVector(-1.0f, 1.0f, 0.0f));
	}

	/**
	 * Build a quaternion from an X forward and a Z up axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the X forward and Z up directions
	 * @Return FQuat::MakeFromXZ
	 */
	UFUNCTION()
	FQuat GetQuatFromXZ()
	{
		return FQuat::MakeFromXZ(FVector(1.0f, 1.0f, 0.0f), FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Build a quaternion from a Y forward and an X right axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the Y forward and X right directions
	 * @Return FQuat::MakeFromYX
	 */
	UFUNCTION()
	FQuat GetQuatFromYX()
	{
		return FQuat::MakeFromYX(FVector(-1.0f, 1.0f, 0.0f), FVector(1.0f, 1.0f, 0.0f));
	}

	/**
	 * Build a quaternion from a Y forward and a Z up axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the Y forward and Z up directions
	 * @Return FQuat::MakeFromYZ
	 */
	UFUNCTION()
	FQuat GetQuatFromYZ()
	{
		return FQuat::MakeFromYZ(FVector(-1.0f, 1.0f, 0.0f), FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Build a quaternion from a Z forward and an X right axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the Z forward and X right directions
	 * @Return FQuat::MakeFromZX
	 */
	UFUNCTION()
	FQuat GetQuatFromZX()
	{
		return FQuat::MakeFromZX(FVector(0.0f, 0.0f, 1.0f), FVector(1.0f, 1.0f, 0.0f));
	}

	/**
	 * Build a quaternion from a Z forward and a Y right axis.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the Z forward and Y right directions
	 * @Return FQuat::MakeFromZY
	 */
	UFUNCTION()
	FQuat GetQuatFromZY()
	{
		return FQuat::MakeFromZY(FVector(0.0f, 0.0f, 1.0f), FVector(-1.0f, 1.0f, 0.0f));
	}

	/**
	 * Blend two transforms into a fresh result.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs transforms A and B, blended at alpha 0.25
	 * @Return the blended transform
	 */
	UFUNCTION()
	FTransform GetBlendTransform()
	{
		FTransform Result;
		const FTransform A = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
		const FTransform B = FTransform(FRotator(-20.0f, 70.0f, 10.0f), FVector(-40.0f, 80.0f, 5.0f), FVector(0.5f, 1.5f, 1.0f));
		Result.Blend(A, B, 0.25f);
		return Result;
	}

	/**
	 * Blend another transform into an existing one in place.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs transform A blended towards B at alpha 0.5
	 * @Return the transform after BlendWith
	 */
	UFUNCTION()
	FTransform GetBlendWithTransform()
	{
		FTransform Result = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
		const FTransform Other = FTransform(FRotator(-20.0f, 70.0f, 10.0f), FVector(-40.0f, 80.0f, 5.0f), FVector(0.5f, 1.5f, 1.0f));
		Result.BlendWith(Other, 0.5f);
		return Result;
	}

	/**
	 * Replace the rotation of an existing transform.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs transform A with its rotation replaced by (-30, 15, 45)
	 * @Return the transform after SetRotation
	 */
	UFUNCTION()
	FTransform GetSetRotationTransform()
	{
		FTransform Result = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
		Result.SetRotation(FRotator(-30.0f, 15.0f, 45.0f));
		return Result;
	}

	/**
	 * Observe that an identity rotator is at zero distance from itself.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs an identity rotator compared with itself
	 * @Return the angular distance, expected to be 0
	 * @Boundary empty rotator
	 */
	UFUNCTION()
	double EmptyAngularDistanceZero()
	{
		const FRotator Empty = FRotator(0.0f, 0.0f, 0.0f);
		return Empty.AngularDistance(Empty);
	}

	/**
	 * Observe that reading the axes through a member agrees with the free function.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs the free and member forward, right and up vectors
	 * @Return true when all three pairs agree
	 * @Boundary member versus free axes
	 */
	UFUNCTION()
	bool AxesMemberCopyIndependence()
	{
		if (!GetAxesForward().Equals(GetAxesForwardMember()))
		{
			return false;
		}
		if (!GetAxesRight().Equals(GetAxesRightMember()))
		{
			return false;
		}
		return GetAxesUp().Equals(GetAxesUpMember());
	}

	/**
	 * Observe that blending at zero alpha leaves the first transform untouched.
	 *
	 * @Kind Observe
	 * @Covers Actor.FactoriesAndTransformMutators
	 * @Inputs transforms A and B blended at alpha 0
	 * @Return the blended transform, expected to equal A
	 * @Boundary zero alpha
	 */
	UFUNCTION()
	FTransform BlendZeroAlphaKeepsA()
	{
		FTransform Result;
		const FTransform A = FTransform(FRotator(10.0f, 20.0f, 30.0f), FVector(100.0f, -50.0f, 25.0f), FVector(1.25f, 0.75f, 2.0f));
		const FTransform B = FTransform(FRotator(-20.0f, 70.0f, 10.0f), FVector(-40.0f, 80.0f, 5.0f), FVector(0.5f, 1.5f, 1.0f));
		Result.Blend(A, B, 0.0f);
		return Result;
	}
}
/** @end */
