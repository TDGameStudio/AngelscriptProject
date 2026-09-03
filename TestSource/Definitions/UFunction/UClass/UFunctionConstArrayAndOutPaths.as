/**
 * Const FQuat&in, TArray<FQuat> in/out, and a stored member. ReadConstQuat
 * returns GetAngle, StoreAndReturn writes StoredQuat and returns Inverse,
 * and AcceptQuatArray counts 2. An empty TArray counts 0, a nullptr actor is
 * the empty handle, and Identity inverse is Identity.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.UFunctionConstArrayAndOutPaths
 * @Harness UClass
 * @Tag Definitions.UFunction.UFunctionConstArrayAndOutPaths
 * @Provenance Theme: Definitions.UFunction. WorldStory const FQuat&in, TArray<FQuat> in/out, stored member.
 * @Provenance C++: AngelscriptCoverageFQuatFunctionTests.cpp::UFunctionConstArrayAndOutPaths
 * @Provenance Oracle: ReadConstQuat returns GetAngle; StoreAndReturn writes StoredQuat and returns Inverse; AcceptQuatArray count 2.
 * @Provenance Extra: empty TArray count 0; nullptr actor is the empty handle; Identity inverse is Identity.
 * @Provenance FixtureIsolated. Keep StoredQuat / StoredQuats / LastArrayProduct / LastArrayCount names.
 */

UCLASS()
class ACoverageFQuatFunctionConstArrayActor : AActor
{
	UPROPERTY()
	FQuat StoredQuat = FQuat::Identity;

	UPROPERTY()
	TArray<FQuat> StoredQuats;

	UPROPERTY()
	FQuat LastArrayProduct = FQuat::Identity;

	UPROPERTY()
	int LastArrayCount = 0;

	/**
	 * Read the angle of a const FQuat&in.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Value Quaternion received as const FQuat&in
	 * @Inputs Value
	 * @Return Value.GetAngle()
	 */
	UFUNCTION()
	double ReadConstQuat(const FQuat&in Value)
	{
		return Value.GetAngle();
	}

	/**
	 * Store Value and return its inverse.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Value Quaternion stored
	 * @Inputs Value
	 * @Return StoredQuat.Inverse()
	 */
	UFUNCTION()
	FQuat StoreAndReturn(FQuat Value)
	{
		StoredQuat = Value;
		return StoredQuat.Inverse();
	}

	/**
	 * Accept a const TArray<FQuat>&in, product the elements, and return the count.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Values Quaternions received as const TArray<FQuat>&in
	 * @Inputs Values
	 * @Return Values.Num() after writing LastArrayCount and LastArrayProduct
	 */
	UFUNCTION()
	int AcceptQuatArray(const TArray<FQuat>&in Values)
	{
		LastArrayCount = Values.Num();
		LastArrayProduct = FQuat::Identity;
		for (FQuat Value : Values)
		{
			LastArrayProduct *= Value;
		}
		return LastArrayCount;
	}

	/**
	 * Build a two-element TArray and store it.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param First First quaternion
	 * @Param Second Second quaternion
	 * @Inputs First and Second
	 * @Return a two-element array also written to StoredQuats
	 */
	UFUNCTION()
	TArray<FQuat> MakeQuatArray(FQuat First, FQuat Second)
	{
		TArray<FQuat> Result;
		Result.Add(First);
		Result.Add(Second);
		StoredQuats = Result;
		return Result;
	}

	/**
	 * Fill an &out TArray with Identity and a 90-degree up rotation.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Result Destination received as TArray<FQuat>&out
	 * @Inputs an empty out array
	 * @Return void; Result and StoredQuats receive two quaternions
	 */
	UFUNCTION()
	void FillOutQuatArray(TArray<FQuat>&out Result)
	{
		Result.Add(FQuat::Identity);
		Result.Add(FQuat(FVector::UpVector, 1.5707963267948966));
		StoredQuats = Result;
	}

	/**
	 * Observe AcceptQuatArray on an empty array.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs AcceptQuatArray of an empty TArray
	 * @Return true when the count is 0 and LastArrayProduct is Identity
	 * @Boundary empty array
	 */
	UFUNCTION()
	bool EmptyArrayCount()
	{
		TArray<FQuat> Empty;
		if (AcceptQuatArray(Empty) != 0)
		{
			return false;
		}
		if (LastArrayCount != 0)
		{
			return false;
		}
		return LastArrayProduct.Equals(FQuat::Identity, 0.01);
	}

	/**
	 * Observe Identity inverse and zero angle.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs StoreAndReturn(Identity) and ReadConstQuat(Identity)
	 * @Return true when inverse is Identity and the angle is nearly 0
	 * @Boundary identity
	 */
	UFUNCTION()
	bool IdentityInverseBoundary()
	{
		FQuat Inverse = StoreAndReturn(FQuat::Identity);
		if (!Inverse.Equals(FQuat::Identity, 0.01))
		{
			return false;
		}
		if (!StoredQuat.Equals(FQuat::Identity, 0.01))
		{
			return false;
		}
		return Math::IsNearlyEqual(ReadConstQuat(FQuat::Identity), 0.0);
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ACoverageFQuatFunctionConstArrayActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageFQuatFunctionConstArrayActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe a two-element make, accept, and fill-out path.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs MakeQuatArray, AcceptQuatArray, FillOutQuatArray
	 * @Return true when all counts are 2
	 */
	UFUNCTION()
	bool TwoElementProduct()
	{
		FQuat First = FQuat::Identity;
		FQuat Second = FQuat(FVector::UpVector, 1.5707963267948966);
		TArray<FQuat> Made = MakeQuatArray(First, Second);
		int Count = AcceptQuatArray(Made);
		TArray<FQuat> Filled;
		FillOutQuatArray(Filled);
		if (Count != 2)
		{
			return false;
		}
		if (Made.Num() != 2)
		{
			return false;
		}
		if (Filled.Num() != 2)
		{
			return false;
		}
		return StoredQuats.Num() == 2;
	}
}
