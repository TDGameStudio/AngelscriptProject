/**
 * @version v1
 * @summary TArray.Reset empties the array while keeping the allocated slack, which is what distinguishes it from Empty(int32) — Empty can also change the reservation. After Reset the array is empty but Max() still reports the.
 * @topic Containers
 */
/**
 * @version root
 * @summary TArray.Reset empties the array while keeping the allocated slack, which is what distinguishes it from Empty(int32) — Empty can also change the reservation. After Reset the array is empty but Max() still reports the.
 * @topic Baseline
 */
UCLASS()
class UTArrayResetObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe Reset: it empties the array and IsEmpty reports true afterwards.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reset
	 * @Inputs TArray<int> with three elements; Reset()
	 * @Return true when Num is 0 and IsEmpty() is true
	 */
	UFUNCTION()
	bool ResetEmptiesArray()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);

		Array.Reset();
		if (Array.Num() != 0)
		{
			return false;
		}
		return Array.IsEmpty();
	}

	/**
	 * Observe that Reset keeps the allocated slack: Max() does not drop back
	 * to zero the way it would for a freshly constructed array.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reset
	 * @Inputs TArray<int>; Reserve(16); Add three; Reset()
	 * @Return true when Max() is still at least 16 after the reset
	 * @Boundary Reset frees elements, not capacity
	 */
	UFUNCTION()
	bool ResetKeepsAllocatedSlack()
	{
		TArray<int> Array;
		Array.Reserve(16);
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);

		Array.Reset();
		if (Array.Num() != 0)
		{
			return false;
		}
		return Array.Max() >= 16;
	}

	/**
	 * Observe that Reset is idempotent and legal on an already-empty array.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reset
	 * @Inputs Empty TArray<int>; Reset() twice
	 * @Return true when Num stays 0
	 */
	UFUNCTION()
	bool ResetOnEmptyIsNoOp()
	{
		TArray<int> Array;

		Array.Reset();
		Array.Reset();
		if (Array.Num() != 0)
		{
			return false;
		}
		return Array.IsEmpty();
	}

	/**
	 * Observe that Add works after Reset: the array is reusable, not spent.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reset
	 * @Inputs TArray<int> [1,2,3]; Reset(); Add(9)
	 * @Return true when Num is 1 and the new element reads back
	 */
	UFUNCTION()
	bool AddAfterResetStartsNewSequence()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);

		Array.Reset();
		if (Array.Num() != 0)
		{
			return false;
		}

		Array.Add(9);
		if (Array.Num() != 1)
		{
			return false;
		}
		return Array[0] == 9;
	}

	/**
	 * In-only: confirm a const&in array reports empty after a Reset.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reset
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values was reset and is therefore empty
	 * @Return true when Num is 0 and IsEmpty() is true
	 */
	UFUNCTION()
	bool ReadAfterReset(const TArray<int>&in Values)
	{
		if (Values.Num() != 0)
		{
			return false;
		}
		return Values.IsEmpty();
	}

	/**
	 * Out-only: fill an &out array and then reset it, leaving it empty.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reset
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result is empty after the reset
	 */
	UFUNCTION()
	void FillThenReset(TArray<int>&out Result)
	{
		Result.Add(1);
		Result.Add(2);
		Result.Add(3);
		Result.Reset();
	}

	/**
	 * Inout: reset an already-populated array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reset
	 * @Param Values Array received as TArray<int>&inout, holds [1,2,3]
	 * @Inputs Values.Num() is 3
	 * @Return void; Values is empty
	 */
	UFUNCTION()
	void ClearByReset(TArray<int>&inout Values)
	{
		Values.Reset();
	}


	/**
	 * Observe Reset for FString: elements are destroyed and the array empties.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reset
	 * @Inputs TArray<FString> with three strings; Reset()
	 * @Return true when Num is 0 and IsEmpty() is true
	 */
	UFUNCTION()
	bool ResetEmptiesArray_FString()
	{
		TArray<FString> Array;
		Array.Add("a");
		Array.Add("b");
		Array.Add("c");

		Array.Reset();
		if (Array.Num() != 0)
		{
			return false;
		}
		return Array.IsEmpty();
	}

	/**
	 * Observe that Add works after Reset for FString.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reset
	 * @Inputs TArray<FString>; Add three; Reset(); Add("z")
	 * @Return true when Num is 1 and the new string reads back
	 */
	UFUNCTION()
	bool AddAfterResetStartsNewSequence_FString()
	{
		TArray<FString> Array;
		Array.Add("a");
		Array.Add("b");
		Array.Add("c");

		Array.Reset();
		if (Array.Num() != 0)
		{
			return false;
		}

		Array.Add("z");
		if (Array.Num() != 1)
		{
			return false;
		}
		return Array[0] == "z";
	}

	/**
	 * In-only: confirm a const&in TArray<FString> reports empty after a Reset.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reset
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs Values was reset and is therefore empty
	 * @Return true when Num is 0
	 */
	UFUNCTION()
	bool ReadAfterReset_FString(const TArray<FString>&in Values)
	{
		if (Values.Num() != 0)
		{
			return false;
		}
		return Values.IsEmpty();
	}

	/**
	 * Out-only: fill an &out TArray<FString> and then reset it.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reset
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result is empty after the reset
	 */
	UFUNCTION()
	void FillThenReset_FString(TArray<FString>&out Result)
	{
		Result.Add("a");
		Result.Add("b");
		Result.Add("c");
		Result.Reset();
	}

	/**
	 * Inout: reset an already-populated TArray<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reset
	 * @Param Values Array received as TArray<FString>&inout, holds three strings
	 * @Inputs Values.Num() is 3
	 * @Return void; Values is empty
	 */
	UFUNCTION()
	void ClearByReset_FString(TArray<FString>&inout Values)
	{
		Values.Reset();
	}
}
/** @end */
