/**
 * RemoveAt deletes one index and shifts later elements down.
 * Shift-remove is observed locally, then through UFUNCTION in, out, and inout.
 *
 * int is the canonical case; other element types repeat the same four entries with a type suffix.
 *
 * @Theme Containers.TArray
 * @Subject TArray.RemoveAt
 * @Harness Function
 * @Tag Containers.TArray.TArrayRemoveAt
 * @Namespace TArrayTest
 */

UCLASS()
class UTArrayRemoveAtObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe RemoveAt: drop index 0, drop last index, then remove until empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAt
	 * @Inputs TArray<int> [1,2]; RemoveAt(0); then [2,3,4]; RemoveAt(2); then remove to empty
	 * @Return true when order is [2], then [2,3], then Num == 0
	 */
	UFUNCTION()
	bool RemoveAtShiftsAndCanEmpty()
	{
		TArray<int> Array;

		Array.Add(1);
		Array.Add(2);
		Array.RemoveAt(0);
		if (Array.Num() != 1 || Array[0] != 2)
		{
			return false;
		}

		Array.Add(3);
		Array.Add(4);
		Array.RemoveAt(2);
		if (Array.Num() != 2 || Array[0] != 2 || Array[1] != 3)
		{
			return false;
		}

		Array.RemoveAt(0);
		Array.RemoveAt(0);
		return Array.Num() == 0;
	}

	/**
	 * In-only: read post-RemoveAt order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [2, 3]
	 * @Return true when Num() == 2 and elements are [2, 3]
	 */
	UFUNCTION()
	bool ReadAfterRemoveAt(const TArray<int>&in Values)
	{
		return Values.Num() == 2 && Values[0] == 2 && Values[1] == 3;
	}

	/**
	 * Out-only: fill an empty &out array then RemoveAt(0).
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [2, 3, 4]
	 */
	UFUNCTION()
	void FillArrayByRemoveAt(TArray<int>&out Result)
	{
		Result.Add(1);
		Result.Add(2);
		Result.Add(3);
		Result.Add(4);
		Result.RemoveAt(0);
	}

	/**
	 * Inout: RemoveAt(0) on an existing [1, 2].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Array received as TArray<int>&inout, starts as [1, 2]
	 * @Inputs Values.Num() == 2 with [1, 2]
	 * @Return void; Values becomes [2]
	 */
	UFUNCTION()
	void RemoveAtHead(TArray<int>&inout Values)
	{
		Values.RemoveAt(0);
	}

	/**
	 * Observe RemoveAt for float: drop index 0, drop last, then empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAt
	 * @Inputs [a,b]; RemoveAt(0); add c,d; RemoveAt(2); remove to empty
	 * @Return true when order is [b], then [b,c], then Num == 0
	 */
	UFUNCTION()
	bool RemoveAtShiftsAndCanEmpty_float()
	{
		TArray<float> Array;
		Array.Add(1.0f);
		Array.Add(2.0f);
		Array.RemoveAt(0);
		if (Array.Num() != 1 || Array[0] != 2.0f)
		{
			return false;
		}
		Array.Add(3.0f);
		Array.Add(4.0f);
		Array.RemoveAt(2);
		if (Array.Num() != 2 || Array[0] != 2.0f || Array[1] != 3.0f)
		{
			return false;
		}
		Array.RemoveAt(0);
		Array.RemoveAt(0);
		return Array.Num() == 0;
	}

	/**
	 * In-only: read post-RemoveAt float order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs [b, c]
	 * @Return true when Num() == 2 and order matches
	 */
	UFUNCTION()
	bool ReadAfterRemoveAt_float(const TArray<float>&in Values)
	{
		return Values.Num() == 2 && Values[0] == 2.0f && Values[1] == 3.0f;
	}

	/**
	 * Out-only: fill an empty &out float array then RemoveAt(0).
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result is [b,c,d]
	 */
	UFUNCTION()
	void FillArrayByRemoveAt_float(TArray<float>&out Result)
	{
		Result.Add(1.0f);
		Result.Add(2.0f);
		Result.Add(3.0f);
		Result.Add(4.0f);
		Result.RemoveAt(0);
	}

	/**
	 * Inout: RemoveAt(0) on an existing two-element float array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs [a, b]
	 * @Return void; Values becomes [b]
	 */
	UFUNCTION()
	void RemoveAtHead_float(TArray<float>&inout Values)
	{
		Values.RemoveAt(0);
	}

	/**
	 * Observe RemoveAt for FString: drop index 0, drop last, then empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAt
	 * @Inputs [a,b]; RemoveAt(0); add c,d; RemoveAt(2); remove to empty
	 * @Return true when order is [b], then [b,c], then Num == 0
	 */
	UFUNCTION()
	bool RemoveAtShiftsAndCanEmpty_FString()
	{
		TArray<FString> Array;
		Array.Add("alpha");
		Array.Add("beta");
		Array.RemoveAt(0);
		if (Array.Num() != 1 || Array[0] != "beta")
		{
			return false;
		}
		Array.Add("gamma");
		Array.Add("delta");
		Array.RemoveAt(2);
		if (Array.Num() != 2 || Array[0] != "beta" || Array[1] != "gamma")
		{
			return false;
		}
		Array.RemoveAt(0);
		Array.RemoveAt(0);
		return Array.Num() == 0;
	}

	/**
	 * In-only: read post-RemoveAt FString order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs [b, c]
	 * @Return true when Num() == 2 and order matches
	 */
	UFUNCTION()
	bool ReadAfterRemoveAt_FString(const TArray<FString>&in Values)
	{
		return Values.Num() == 2 && Values[0] == "beta" && Values[1] == "gamma";
	}

	/**
	 * Out-only: fill an empty &out FString array then RemoveAt(0).
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result is [b,c,d]
	 */
	UFUNCTION()
	void FillArrayByRemoveAt_FString(TArray<FString>&out Result)
	{
		Result.Add("alpha");
		Result.Add("beta");
		Result.Add("gamma");
		Result.Add("delta");
		Result.RemoveAt(0);
	}

	/**
	 * Inout: RemoveAt(0) on an existing two-element FString array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs [a, b]
	 * @Return void; Values becomes [b]
	 */
	UFUNCTION()
	void RemoveAtHead_FString(TArray<FString>&inout Values)
	{
		Values.RemoveAt(0);
	}

	/**
	 * Observe RemoveAt for FVector: drop index 0, drop last, then empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAt
	 * @Inputs [a,b]; RemoveAt(0); add c,d; RemoveAt(2); remove to empty
	 * @Return true when order is [b], then [b,c], then Num == 0
	 */
	UFUNCTION()
	bool RemoveAtShiftsAndCanEmpty_FVector()
	{
		TArray<FVector> Array;
		Array.Add(FVector(1.0f, 0.0f, 0.0f));
		Array.Add(FVector(0.0f, 1.0f, 0.0f));
		Array.RemoveAt(0);
		if (Array.Num() != 1 || !Array[0].Equals(FVector(0.0f, 1.0f, 0.0f)))
		{
			return false;
		}
		Array.Add(FVector(0.0f, 0.0f, 1.0f));
		Array.Add(FVector(1.0f, 1.0f, 0.0f));
		Array.RemoveAt(2);
		if (Array.Num() != 2 || !Array[0].Equals(FVector(0.0f, 1.0f, 0.0f)) || !Array[1].Equals(FVector(0.0f, 0.0f, 1.0f)))
		{
			return false;
		}
		Array.RemoveAt(0);
		Array.RemoveAt(0);
		return Array.Num() == 0;
	}

	/**
	 * In-only: read post-RemoveAt FVector order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs [b, c]
	 * @Return true when Num() == 2 and order matches
	 */
	UFUNCTION()
	bool ReadAfterRemoveAt_FVector(const TArray<FVector>&in Values)
	{
		return Values.Num() == 2 && Values[0].Equals(FVector(0.0f, 1.0f, 0.0f)) && Values[1].Equals(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Out-only: fill an empty &out FVector array then RemoveAt(0).
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result is [b,c,d]
	 */
	UFUNCTION()
	void FillArrayByRemoveAt_FVector(TArray<FVector>&out Result)
	{
		Result.Add(FVector(1.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 1.0f));
		Result.Add(FVector(1.0f, 1.0f, 0.0f));
		Result.RemoveAt(0);
	}

	/**
	 * Inout: RemoveAt(0) on an existing two-element FVector array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Array received as TArray<FVector>&inout
	 * @Inputs [a, b]
	 * @Return void; Values becomes [b]
	 */
	UFUNCTION()
	void RemoveAtHead_FVector(TArray<FVector>&inout Values)
	{
		Values.RemoveAt(0);
	}

	/**
	 * Observe RemoveAt for bool: drop index 0, drop last, then empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAt
	 * @Inputs [true, false]; RemoveAt(0); add true,false; RemoveAt(2); empty
	 * @Return true when Num reaches 0
	 */
	UFUNCTION()
	bool RemoveAtShiftsAndCanEmpty_bool()
	{
		TArray<bool> Array;
		Array.Add(true);
		Array.Add(false);
		Array.RemoveAt(0);
		if (Array.Num() != 1 || Array[0] != false)
		{
			return false;
		}
		Array.Add(true);
		Array.Add(false);
		Array.RemoveAt(2);
		if (Array.Num() != 2 || Array[0] != false || Array[1] != true)
		{
			return false;
		}
		Array.RemoveAt(0);
		Array.RemoveAt(0);
		return Array.Num() == 0;
	}

	/**
	 * In-only: read post-RemoveAt bool order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs [false, true]
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAfterRemoveAt_bool(const TArray<bool>&in Values)
	{
		return Values.Num() == 2 && Values[0] == false && Values[1] == true;
	}

	/**
	 * Out-only: fill an empty &out bool array then RemoveAt(0).
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillArrayByRemoveAt_bool(TArray<bool>&out Result)
	{
		Result.Add(true);
		Result.Add(false);
		Result.Add(true);
		Result.Add(false);
		Result.RemoveAt(0);
	}

	/**
	 * Inout: RemoveAt(0) on an existing [true, false].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs [true, false]
	 * @Return void; Values becomes [false]
	 */
	UFUNCTION()
	void RemoveAtHead_bool(TArray<bool>&inout Values)
	{
		Values.RemoveAt(0);
	}

	/**
	 * Observe RemoveAt for UObject handles: drop index 0, drop last, then empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAt
	 * @Inputs two handles; RemoveAt(0); add two; RemoveAt(2); empty
	 * @Return true when Num reaches 0
	 */
	UFUNCTION()
	bool RemoveAtShiftsAndCanEmpty_UObject()
	{
		UObject A = NewObject(GetTransientPackage(), UTArrayRemoveAtObject::StaticClass(), n"TArrayRemoveAt_A", true);
		UObject B = NewObject(GetTransientPackage(), UTArrayRemoveAtObject::StaticClass(), n"TArrayRemoveAt_B", true);
		UObject C = NewObject(GetTransientPackage(), UTArrayRemoveAtObject::StaticClass(), n"TArrayRemoveAt_C", true);
		UObject D = NewObject(GetTransientPackage(), UTArrayRemoveAtObject::StaticClass(), n"TArrayRemoveAt_D", true);
		if (A == nullptr || B == nullptr || C == nullptr || D == nullptr)
		{
			return false;
		}
		TArray<UObject> Array;
		Array.Add(A);
		Array.Add(B);
		Array.RemoveAt(0);
		if (Array.Num() != 1 || Array[0] != B)
		{
			return false;
		}
		Array.Add(C);
		Array.Add(D);
		Array.RemoveAt(2);
		if (Array.Num() != 2 || Array[0] != B || Array[1] != C)
		{
			return false;
		}
		Array.RemoveAt(0);
		Array.RemoveAt(0);
		return Array.Num() == 0;
	}

	/**
	 * In-only: read post-RemoveAt UObject order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs Num() == 2
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAfterRemoveAt_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: fill an empty &out UObject array then RemoveAt(0).
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillArrayByRemoveAt_UObject(TArray<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTArrayRemoveAtObject::StaticClass(), n"TArrayRemoveAt_Fill_A", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayRemoveAtObject::StaticClass(), n"TArrayRemoveAt_Fill_B", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayRemoveAtObject::StaticClass(), n"TArrayRemoveAt_Fill_C", true));
		Result.Add(NewObject(GetTransientPackage(), UTArrayRemoveAtObject::StaticClass(), n"TArrayRemoveAt_Fill_D", true));
		Result.RemoveAt(0);
	}

	/**
	 * Inout: RemoveAt(0) on an existing two-handle UObject array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs Num() == 2
	 * @Return void; Values.Num() == 1
	 */
	UFUNCTION()
	void RemoveAtHead_UObject(TArray<UObject>&inout Values)
	{
		Values.RemoveAt(0);
	}

}
