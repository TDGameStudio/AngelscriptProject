/**
 * @version v1
 * @summary FQuat multiply, axis, &out, and rotator convert. MultiplyQuats of two yaw-45 quats equals the product. WriteOut writes FQuat(FRotator(0,90,0)). QuatToRotator of yaw-90 equals that rotator. Identity * Identity is empty.
 * @topic Definitions
 */
/**
 * @version root
 * @summary FQuat multiply, axis, &out, and rotator convert. MultiplyQuats of two yaw-45 quats equals the product. WriteOut writes FQuat(FRotator(0,90,0)). QuatToRotator of yaw-90 equals that rotator. Identity * Identity is empty.
 * @topic Baseline
 */
UCLASS()
class ACoverageFQuatFunctionActor : AActor
{
	/**
	 * Multiply two quaternions.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param a First quaternion
	 * @Param b Second quaternion
	 * @Inputs a and b
	 * @Return a * b
	 */
	UFUNCTION()
	FQuat MultiplyQuats(FQuat a, FQuat b)
	{
		return a * b;
	}

	/**
	 * Read axis X of a quaternion.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param q Quaternion
	 * @Inputs q
	 * @Return q.GetAxisX()
	 */
	UFUNCTION()
	FVector QuatToAxisX(FQuat q)
	{
		return q.GetAxisX();
	}

	/**
	 * Write a yaw-90 quaternion to an out slot.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param result Destination received as FQuat&out
	 * @Inputs an empty out quaternion
	 * @Return void; result becomes FQuat(FRotator(0, 90, 0))
	 */
	UFUNCTION()
	void WriteOut(FQuat&out result)
	{
		result = FQuat(FRotator(0, 90, 0));
	}

	/**
	 * Convert a quaternion to a rotator.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param q Quaternion
	 * @Inputs q
	 * @Return q.Rotator()
	 */
	UFUNCTION()
	FRotator QuatToRotator(FQuat q)
	{
		return q.Rotator();
	}

	/**
	 * Observe multiply, WriteOut, and QuatToRotator of yaw-90.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs MultiplyQuats of two yaw-45 quats, WriteOut, QuatToRotator of yaw-90
	 * @Return true when product, out, and rotator match the oracle
	 */
	UFUNCTION()
	bool QuatFunctionLiveMatrix()
	{
		FQuat A = FQuat(FRotator(0, 45, 0));
		FQuat B = FQuat(FRotator(0, 45, 0));
		FQuat Product = MultiplyQuats(A, B);
		FQuat OutValue = FQuat::Identity;
		WriteOut(OutValue);
		FQuat Yaw90 = FQuat(FRotator(0, 90, 0));
		if (!Product.Equals(A * B, 0.01))
		{
			return false;
		}
		if (!OutValue.Equals(Yaw90, 0.01))
		{
			return false;
		}
		return QuatToRotator(Yaw90).Equals(FRotator(0, 90, 0), 0.1);
	}

	/**
	 * Observe Identity * Identity and Identity axis X.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs MultiplyQuats(Identity, Identity) and QuatToAxisX(Identity)
	 * @Return true when the product is Identity and axis X is (1,0,0)
	 * @Boundary identity
	 */
	UFUNCTION()
	bool IdentityEmpty()
	{
		FQuat Product = MultiplyQuats(FQuat::Identity, FQuat::Identity);
		if (!Product.Equals(FQuat::Identity, 0.01))
		{
			return false;
		}
		return QuatToAxisX(FQuat::Identity).Equals(FVector(1, 0, 0), 0.01);
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ACoverageFQuatFunctionActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageFQuatFunctionActor Actor = nullptr;
		return Actor == nullptr;
	}
}
/** @end */
