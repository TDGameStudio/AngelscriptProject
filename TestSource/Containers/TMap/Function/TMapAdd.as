/**
 * TMap.Add inserts or replaces by key. Num grows only for a new key;
 * overwrite keeps Num and updates the value. Presence is observed through
 * Contains and [], then through UFUNCTION in, out, and inout directions.
 * int/int is canonical; other key/value shapes repeat the same four entries
 * with a type suffix. float keys are omitted (hash/equality footgun).
 *
 * @Theme Containers.TMap
 * @Subject TMap.Add
 * @Harness Function
 * @Tag Containers.TMap.TMapAdd
 * @Namespace TMapTest
 */

UCLASS()
class UTMapAddObject : UObject
{
}

namespace TMapTest
{
	/**
	 * Observe Add: first key lands, second key grows Num, overwrite replaces value.
	 *
	 * @Kind Observe
	 * @Covers TMap.Add
	 * @Inputs Default-constructed TMap<int, int>; Add two keys; Add first key again
	 * @Return true when Num grows for a new key and overwrite keeps Num
	 */
	UFUNCTION()
	bool AddInsertsAndOverwriteKeepsNum()
	{
		TMap<int, int> Map;

		Map.Add(10, 100);
		if (Map.Num() != 1 || !Map.Contains(10) || Map[10] != 100)
		{
			return false;
		}

		Map.Add(20, 200);
		if (Map.Num() != 2 || Map[10] != 100 || Map[20] != 200)
		{
			return false;
		}

		Map.Add(10, 999);
		return Map.Num() == 2
			&& Map[10] == 999
			&& Map[20] == 200;
	}

	/**
	 * In-only: read Add pairs from a const&in TMap<int, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs Values holds the three canonical pairs
	 * @Return true when Num is 3 and each key maps to its value
	 */
	UFUNCTION()
	bool ReadAddedPairs(const TMap<int, int>&in Values)
	{
		return Values.Num() == 3
			&& Values.Contains(10) && Values.Contains(20) && Values.Contains(30)
			&& Values[10] == 100
			&& Values[20] == 200
			&& Values[30] == 300;
	}

	/**
	 * Out-only: fill an empty &out TMap<int, int> with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapByAdd(TMap<int, int>&out Result)
	{
		Result.Add(10, 100);
		Result.Add(20, 200);
		Result.Add(30, 300);
	}

	/**
	 * Inout: Add the third pair onto an existing two-pair TMap<int, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Map received as TMap<int, int>&inout, starts with two pairs
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3 and the third key is present
	 */
	UFUNCTION()
	void AppendWithAdd(TMap<int, int>&inout Values)
	{
		Values.Add(30, 300);
	}


	/**
	 * Observe Add_FString: first key lands, second key grows Num, overwrite replaces value.
	 *
	 * @Kind Observe
	 * @Covers TMap.Add
	 * @Inputs Default-constructed TMap<FString, int>; Add two keys; Add first key again
	 * @Return true when Num grows for a new key and overwrite keeps Num
	 */
	UFUNCTION()
	bool AddInsertsAndOverwriteKeepsNum_FString()
	{
		TMap<FString, int> Map;

		Map.Add("alpha", 100);
		if (Map.Num() != 1 || !Map.Contains("alpha") || Map["alpha"] != 100)
		{
			return false;
		}

		Map.Add("beta", 200);
		if (Map.Num() != 2 || Map["alpha"] != 100 || Map["beta"] != 200)
		{
			return false;
		}

		Map.Add("alpha", 999);
		return Map.Num() == 2
			&& Map["alpha"] == 999
			&& Map["beta"] == 200;
	}

	/**
	 * In-only: read Add pairs from a const&in TMap<FString, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Source map received as const TMap<FString, int>&in
	 * @Inputs Values holds the three canonical pairs
	 * @Return true when Num is 3 and each key maps to its value
	 */
	UFUNCTION()
	bool ReadAddedPairs_FString(const TMap<FString, int>&in Values)
	{
		return Values.Num() == 3
			&& Values.Contains("alpha") && Values.Contains("beta") && Values.Contains("gamma")
			&& Values["alpha"] == 100
			&& Values["beta"] == 200
			&& Values["gamma"] == 300;
	}

	/**
	 * Out-only: fill an empty &out TMap<FString, int> with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Result Destination received as TMap<FString, int>&out
	 * @Inputs Empty &out TMap<FString, int>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapByAdd_FString(TMap<FString, int>&out Result)
	{
		Result.Add("alpha", 100);
		Result.Add("beta", 200);
		Result.Add("gamma", 300);
	}

	/**
	 * Inout: Add the third pair onto an existing two-pair TMap<FString, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Map received as TMap<FString, int>&inout, starts with two pairs
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3 and the third key is present
	 */
	UFUNCTION()
	void AppendWithAdd_FString(TMap<FString, int>&inout Values)
	{
		Values.Add("gamma", 300);
	}


