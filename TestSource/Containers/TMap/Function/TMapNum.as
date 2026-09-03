/**
 * Num is the live pair count, not capacity. Overwrite of an existing key does not
 * change Num. Observed locally, then through UFUNCTION in, out, and inout.
 * int/int is canonical; other key/value shapes repeat the same four entries with a type suffix.
 *
 * @Theme Containers.TMap
 * @Subject TMap.Num
 * @Harness Function
 * @Tag Containers.TMap.TMapNum
 * @Namespace TMapTest
 */

UCLASS()
class UTMapNumObject : UObject
{
}

namespace TMapTest
{
	/**
	 * Observe Num: empty is 0, Add grows, overwrite keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TMap.Num
	 * @Inputs Default-constructed TMap<int, int>; Add two keys; overwrite first
	 * @Return true when empty is 0 and overwrite leaves Num == 2
	 */
	UFUNCTION()
	NumCountsDistinctKeys()
	{
		TMap<int, int> Map;
		if (Map.Num() != 0)
		{
			return false;
		}

		Map.Add(10, 100);
		if (Map.Num() != 1)
		{
			return false;
		}

		Map.Add(20, 200);
		Map.Add(10, 999);
		return Map.Num() == 2;
	}

	/**
	 * In-only: Num on a const&in TMap<int, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	ReadNum(const TMap<int, int>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out TMap<int, int> so Num becomes 3.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	FillMapForNum(TMap<int, int>&out Result)
	{
		Result.Add(10, 100);
		Result.Add(20, 200);
		Result.Add(30, 300);
	}

	/**
	 * Inout: Add a third key so Num becomes 3.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Values Map received as TMap<int, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	AppendForNum(TMap<int, int>&inout Values)
	{
		Values.Add(30, 300);
	}


	/**
	 * Observe Num_FString: empty is 0, Add grows, overwrite keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TMap.Num
	 * @Inputs Default-constructed TMap<FString, int>; Add two keys; overwrite first
	 * @Return true when empty is 0 and overwrite leaves Num == 2
	 */
	UFUNCTION()
	NumCountsDistinctKeys_FString()
	{
		TMap<FString, int> Map;
		if (Map.Num() != 0)
		{
			return false;
		}

		Map.Add("alpha", 100);
		if (Map.Num() != 1)
		{
			return false;
		}

		Map.Add("beta", 200);
		Map.Add("alpha", 999);
		return Map.Num() == 2;
	}

	/**
	 * In-only: Num on a const&in TMap<FString, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Values Source map received as const TMap<FString, int>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	ReadNum_FString(const TMap<FString, int>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out TMap<FString, int> so Num becomes 3.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Result Destination received as TMap<FString, int>&out
	 * @Inputs Empty &out TMap<FString, int>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	FillMapForNum_FString(TMap<FString, int>&out Result)
	{
		Result.Add("alpha", 100);
		Result.Add("beta", 200);
		Result.Add("gamma", 300);
	}

	/**
	 * Inout: Add a third key so Num becomes 3_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Values Map received as TMap<FString, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	AppendForNum_FString(TMap<FString, int>&inout Values)
	{
		Values.Add("gamma", 300);
	}


	/**
	 * Observe Num_FName: empty is 0, Add grows, overwrite keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TMap.Num
	 * @Inputs Default-constructed TMap<FName, int>; Add two keys; overwrite first
	 * @Return true when empty is 0 and overwrite leaves Num == 2
	 */
	UFUNCTION()
	NumCountsDistinctKeys_FName()
	{
		TMap<FName, int> Map;
		if (Map.Num() != 0)
		{
			return false;
		}

		Map.Add(n"Red", 1);
		if (Map.Num() != 1)
		{
			return false;
		}

		Map.Add(n"Green", 2);
		Map.Add(n"Red", 9);
		return Map.Num() == 2;
	}

	/**
	 * In-only: Num on a const&in TMap<FName, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Values Source map received as const TMap<FName, int>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	ReadNum_FName(const TMap<FName, int>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out TMap<FName, int> so Num becomes 3.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Result Destination received as TMap<FName, int>&out
	 * @Inputs Empty &out TMap<FName, int>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	FillMapForNum_FName(TMap<FName, int>&out Result)
	{
		Result.Add(n"Red", 1);
		Result.Add(n"Green", 2);
		Result.Add(n"Blue", 3);
	}

	/**
	 * Inout: Add a third key so Num becomes 3_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Values Map received as TMap<FName, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	AppendForNum_FName(TMap<FName, int>&inout Values)
	{
		Values.Add(n"Blue", 3);
	}


	/**
	 * Observe Num_bool: empty is 0, Add grows, overwrite keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TMap.Num
	 * @Inputs Default-constructed TMap<int, bool>; Add two keys; overwrite first
	 * @Return true when empty is 0 and overwrite leaves Num == 2
	 */
	UFUNCTION()
	NumCountsDistinctKeys_bool()
	{
		TMap<int, bool> Map;
		if (Map.Num() != 0)
		{
			return false;
		}

		Map.Add(1, true);
		if (Map.Num() != 1)
		{
			return false;
		}

		Map.Add(2, false);
		Map.Add(1, false);
		return Map.Num() == 2;
	}

