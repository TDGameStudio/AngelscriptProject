/**
 * @version v1
 * @summary FVector add, Size, and &out UpVector. AddVectors((1,2,3),(4,5,6)) is (5,7,9). VectorLength(3,4,0) is 5. WriteOut writes UpVector. ZeroVector add is empty, a nullptr actor is the empty handle, and addends are unchanged.
 * @topic Definitions
 */
/**
 * @version root
 * @summary FVector add, Size, and &out UpVector. AddVectors((1,2,3),(4,5,6)) is (5,7,9). VectorLength(3,4,0) is 5. WriteOut writes UpVector. ZeroVector add is empty, a nullptr actor is the empty handle, and addends are unchanged.
 * @topic Baseline
 */
UCLASS()
class ACoverageFVectorFunctionActor : AActor
{
	/**
	 * Add two FVector values.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param a First vector
	 * @Param b Second vector
	 * @Inputs a and b
	 * @Return a + b
	 */
	UFUNCTION()
	FVector AddVectors(FVector a, FVector b)
	{
		return a + b;
	}

	/**
	 * Read the size of an FVector.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param v Vector whose size is read
	 * @Inputs v
	 * @Return v.Size()
	 */
	UFUNCTION()
	float VectorLength(FVector v)
	{
		return v.Size();
	}

	/**
	 * Write UpVector to an out FVector.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param result Destination received as FVector&out
	 * @Inputs an empty out vector
	 * @Return void; result becomes UpVector
	 */
	UFUNCTION()
	void WriteOut(FVector&out result)
	{
		result = FVector::UpVector;
	}

	/**
	 * Observe add, length, and WriteOut.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs AddVectors((1,2,3),(4,5,6)), VectorLength(3,4,0), WriteOut
	 * @Return true when the results are (5,7,9), 5, and UpVector
	 */
	UFUNCTION()
	bool VectorLiveMatrix()
	{
		FVector Sum = AddVectors(FVector(1, 2, 3), FVector(4, 5, 6));
		FVector OutValue = FVector::ZeroVector;
		WriteOut(OutValue);
		if (!Sum.Equals(FVector(5, 7, 9), 0.01))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(VectorLength(FVector(3, 4, 0)), 5.0))
		{
			return false;
		}
		return OutValue.Equals(FVector::UpVector, 0.01);
	}

	/**
	 * Observe ZeroVector add and length.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs AddVectors(Zero, Zero) and VectorLength(Zero)
	 * @Return true when the sum is Zero and the length is 0
	 * @Boundary zero vector
	 */
	UFUNCTION()
	bool ZeroEmpty()
	{
		if (!AddVectors(FVector::ZeroVector, FVector::ZeroVector).Equals(FVector::ZeroVector, 0.01))
		{
			return false;
		}
		return Math::IsNearlyEqual(VectorLength(FVector::ZeroVector), 0.0);
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ACoverageFVectorFunctionActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageFVectorFunctionActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that AddVectors does not write its addends.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs AddVectors of locals (1,2,3) and (4,5,6)
	 * @Return true when the locals stay put and the sum is (5,7,9)
	 */
	UFUNCTION()
	bool AddVectorsCopyIndependence()
	{
		FVector A = FVector(1, 2, 3);
		FVector B = FVector(4, 5, 6);
		FVector Sum = AddVectors(A, B);
		if (!A.Equals(FVector(1, 2, 3), 0.01))
		{
			return false;
		}
		if (!B.Equals(FVector(4, 5, 6), 0.01))
		{
			return false;
		}
		return Sum.Equals(FVector(5, 7, 9), 0.01);
	}
}
/** @end */