	/**
	 * Observe Add_FName: first key lands, second key grows Num, overwrite replaces value.
	 *
	 * @Kind Observe
	 * @Covers TMap.Add
	 * @Inputs Default-constructed TMap<FName, int>; Add two keys; Add first key again
	 * @Return true when Num grows for a new key and overwrite keeps Num
	 */
	UFUNCTION()
	bool AddInsertsAndOverwriteKeepsNum_FName()
	{
		TMap<FName, int> Map;

		Map.Add(n"Red", 1);
		if (Map.Num() != 1 || !Map.Contains(n"Red") || Map[n"Red"] != 1)
		{
			return false;
		}

		Map.Add(n"Green", 2);
		if (Map.Num() != 2 || Map[n"Red"] != 1 || Map[n"Green"] != 2)
		{
			return false;
		}

		Map.Add(n"Red", 9);
		return Map.Num() == 2
			&& Map[n"Red"] == 9
			&& Map[n"Green"] == 2;
	}

	/**
	 * In-only: read Add pairs from a const&in TMap<FName, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Source map received as const TMap<FName, int>&in
	 * @Inputs Values holds the three canonical pairs
	 * @Return true when Num is 3 and each key maps to its value
	 */
	UFUNCTION()
	bool ReadAddedPairs_FName(const TMap<FName, int>&in Values)
	{
		return Values.Num() == 3
			&& Values.Contains(n"Red") && Values.Contains(n"Green") && Values.Contains(n"Blue")
			&& Values[n"Red"] == 1
			&& Values[n"Green"] == 2
			&& Values[n"Blue"] == 3;
	}

	/**
	 * Out-only: fill an empty &out TMap<FName, int> with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Result Destination received as TMap<FName, int>&out
	 * @Inputs Empty &out TMap<FName, int>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapByAdd_FName(TMap<FName, int>&out Result)
	{
		Result.Add(n"Red", 1);
		Result.Add(n"Green", 2);
		Result.Add(n"Blue", 3);
	}

	/**
	 * Inout: Add the third pair onto an existing two-pair TMap<FName, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Map received as TMap<FName, int>&inout, starts with two pairs
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3 and the third key is present
	 */
	UFUNCTION()
	void AppendWithAdd_FName(TMap<FName, int>&inout Values)
	{
		Values.Add(n"Blue", 3);
	}


	/**
	 * Observe Add_bool: first key lands, second key grows Num, overwrite replaces value.
	 *
	 * @Kind Observe
	 * @Covers TMap.Add
	 * @Inputs Default-constructed TMap<int, bool>; Add two keys; Add first key again
	 * @Return true when Num grows for a new key and overwrite keeps Num
	 */
	UFUNCTION()
	bool AddInsertsAndOverwriteKeepsNum_bool()
	{
		TMap<int, bool> Map;

		Map.Add(1, true);
		if (Map.Num() != 1 || !Map.Contains(1) || Map[1] != true)
		{
			return false;
		}

		Map.Add(2, false);
		if (Map.Num() != 2 || Map[1] != true || Map[2] != false)
		{
			return false;
		}

		Map.Add(1, false);
		return Map.Num() == 2
			&& Map[1] == false
			&& Map[2] == false;
	}

	/**
	 * In-only: read Add pairs from a const&in TMap<int, bool> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Source map received as const TMap<int, bool>&in
	 * @Inputs Values holds the three canonical pairs
	 * @Return true when Num is 3 and each key maps to its value
	 */
	UFUNCTION()
	bool ReadAddedPairs_bool(const TMap<int, bool>&in Values)
	{
		return Values.Num() == 3
			&& Values.Contains(1) && Values.Contains(2) && Values.Contains(3)
			&& Values[1] == true
			&& Values[2] == false
			&& Values[3] == true;
	}

	/**
	 * Out-only: fill an empty &out TMap<int, bool> with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Result Destination received as TMap<int, bool>&out
	 * @Inputs Empty &out TMap<int, bool>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapByAdd_bool(TMap<int, bool>&out Result)
	{
		Result.Add(1, true);
		Result.Add(2, false);
		Result.Add(3, true);
	}

	/**
	 * Inout: Add the third pair onto an existing two-pair TMap<int, bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Map received as TMap<int, bool>&inout, starts with two pairs
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3 and the third key is present
	 */
	UFUNCTION()
	void AppendWithAdd_bool(TMap<int, bool>&inout Values)
	{
		Values.Add(3, true);
	}


	/**
	 * Observe Add_FVector: first key lands, second key grows Num, overwrite replaces value.
	 *
	 * @Kind Observe
	 * @Covers TMap.Add
	 * @Inputs Default-constructed TMap<int, FVector>; Add two keys; Add first key again
	 * @Return true when Num grows for a new key and overwrite keeps Num
	 */
	UFUNCTION()
	bool AddInsertsAndOverwriteKeepsNum_FVector()
	{
		TMap<int, FVector> Map;

		Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
		if (Map.Num() != 1 || !Map.Contains(1) || !Map[1].Equals(FVector(1.0f, 0.0f, 0.0f)))
		{
			return false;
		}

		Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
		if (Map.Num() != 2 || !Map[1].Equals(FVector(1.0f, 0.0f, 0.0f)) || !Map[2].Equals(FVector(0.0f, 1.0f, 0.0f)))
		{
			return false;
		}

		Map.Add(1, FVector(9.0f, 9.0f, 9.0f));
		return Map.Num() == 2
			&& Map[1].Equals(FVector(9.0f, 9.0f, 9.0f))
			&& Map[2].Equals(FVector(0.0f, 1.0f, 0.0f));
	}