	/**
	 * In-only: Num on a const&in TMap<int, bool> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Values Source map received as const TMap<int, bool>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	ReadNum_bool(const TMap<int, bool>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out TMap<int, bool> so Num becomes 3.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Result Destination received as TMap<int, bool>&out
	 * @Inputs Empty &out TMap<int, bool>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	FillMapForNum_bool(TMap<int, bool>&out Result)
	{
		Result.Add(1, true);
		Result.Add(2, false);
		Result.Add(3, true);
	}

	/**
	 * Inout: Add a third key so Num becomes 3_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Values Map received as TMap<int, bool>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	AppendForNum_bool(TMap<int, bool>&inout Values)
	{
		Values.Add(3, true);
	}


	/**
	 * Observe Num_FVector: empty is 0, Add grows, overwrite keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TMap.Num
	 * @Inputs Default-constructed TMap<int, FVector>; Add two keys; overwrite first
	 * @Return true when empty is 0 and overwrite leaves Num == 2
	 */
	UFUNCTION()
	NumCountsDistinctKeys_FVector()
	{
		TMap<int, FVector> Map;
		if (Map.Num() != 0)
		{
			return false;
		}

		Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
		if (Map.Num() != 1)
		{
			return false;
		}

		Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Map.Add(1, FVector(9.0f, 9.0f, 9.0f));
		return Map.Num() == 2;
	}

	/**
	 * In-only: Num on a const&in TMap<int, FVector> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Values Source map received as const TMap<int, FVector>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	ReadNum_FVector(const TMap<int, FVector>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out TMap<int, FVector> so Num becomes 3.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Result Destination received as TMap<int, FVector>&out
	 * @Inputs Empty &out TMap<int, FVector>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	FillMapForNum_FVector(TMap<int, FVector>&out Result)
	{
		Result.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Result.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Result.Add(3, FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Inout: Add a third key so Num becomes 3_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Values Map received as TMap<int, FVector>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	AppendForNum_FVector(TMap<int, FVector>&inout Values)
	{
		Values.Add(3, FVector(0.0f, 0.0f, 1.0f));
	}


	/**
	 * Observe Num_UObject: empty is 0, Add grows, overwrite keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TMap.Num
	 * @Inputs Default-constructed TMap<int, UObject>; Add two keys; overwrite first
	 * @Return true when empty is 0 and overwrite leaves Num == 2
	 */
	UFUNCTION()
	NumCountsDistinctKeys_UObject()
	{
		TMap<int, UObject> Map;
		UObject First = NewObject(GetTransientPackage(), UTMapNumObject::StaticClass(), n"TMapNum_First", true);
		if (Map.Num() != 0 || First == nullptr)
		{
			return false;
		}
		Map.Add(10, First);
		Map.Add(20, First);
		Map.Add(10, First);
		return Map.Num() == 2;
	}

	/**
	 * In-only: Num on a const&in TMap<int, UObject> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Values Source map received as const TMap<int, UObject>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	ReadNum_UObject(const TMap<int, UObject>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out TMap<int, UObject> so Num becomes 3.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Result Destination received as TMap<int, UObject>&out
	 * @Inputs Empty &out TMap<int, UObject>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	FillMapForNum_UObject(TMap<int, UObject>&out Result)
	{
		Result.Add(10, NewObject(GetTransientPackage(), UTMapNumObject::StaticClass(), n"UTMapNumObject_Fill_0", true));
		Result.Add(20, NewObject(GetTransientPackage(), UTMapNumObject::StaticClass(), n"UTMapNumObject_Fill_1", true));
		Result.Add(30, NewObject(GetTransientPackage(), UTMapNumObject::StaticClass(), n"UTMapNumObject_Fill_2", true));
	}

	/**
	 * Inout: Add a third key so Num becomes 3_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Num
	 * @Param Values Map received as TMap<int, UObject>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	AppendForNum_UObject(TMap<int, UObject>&inout Values)
	{
		Values.Add(30, NewObject(GetTransientPackage(), UTMapNumObject::StaticClass(), n"UTMapNumObject_Append", true));
	}


}
