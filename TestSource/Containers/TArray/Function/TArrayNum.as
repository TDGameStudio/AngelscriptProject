/**
 * Num is 0 on a default array and grows by one for each Add.
 * Length is observed locally, then through UFUNCTION in, out, and inout.
 *
 * int is the canonical case; other element types repeat the same four entries with a type suffix.
 *
 * @Theme Containers.TArray
 * @Subject TArray.Num
 * @Harness Function
 * @Tag Containers.TArray.TArrayNum
 * @Namespace TArrayTest
 */

UCLASS()
class UTArrayNumObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe Num: empty is 0, one Add is 1, three Adds are 3.
	 *
	 * @Kind Observe
	 * @Covers TArray.Num
	 * @Inputs Default-constructed TArray<int>; Add(1); Add(2); Add(3)
	 * @Return true when Num is 0, then 1, then 3
	 */
	UFUNCTION()
	bool NumGrowsWithAdd()
	{
		TArray<int> Array;
		if (Array.Num() != 0)
		{
			return false;
		}

		Array.Add(1);
		if (Array.Num() != 1)
		{
			return false;
		}

		Array.Add(2);
		Array.Add(3);
		return Array.Num() == 3;
	}

	/**
	 * In-only: read Num from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [1, 2, 3]
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadNum(const TArray<int>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out array so Num becomes 3.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result.Num() becomes 3 with [1, 2, 3]
	 */
	UFUNCTION()
	void FillArrayForNum(TArray<int>&out Result)
	{
		Result.Add(1);
		Result.Add(2);
		Result.Add(3);
	}

	/**
	 * Inout: keep existing elements and Add one more so Num grows by one.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Values Array received as TArray<int>&inout, starts as [1, 2]
	 * @Inputs Values.Num() == 2 with [1, 2]
	 * @Return void; Values.Num() becomes 3 with [1, 2, 3]
	 */
	UFUNCTION()
	void GrowNumByOne(TArray<int>&inout Values)
	{
		Values.Add(3);
	}

	/**
	 * Observe Num for float: empty is 0, one Add is 1, three Adds are 3.
	 *
	 * @Kind Observe
	 * @Covers TArray.Num
	 * @Inputs Default-constructed TArray<float>; three Adds
	 * @Return true when Num is 0, then 1, then 3
	 */
	UFUNCTION()
	bool NumGrowsWithAdd_float()
	{
		TArray<float> Array;
		if (Array.Num() != 0)
		{
			return false;
		}
		Array.Add(1.0f);
		if (Array.Num() != 1)
		{
			return false;
		}
		Array.Add(2.0f);
		Array.Add(3.0f);
		return Array.Num() == 3;
	}

	/**
	 * In-only: read Num from a const&in float array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadNum_float(const TArray<float>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out float array so Num becomes 3.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result.Num() becomes 3
	 */
	UFUNCTION()
	void FillArrayForNum_float(TArray<float>&out Result)
	{
		Result.Add(1.0f);
		Result.Add(2.0f);
		Result.Add(3.0f);
	}

	/**
	 * Inout: keep existing float elements and Add one more so Num grows by one.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Values Array received as TArray<float>&inout, starts with two elements
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() becomes 3
	 */
	UFUNCTION()
	void GrowNumByOne_float(TArray<float>&inout Values)
	{
		Values.Add(3.0f);
	}

	/**
	 * Observe Num for FString: empty is 0, one Add is 1, three Adds are 3.
	 *
	 * @Kind Observe
	 * @Covers TArray.Num
	 * @Inputs Default-constructed TArray<FString>; three Adds
	 * @Return true when Num is 0, then 1, then 3
	 */
	UFUNCTION()
	bool NumGrowsWithAdd_FString()
	{
		TArray<FString> Array;
		if (Array.Num() != 0)
		{
			return false;
		}
		Array.Add("alpha");
		if (Array.Num() != 1)
		{
			return false;
		}
		Array.Add("beta");
		Array.Add("gamma");
		return Array.Num() == 3;
	}

	/**
	 * In-only: read Num from a const&in FString array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadNum_FString(const TArray<FString>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out FString array so Num becomes 3.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result.Num() becomes 3
	 */
	UFUNCTION()
	void FillArrayForNum_FString(TArray<FString>&out Result)
	{
		Result.Add("alpha");
		Result.Add("beta");
		Result.Add("gamma");
	}

	/**
	 * Inout: keep existing FString elements and Add one more so Num grows by one.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Values Array received as TArray<FString>&inout, starts with two elements
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() becomes 3
	 */
	UFUNCTION()
	void GrowNumByOne_FString(TArray<FString>&inout Values)
	{
		Values.Add("gamma");
	}

	/**
	 * Observe Num for FVector: empty is 0, one Add is 1, three Adds are 3.
	 *
	 * @Kind Observe
	 * @Covers TArray.Num
	 * @Inputs Default-constructed TArray<FVector>; three Adds
	 * @Return true when Num is 0, then 1, then 3
	 */
	UFUNCTION()
	bool NumGrowsWithAdd_FVector()
	{
		TArray<FVector> Array;
		if (Array.Num() != 0)
		{
			return false;
		}
		Array.Add(FVector(1.0f, 0.0f, 0.0f));
		if (Array.Num() != 1)
		{
			return false;
		}
		Array.Add(FVector(0.0f, 1.0f, 0.0f));
		Array.Add(FVector(0.0f, 0.0f, 1.0f));
		return Array.Num() == 3;
	}

	/**
	 * In-only: read Num from a const&in FVector array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadNum_FVector(const TArray<FVector>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out FVector array so Num becomes 3.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result.Num() becomes 3
	 */
	UFUNCTION()
	void FillArrayForNum_FVector(TArray<FVector>&out Result)
	{
		Result.Add(FVector(1.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Inout: keep existing FVector elements and Add one more so Num grows by one.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Values Array received as TArray<FVector>&inout, starts with two elements
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() becomes 3
	 */
	UFUNCTION()
	void GrowNumByOne_FVector(TArray<FVector>&inout Values)
	{
		Values.Add(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Observe Num for bool: empty is 0, one Add is 1, three Adds are 3.
	 *
	 * @Kind Observe
	 * @Covers TArray.Num
	 * @Inputs Add(false); Add(true); Add(false)
	 * @Return true when Num is 0, then 1, then 3
	 */
	UFUNCTION()
	bool NumGrowsWithAdd_bool()
	{
		TArray<bool> Array;
		if (Array.Num() != 0)
		{
			return false;
		}
		Array.Add(false);
		if (Array.Num() != 1)
		{
			return false;
		}
		Array.Add(true);
		Array.Add(false);
		return Array.Num() == 3;
	}

	/**
	 * In-only: read Num from a const&in bool array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadNum_bool(const TArray<bool>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out bool array so Num becomes 3.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result.Num() becomes 3
	 */
	UFUNCTION()
	void FillArrayForNum_bool(TArray<bool>&out Result)
	{
		Result.Add(false);
		Result.Add(true);
		Result.Add(false);
	}

	/**
	 * Inout: keep existing bool elements and Add one more so Num grows by one.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Values Array received as TArray<bool>&inout, starts as [false, true]
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() becomes 3
	 */
	UFUNCTION()
	void GrowNumByOne_bool(TArray<bool>&inout Values)
	{
		Values.Add(false);
	}

	/**
	 * Observe Num for UObject handles: empty is 0, one Add is 1, three Adds are 3.
	 *
	 * @Kind Observe
	 * @Covers TArray.Num
	 * @Inputs three named NewObject temps
	 * @Return true when Num is 0, then 1, then 3
	 */
	UFUNCTION()
	bool NumGrowsWithAdd_UObject()
	{
		TArray<UObject> Array;
		if (Array.Num() != 0)
		{
			return false;
		}
		UObject First = NewObject(GetTransientPackage(), UTArrayNumObject::StaticClass(), n"TArrayNum_First", true);
		UObject Second = NewObject(GetTransientPackage(), UTArrayNumObject::StaticClass(), n"TArrayNum_Second", true);
		UObject Third = NewObject(GetTransientPackage(), UTArrayNumObject::StaticClass(), n"TArrayNum_Third", true);
		if (First == nullptr || Second == nullptr || Third == nullptr)
		{
			return false;
		}
		Array.Add(First);
		if (Array.Num() != 1)
		{
			return false;
		}
		Array.Add(Second);
		Array.Add(Third);
		return Array.Num() == 3;
	}

	/**
	 * In-only: read Num from a const&in UObject array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadNum_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out UObject array so Num becomes 3.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result.Num() becomes 3
	 */
	UFUNCTION()
	void FillArrayForNum_UObject(TArray<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTArrayNumObject::StaticClass(), n"TArrayNum_Fill_0", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayNumObject::StaticClass(), n"TArrayNum_Fill_1", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayNumObject::StaticClass(), n"TArrayNum_Fill_2", true));
	}

	/**
	 * Inout: keep existing UObject elements and Add one NewObject so Num grows by one.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Num
	 * @Param Values Array received as TArray<UObject>&inout, starts with two handles
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() becomes 3
	 */
	UFUNCTION()
	void GrowNumByOne_UObject(TArray<UObject>&inout Values)
	{
		Values.Add(NewObject(GetTransientPackage(), UTArrayNumObject::StaticClass(), n"TArrayNum_Append", true));
	}

}
