/**
 * @version v1
 * @summary Remove deletes an existing key and reports whether it existed. Remove is the RoundTrip surface; RemoveAndCopyValue stays Observe (int only). int/int is canonical; other shapes repeat the same four entries with a type.
 * @topic Containers
 */
/**
 * @version root
 * @summary Remove deletes an existing key and reports whether it existed. Remove is the RoundTrip surface; RemoveAndCopyValue stays Observe (int only). int/int is canonical; other shapes repeat the same four entries with a type.
 * @topic Baseline
 */
UCLASS()
class UTMapRemoveObject : UObject
{
}

namespace TMapTest
{
	/**
	 * Observe Remove: existing key is dropped; missing key returns false.
	 *
	 * @Kind Observe
	 * @Covers TMap.Remove
	 * @Inputs TMap<int, int> with pairs; Remove present; Remove missing
	 * @Return true when present Remove shrinks Num and missing Remove is false
	 */
	UFUNCTION()
	bool RemovePresentAndMissAbsent()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		Map.Add(20, 200);
		Map.Add(30, 300);
		if (!Map.Remove(20) || Map.Contains(20) || Map.Num() != 2)
		{
			return false;
		}
		return !Map.Remove(99)
			&& Map.Contains(10)
			&& Map.Contains(30);
	}

	/**
	 * In-only: read a map that already had a key removed.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs Values.Num() == 2 with the remaining keys
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAfterRemove(const TMap<int, int>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: Add three pairs then Remove the middle key.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result.Num() == 2
	 */
	UFUNCTION()
	void FillThenRemove(TMap<int, int>&out Result)
	{
		Result.Add(10, 100);
		Result.Add(20, 200);
		Result.Add(30, 300);
		Result.Remove(20);
	}

	/**
	 * Inout: Remove one present key from an existing three-pair map.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Values Map received as TMap<int, int>&inout, starts with three keys
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 2
	 */
	UFUNCTION()
	void RemoveInPlace(TMap<int, int>&inout Values)
	{
		Values.Remove(20);
	}


	/**
	 * Observe Remove_FString: existing key is dropped; missing key returns false.
	 *
	 * @Kind Observe
	 * @Covers TMap.Remove
	 * @Inputs TMap<FString, int> with pairs; Remove present; Remove missing
	 * @Return true when present Remove shrinks Num and missing Remove is false
	 */
	UFUNCTION()
	bool RemovePresentAndMissAbsent_FString()
	{
		TMap<FString, int> Map;
		Map.Add("alpha", 100);
		Map.Add("beta", 200);
		Map.Add("gamma", 300);
		if (!Map.Remove("beta") || Map.Contains("beta") || Map.Num() != 2)
		{
			return false;
		}
		return !Map.Remove("missing")
			&& Map.Contains("alpha")
			&& Map.Contains("gamma");
	}

	/**
	 * In-only: read a map that already had a key removed_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Values Source map received as const TMap<FString, int>&in
	 * @Inputs Values.Num() == 2 with the remaining keys
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAfterRemove_FString(const TMap<FString, int>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: Add three pairs then Remove the middle key_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Result Destination received as TMap<FString, int>&out
	 * @Inputs Empty &out TMap<FString, int>
	 * @Return void; Result.Num() == 2
	 */
	UFUNCTION()
	void FillThenRemove_FString(TMap<FString, int>&out Result)
	{
		Result.Add("alpha", 100);
		Result.Add("beta", 200);
		Result.Add("gamma", 300);
		Result.Remove("beta");
	}

	/**
	 * Inout: Remove one present key from an existing three-pair map_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Values Map received as TMap<FString, int>&inout, starts with three keys
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 2
	 */
	UFUNCTION()
	void RemoveInPlace_FString(TMap<FString, int>&inout Values)
	{
		Values.Remove("beta");
	}


	/**
	 * Observe Remove_FName: existing key is dropped; missing key returns false.
	 *
	 * @Kind Observe
	 * @Covers TMap.Remove
	 * @Inputs TMap<FName, int> with pairs; Remove present; Remove missing
	 * @Return true when present Remove shrinks Num and missing Remove is false
	 */
	UFUNCTION()
	bool RemovePresentAndMissAbsent_FName()
	{
		TMap<FName, int> Map;
		Map.Add(n"Red", 1);
		Map.Add(n"Green", 2);
		Map.Add(n"Blue", 3);
		if (!Map.Remove(n"Green") || Map.Contains(n"Green") || Map.Num() != 2)
		{
			return false;
		}
		return !Map.Remove(n"Missing")
			&& Map.Contains(n"Red")
			&& Map.Contains(n"Blue");
	}

	/**
	 * In-only: read a map that already had a key removed_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Values Source map received as const TMap<FName, int>&in
	 * @Inputs Values.Num() == 2 with the remaining keys
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAfterRemove_FName(const TMap<FName, int>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: Add three pairs then Remove the middle key_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Result Destination received as TMap<FName, int>&out
	 * @Inputs Empty &out TMap<FName, int>
	 * @Return void; Result.Num() == 2
	 */
	UFUNCTION()
	void FillThenRemove_FName(TMap<FName, int>&out Result)
	{
		Result.Add(n"Red", 1);
		Result.Add(n"Green", 2);
		Result.Add(n"Blue", 3);
		Result.Remove(n"Green");
	}

	/**
	 * Inout: Remove one present key from an existing three-pair map_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Values Map received as TMap<FName, int>&inout, starts with three keys
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 2
	 */
	UFUNCTION()
	void RemoveInPlace_FName(TMap<FName, int>&inout Values)
	{
		Values.Remove(n"Green");
	}


	/**
	 * Observe Remove_bool: existing key is dropped; missing key returns false.
	 *
	 * @Kind Observe
	 * @Covers TMap.Remove
	 * @Inputs TMap<int, bool> with pairs; Remove present; Remove missing
	 * @Return true when present Remove shrinks Num and missing Remove is false
	 */
	UFUNCTION()
	bool RemovePresentAndMissAbsent_bool()
	{
		TMap<int, bool> Map;
		Map.Add(1, true);
		Map.Add(2, false);
		Map.Add(3, true);
		if (!Map.Remove(2) || Map.Contains(2) || Map.Num() != 2)
		{
			return false;
		}
		return !Map.Remove(99)
			&& Map.Contains(1)
			&& Map.Contains(3);
	}

	/**
	 * In-only: read a map that already had a key removed_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Values Source map received as const TMap<int, bool>&in
	 * @Inputs Values.Num() == 2 with the remaining keys
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAfterRemove_bool(const TMap<int, bool>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: Add three pairs then Remove the middle key_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Result Destination received as TMap<int, bool>&out
	 * @Inputs Empty &out TMap<int, bool>
	 * @Return void; Result.Num() == 2
	 */
	UFUNCTION()
	void FillThenRemove_bool(TMap<int, bool>&out Result)
	{
		Result.Add(1, true);
		Result.Add(2, false);
		Result.Add(3, true);
		Result.Remove(2);
	}

	/**
	 * Inout: Remove one present key from an existing three-pair map_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Values Map received as TMap<int, bool>&inout, starts with three keys
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 2
	 */
	UFUNCTION()
	void RemoveInPlace_bool(TMap<int, bool>&inout Values)
	{
		Values.Remove(2);
	}


	/**
	 * Observe Remove_FVector: existing key is dropped; missing key returns false.
	 *
	 * @Kind Observe
	 * @Covers TMap.Remove
	 * @Inputs TMap<int, FVector> with pairs; Remove present; Remove missing
	 * @Return true when present Remove shrinks Num and missing Remove is false
	 */
	UFUNCTION()
	bool RemovePresentAndMissAbsent_FVector()
	{
		TMap<int, FVector> Map;
		Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Map.Add(3, FVector(0.0f, 0.0f, 1.0f));
		if (!Map.Remove(2) || Map.Contains(2) || Map.Num() != 2)
		{
			return false;
		}
		return !Map.Remove(99)
			&& Map.Contains(1)
			&& Map.Contains(3);
	}

	/**
	 * In-only: read a map that already had a key removed_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Values Source map received as const TMap<int, FVector>&in
	 * @Inputs Values.Num() == 2 with the remaining keys
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAfterRemove_FVector(const TMap<int, FVector>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: Add three pairs then Remove the middle key_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Result Destination received as TMap<int, FVector>&out
	 * @Inputs Empty &out TMap<int, FVector>
	 * @Return void; Result.Num() == 2
	 */
	UFUNCTION()
	void FillThenRemove_FVector(TMap<int, FVector>&out Result)
	{
		Result.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Result.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Result.Add(3, FVector(0.0f, 0.0f, 1.0f));
		Result.Remove(2);
	}

	/**
	 * Inout: Remove one present key from an existing three-pair map_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Values Map received as TMap<int, FVector>&inout, starts with three keys
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 2
	 */
	UFUNCTION()
	void RemoveInPlace_FVector(TMap<int, FVector>&inout Values)
	{
		Values.Remove(2);
	}


	/**
	 * Observe Remove_UObject: existing key is dropped; missing key returns false.
	 *
	 * @Kind Observe
	 * @Covers TMap.Remove
	 * @Inputs TMap<int, UObject> with pairs; Remove present; Remove missing
	 * @Return true when present Remove shrinks Num and missing Remove is false
	 */
	UFUNCTION()
	bool RemovePresentAndMissAbsent_UObject()
	{
		TMap<int, UObject> Map;
		UObject First = NewObject(GetTransientPackage(), UTMapRemoveObject::StaticClass(), n"TMapRemove_First", true);
		Map.Add(10, First);
		Map.Add(20, First);
		if (!Map.Remove(10) || Map.Contains(10) || Map.Num() != 1)
		{
			return false;
		}
		return !Map.Remove(99) && Map.Contains(20);
	}

	/**
	 * In-only: read a map that already had a key removed_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Values Source map received as const TMap<int, UObject>&in
	 * @Inputs Values.Num() == 2 with the remaining keys
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadAfterRemove_UObject(const TMap<int, UObject>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: Add three pairs then Remove the middle key_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Result Destination received as TMap<int, UObject>&out
	 * @Inputs Empty &out TMap<int, UObject>
	 * @Return void; Result.Num() == 2
	 */
	UFUNCTION()
	void FillThenRemove_UObject(TMap<int, UObject>&out Result)
	{
		Result.Add(10, NewObject(GetTransientPackage(), UTMapRemoveObject::StaticClass(), n"UTMapRemoveObject_Fill_0", true));
		Result.Add(20, NewObject(GetTransientPackage(), UTMapRemoveObject::StaticClass(), n"UTMapRemoveObject_Fill_1", true));
		Result.Add(30, NewObject(GetTransientPackage(), UTMapRemoveObject::StaticClass(), n"UTMapRemoveObject_Fill_2", true));
		Result.Remove(20);
	}

	/**
	 * Inout: Remove one present key from an existing three-pair map_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Values Map received as TMap<int, UObject>&inout, starts with three keys
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 2
	 */
	UFUNCTION()
	void RemoveInPlace_UObject(TMap<int, UObject>&inout Values)
	{
		Values.Remove(20);
	}


	/**
	 * Observe RemoveAndCopyValue: copies the old value then drops the key.
	 *
	 * @Kind Observe
	 * @Covers TMap.RemoveAndCopyValue
	 * @Inputs TMap<int, int> [10->100, 20->200]; RemoveAndCopyValue(10); miss 99
	 * @Return true when copied value is 100, key 10 is gone, and miss is false
	 */
	UFUNCTION()
	bool RemoveAndCopyValueCopiesThenDrops()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		Map.Add(20, 200);
		int Copied = 0;
		if (!Map.RemoveAndCopyValue(10, Copied) || Copied != 100 || Map.Contains(10))
		{
			return false;
		}
		int Miss = 7;
		return !Map.RemoveAndCopyValue(99, Miss) && Miss == 7 && Map.Contains(20);
	}

}
/** @end */
