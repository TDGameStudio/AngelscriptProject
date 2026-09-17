/**
 * @version v1
 * @summary In-range opIndex reads insertion order and write replaces only that slot. Out-of-range and float truncation are other files. Reads and writes are observed locally, then through UFUNCTION in, out, and inout. int is the.
 * @topic Containers
 */
/**
 * @version root
 * @summary In-range opIndex reads insertion order and write replaces only that slot. Out-of-range and float truncation are other files. Reads and writes are observed locally, then through UFUNCTION in, out, and inout. int is the.
 * @topic Baseline
 */
UCLASS()
class UTArrayIndexAccessObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe []: first slot after Add, last slot, sequential reads, then write slot 1.
	 *
	 * @Kind Observe
	 * @Covers TArray.opIndex
	 * @Inputs TArray<int> via Add(10,20,30); read [0]/[1]/[2]; write [1] = 99
	 * @Return true when reads are [10,20,30] and write leaves [10,99,30]
	 */
	UFUNCTION()
	bool IndexReadAndWritePreserveOtherSlots()
	{
		TArray<int> Array;

		Array.Add(10);
		if (Array[0] != 10)
		{
			return false;
		}

		Array.Add(20);
		Array.Add(30);
		if (Array[2] != 30 || Array[0] != 10 || Array[1] != 20)
		{
			return false;
		}

		Array[1] = 99;
		return Array[0] == 10 && Array[1] == 99 && Array[2] == 30;
	}

	/**
	 * In-only: read [] order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [10, 20, 30]
	 * @Return true when Num() == 3 and elements are [10, 20, 30]
	 */
	UFUNCTION()
	bool ReadIndexOrder(const TArray<int>&in Values)
	{
		return Values.Num() == 3 && Values[0] == 10 && Values[1] == 20 && Values[2] == 30;
	}

	/**
	 * Out-only: fill an empty &out array then write slot 1.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [10, 99, 30]
	 */
	UFUNCTION()
	void FillArrayByIndexWrite(TArray<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
		Result[1] = 99;
	}

	/**
	 * Inout: write slot 1 of an existing [10, 20, 30].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Array received as TArray<int>&inout, starts as [10, 20, 30]
	 * @Inputs Values.Num() == 3 with [10, 20, 30]
	 * @Return void; Values becomes [10, 99, 30]
	 */
	UFUNCTION()
	void WriteIndexedSlot(TArray<int>&inout Values)
	{
		Values[1] = 99;
	}

	/**
	 * Observe [] for float: sequential reads, then write slot 1.
	 *
	 * @Kind Observe
	 * @Covers TArray.opIndex
	 * @Inputs Add three float; write [1]
	 * @Return true when write leaves only slot 1 changed
	 */
	UFUNCTION()
	bool IndexReadAndWritePreserveOtherSlots_float()
	{
		TArray<float> Array;
		Array.Add(10.0f);
		if (Array[0] != 10.0f)
		{
			return false;
		}
		Array.Add(20.0f);
		Array.Add(30.0f);
		if (Array[2] != 30.0f || Array[0] != 10.0f || Array[1] != 20.0f)
		{
			return false;
		}
		Array[1] = 99.0f;
		return Array[0] == 10.0f && Array[1] == 99.0f && Array[2] == 30.0f;
	}

	/**
	 * In-only: read [] order from a const&in float array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs three-element array
	 * @Return true when elements match insertion order
	 */
	UFUNCTION()
	bool ReadIndexOrder_float(const TArray<float>&in Values)
	{
		return Values.Num() == 3 && Values[0] == 10.0f && Values[1] == 20.0f && Values[2] == 30.0f;
	}

	/**
	 * Out-only: fill an empty &out float array then write slot 1.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; slot 1 overwritten
	 */
	UFUNCTION()
	void FillArrayByIndexWrite_float(TArray<float>&out Result)
	{
		Result.Add(10.0f);
		Result.Add(20.0f);
		Result.Add(30.0f);
		Result[1] = 99.0f;
	}

	/**
	 * Inout: write slot 1 of an existing three-element float array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs Values.Num() == 3
	 * @Return void; slot 1 overwritten
	 */
	UFUNCTION()
	void WriteIndexedSlot_float(TArray<float>&inout Values)
	{
		Values[1] = 99.0f;
	}

	/**
	 * Observe [] for FString: sequential reads, then write slot 1.
	 *
	 * @Kind Observe
	 * @Covers TArray.opIndex
	 * @Inputs Add three FString; write [1]
	 * @Return true when write leaves only slot 1 changed
	 */
	UFUNCTION()
	bool IndexReadAndWritePreserveOtherSlots_FString()
	{
		TArray<FString> Array;
		Array.Add("juliet");
		if (Array[0] != "juliet")
		{
			return false;
		}
		Array.Add("lima");
		Array.Add("mike");
		if (Array[2] != "mike" || Array[0] != "juliet" || Array[1] != "lima")
		{
			return false;
		}
		Array[1] = "omega";
		return Array[0] == "juliet" && Array[1] == "omega" && Array[2] == "mike";
	}

	/**
	 * In-only: read [] order from a const&in FString array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs three-element array
	 * @Return true when elements match insertion order
	 */
	UFUNCTION()
	bool ReadIndexOrder_FString(const TArray<FString>&in Values)
	{
		return Values.Num() == 3 && Values[0] == "juliet" && Values[1] == "lima" && Values[2] == "mike";
	}

	/**
	 * Out-only: fill an empty &out FString array then write slot 1.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; slot 1 overwritten
	 */
	UFUNCTION()
	void FillArrayByIndexWrite_FString(TArray<FString>&out Result)
	{
		Result.Add("juliet");
		Result.Add("lima");
		Result.Add("mike");
		Result[1] = "omega";
	}

	/**
	 * Inout: write slot 1 of an existing three-element FString array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs Values.Num() == 3
	 * @Return void; slot 1 overwritten
	 */
	UFUNCTION()
	void WriteIndexedSlot_FString(TArray<FString>&inout Values)
	{
		Values[1] = "omega";
	}

	/**
	 * Observe [] for FVector: sequential reads, then write slot 1.
	 *
	 * @Kind Observe
	 * @Covers TArray.opIndex
	 * @Inputs Add three FVector; write [1]
	 * @Return true when write leaves only slot 1 changed
	 */
	UFUNCTION()
	bool IndexReadAndWritePreserveOtherSlots_FVector()
	{
		TArray<FVector> Array;
		Array.Add(FVector(2.0f, 0.0f, 0.0f));
		if (!Array[0].Equals(FVector(2.0f, 0.0f, 0.0f)))
		{
			return false;
		}
		Array.Add(FVector(0.0f, 0.0f, 2.0f));
		Array.Add(FVector(2.0f, 2.0f, 0.0f));
		if (!Array[2].Equals(FVector(2.0f, 2.0f, 0.0f)) || !Array[0].Equals(FVector(2.0f, 0.0f, 0.0f)) || !Array[1].Equals(FVector(0.0f, 0.0f, 2.0f)))
		{
			return false;
		}
		Array[1] = FVector(9.0f, 9.0f, 9.0f);
		return Array[0].Equals(FVector(2.0f, 0.0f, 0.0f)) && Array[1].Equals(FVector(9.0f, 9.0f, 9.0f)) && Array[2].Equals(FVector(2.0f, 2.0f, 0.0f));
	}

	/**
	 * In-only: read [] order from a const&in FVector array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs three-element array
	 * @Return true when elements match insertion order
	 */
	UFUNCTION()
	bool ReadIndexOrder_FVector(const TArray<FVector>&in Values)
	{
		return Values.Num() == 3 && Values[0].Equals(FVector(2.0f, 0.0f, 0.0f)) && Values[1].Equals(FVector(0.0f, 0.0f, 2.0f)) && Values[2].Equals(FVector(2.0f, 2.0f, 0.0f));
	}

	/**
	 * Out-only: fill an empty &out FVector array then write slot 1.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; slot 1 overwritten
	 */
	UFUNCTION()
	void FillArrayByIndexWrite_FVector(TArray<FVector>&out Result)
	{
		Result.Add(FVector(2.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 2.0f));
		Result.Add(FVector(2.0f, 2.0f, 0.0f));
		Result[1] = FVector(9.0f, 9.0f, 9.0f);
	}

	/**
	 * Inout: write slot 1 of an existing three-element FVector array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Array received as TArray<FVector>&inout
	 * @Inputs Values.Num() == 3
	 * @Return void; slot 1 overwritten
	 */
	UFUNCTION()
	void WriteIndexedSlot_FVector(TArray<FVector>&inout Values)
	{
		Values[1] = FVector(9.0f, 9.0f, 9.0f);
	}

	/**
	 * Observe [] for bool: sequential reads, then write slot 1.
	 *
	 * @Kind Observe
	 * @Covers TArray.opIndex
	 * @Inputs [false, true, false]; write [1] = true already then [1] = false
	 * @Return true when the array becomes [false, false, false]
	 */
	UFUNCTION()
	bool IndexReadAndWritePreserveOtherSlots_bool()
	{
		TArray<bool> Array;
		Array.Add(false);
		if (Array[0] != false)
		{
			return false;
		}
		Array.Add(true);
		Array.Add(false);
		if (Array[2] != false || Array[0] != false || Array[1] != true)
		{
			return false;
		}
		Array[1] = false;
		return Array[0] == false && Array[1] == false && Array[2] == false;
	}

	/**
	 * In-only: read [] order from a const&in bool array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs Values == [false, true, false]
	 * @Return true when elements are [false, true, false]
	 */
	UFUNCTION()
	bool ReadIndexOrder_bool(const TArray<bool>&in Values)
	{
		return Values.Num() == 3 && Values[0] == false && Values[1] == true && Values[2] == false;
	}

	/**
	 * Out-only: fill an empty &out bool array then write slot 1.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result becomes [false, false, false]
	 */
	UFUNCTION()
	void FillArrayByIndexWrite_bool(TArray<bool>&out Result)
	{
		Result.Add(false);
		Result.Add(true);
		Result.Add(false);
		Result[1] = false;
	}

	/**
	 * Inout: write slot 1 of an existing [false, true, false].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs [false, true, false]
	 * @Return void; Values becomes [false, false, false]
	 */
	UFUNCTION()
	void WriteIndexedSlot_bool(TArray<bool>&inout Values)
	{
		Values[1] = false;
	}

	/**
	 * Observe [] for UObject handles: sequential reads, then write slot 1.
	 *
	 * @Kind Observe
	 * @Covers TArray.opIndex
	 * @Inputs three named NewObject temps; write [1] to a fourth
	 * @Return true when only slot 1 identity changes
	 */
	UFUNCTION()
	bool IndexReadAndWritePreserveOtherSlots_UObject()
	{
		TArray<UObject> Array;
		UObject First = NewObject(GetTransientPackage(), UTArrayIndexAccessObject::StaticClass(), n"TArrayIndex_First", true);
		UObject Second = NewObject(GetTransientPackage(), UTArrayIndexAccessObject::StaticClass(), n"TArrayIndex_Second", true);
		UObject Third = NewObject(GetTransientPackage(), UTArrayIndexAccessObject::StaticClass(), n"TArrayIndex_Third", true);
		UObject Wrote = NewObject(GetTransientPackage(), UTArrayIndexAccessObject::StaticClass(), n"TArrayIndex_Wrote", true);
		if (First == nullptr || Second == nullptr || Third == nullptr || Wrote == nullptr)
		{
			return false;
		}
		Array.Add(First);
		if (Array[0] != First)
		{
			return false;
		}
		Array.Add(Second);
		Array.Add(Third);
		if (Array[2] != Third || Array[0] != First || Array[1] != Second)
		{
			return false;
		}
		Array[1] = Wrote;
		return Array[0] == First && Array[1] == Wrote && Array[2] == Third;
	}

	/**
	 * In-only: read [] order from a const&in UObject array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs three distinct non-null handles
	 * @Return true when Num() == 3 and identities differ
	 */
	UFUNCTION()
	bool ReadIndexOrder_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 3 && Values[0] != nullptr && Values[1] != nullptr && Values[2] != nullptr
			&& Values[0] != Values[1] && Values[1] != Values[2] && Values[0] != Values[2];
	}

	/**
	 * Out-only: fill an empty &out UObject array then write slot 1.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result has three handles and slot 1 replaced
	 */
	UFUNCTION()
	void FillArrayByIndexWrite_UObject(TArray<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTArrayIndexAccessObject::StaticClass(), n"TArrayIndex_Fill_0", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayIndexAccessObject::StaticClass(), n"TArrayIndex_Fill_1", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayIndexAccessObject::StaticClass(), n"TArrayIndex_Fill_2", true));
		Result[1] = NewObject(GetTransientPackage(), UTArrayIndexAccessObject::StaticClass(), n"TArrayIndex_Fill_W", true);
	}

	/**
	 * Inout: write slot 1 of an existing three-handle UObject array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs Values.Num() == 3
	 * @Return void; Values[1] is a new handle
	 */
	UFUNCTION()
	void WriteIndexedSlot_UObject(TArray<UObject>&inout Values)
	{
		Values[1] = NewObject(GetTransientPackage(), UTArrayIndexAccessObject::StaticClass(), n"TArrayIndex_Inout", true);
	}

}
/** @end */