	/**
	 * In-only: read Add pairs from a const&in TMap<int, FVector> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Source map received as const TMap<int, FVector>&in
	 * @Inputs Values holds the three canonical pairs
	 * @Return true when Num is 3 and each key maps to its value
	 */
	UFUNCTION()
	bool ReadAddedPairs_FVector(const TMap<int, FVector>&in Values)
	{
		return Values.Num() == 3
			&& Values.Contains(1) && Values.Contains(2) && Values.Contains(3)
			&& Values[1].Equals(FVector(1.0f, 0.0f, 0.0f))
			&& Values[2].Equals(FVector(0.0f, 1.0f, 0.0f))
			&& Values[3].Equals(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Out-only: fill an empty &out TMap<int, FVector> with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Result Destination received as TMap<int, FVector>&out
	 * @Inputs Empty &out TMap<int, FVector>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapByAdd_FVector(TMap<int, FVector>&out Result)
	{
		Result.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Result.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Result.Add(3, FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Inout: Add the third pair onto an existing two-pair TMap<int, FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Map received as TMap<int, FVector>&inout, starts with two pairs
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3 and the third key is present
	 */
	UFUNCTION()
	void AppendWithAdd_FVector(TMap<int, FVector>&inout Values)
	{
		Values.Add(3, FVector(0.0f, 0.0f, 1.0f));
	}


	/**
	 * Observe Add_UObject: first key lands, second key grows Num, overwrite replaces value.
	 *
	 * @Kind Observe
	 * @Covers TMap.Add
	 * @Inputs Default-constructed TMap<int, UObject>; Add two keys; Add first key again
	 * @Return true when Num grows for a new key and overwrite keeps Num
	 */
	UFUNCTION()
	bool AddInsertsAndOverwriteKeepsNum_UObject()
	{
		TMap<int, UObject> Map;
		UObject First = NewObject(GetTransientPackage(), UTMapAddObject::StaticClass(), n"TMapAdd_First", true);
		UObject Second = NewObject(GetTransientPackage(), UTMapAddObject::StaticClass(), n"TMapAdd_Second", true);
		UObject Third = NewObject(GetTransientPackage(), UTMapAddObject::StaticClass(), n"TMapAdd_Third", true);
		if (First == nullptr || Second == nullptr || Third == nullptr
			|| First == Second || Second == Third || First == Third)
		{
			return false;
		}

		Map.Add(10, First);
		if (Map.Num() != 1 || !Map.Contains(10) || Map[10] != First)
		{
			return false;
		}

		Map.Add(20, Second);
		if (Map.Num() != 2 || Map[10] != First || Map[20] != Second)
		{
			return false;
		}

		Map.Add(10, Third);
		return Map.Num() == 2 && Map[10] == Third && Map[20] == Second;
	}

	/**
	 * In-only: read Add pairs from a const&in TMap<int, UObject> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Source map received as const TMap<int, UObject>&in
	 * @Inputs Values holds the three canonical pairs
	 * @Return true when Num is 3 and each key maps to its value
	 */
	UFUNCTION()
	bool ReadAddedPairs_UObject(const TMap<int, UObject>&in Values)
	{
		return Values.Num() == 2
			&& Values.Contains(10) && Values.Contains(20)
			&& Values[10] != nullptr && Values[20] != nullptr
			&& Values[10] != Values[20];
	}

	/**
	 * Out-only: fill an empty &out TMap<int, UObject> with Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Result Destination received as TMap<int, UObject>&out
	 * @Inputs Empty &out TMap<int, UObject>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapByAdd_UObject(TMap<int, UObject>&out Result)
	{
		Result.Add(10, NewObject(GetTransientPackage(), UTMapAddObject::StaticClass(), n"TMapAdd_Fill_0", true));
		Result.Add(20, NewObject(GetTransientPackage(), UTMapAddObject::StaticClass(), n"TMapAdd_Fill_1", true));
		Result.Add(30, NewObject(GetTransientPackage(), UTMapAddObject::StaticClass(), n"TMapAdd_Fill_2", true));
	}

	/**
	 * Inout: Add the third pair onto an existing two-pair TMap<int, UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Map received as TMap<int, UObject>&inout, starts with two pairs
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3 and the third key is present
	 */
	UFUNCTION()
	void AppendWithAdd_UObject(TMap<int, UObject>&inout Values)
	{
		Values.Add(30, NewObject(GetTransientPackage(), UTMapAddObject::StaticClass(), n"TMapAdd_Append", true));
	}


}
