/**
 * opIndex reads and writes an existing key. A missing key Throws;
 * that path lives in Exception/. Legal access is observed locally, then
 * through UFUNCTION in, out, and inout. int/int is canonical; other shapes
 * repeat the same four entries with a type suffix.
 *
 * @Theme Containers.TMap
 * @Subject TMap.opIndex
 * @Harness Function
 * @Tag Containers.TMap.TMapIndexAccess
 * @Namespace TMapTest
 */

UCLASS()
class UTMapIndexObject : UObject
{
}

namespace TMapTest
{
	/**
	 * Observe opIndex: read the stored value, then write a replacement.
	 *
	 * @Kind Observe
	 * @Covers TMap.opIndex
	 * @Inputs TMap<int, int> with one pair; read []; write []
	 * @Return true when read matches Add and write replaces the value
	 */
	UFUNCTION()
	IndexReadsAndWritesPresentKey()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		if (Map[10] != 100)
		{
			return false;
		}

		Map[10] = 999;
		return Map[10] == 999 && Map.Num() == 1;
	}

	/**
	 * In-only: read [] from a const&in TMap<int, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs three present keys
	 * @Return true when [] matches each stored value
	 */
	UFUNCTION()
	ReadIndexAccess(const TMap<int, int>&in Values)
	{
		return Values.Num() == 3
			&& Values[10] == 100
			&& Values[20] == 200
			&& Values[30] == 300;
	}

	/**
	 * Out-only: fill an empty &out TMap<int, int> for [] reads.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	FillMapForIndexAccess(TMap<int, int>&out Result)
	{
		Result.Add(10, 100);
		Result.Add(20, 200);
		Result.Add(30, 300);
	}

	/**
	 * Inout: Add the third key so [] can read it.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Map received as TMap<int, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	AppendForIndexAccess(TMap<int, int>&inout Values)
	{
		Values.Add(30, 300);
	}


	/**
	 * Observe opIndex_FString: read the stored value, then write a replacement.
	 *
	 * @Kind Observe
	 * @Covers TMap.opIndex
	 * @Inputs TMap<FString, int> with one pair; read []; write []
	 * @Return true when read matches Add and write replaces the value
	 */
	UFUNCTION()
	IndexReadsAndWritesPresentKey_FString()
	{
		TMap<FString, int> Map;
		Map.Add("alpha", 100);
		if (Map["alpha"] != 100)
		{
			return false;
		}

		Map["alpha"] = 999;
		return Map["alpha"] == 999 && Map.Num() == 1;
	}

	/**
	 * In-only: read [] from a const&in TMap<FString, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Source map received as const TMap<FString, int>&in
	 * @Inputs three present keys
	 * @Return true when [] matches each stored value
	 */
	UFUNCTION()
	ReadIndexAccess_FString(const TMap<FString, int>&in Values)
	{
		return Values.Num() == 3
			&& Values["alpha"] == 100
			&& Values["beta"] == 200
			&& Values["gamma"] == 300;
	}

	/**
	 * Out-only: fill an empty &out TMap<FString, int> for [] reads.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Result Destination received as TMap<FString, int>&out
	 * @Inputs Empty &out TMap<FString, int>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	FillMapForIndexAccess_FString(TMap<FString, int>&out Result)
	{
		Result.Add("alpha", 100);
		Result.Add("beta", 200);
		Result.Add("gamma", 300);
	}

	/**
	 * Inout: Add the third key so [] can read it_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Map received as TMap<FString, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	AppendForIndexAccess_FString(TMap<FString, int>&inout Values)
	{
		Values.Add("gamma", 300);
	}


	/**
	 * Observe opIndex_FName: read the stored value, then write a replacement.
	 *
	 * @Kind Observe
	 * @Covers TMap.opIndex
	 * @Inputs TMap<FName, int> with one pair; read []; write []
	 * @Return true when read matches Add and write replaces the value
	 */
	UFUNCTION()
	IndexReadsAndWritesPresentKey_FName()
	{
		TMap<FName, int> Map;
		Map.Add(n"Red", 1);
		if (Map[n"Red"] != 1)
		{
			return false;
		}

		Map[n"Red"] = 9;
		return Map[n"Red"] == 9 && Map.Num() == 1;
	}

	/**
	 * In-only: read [] from a const&in TMap<FName, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Source map received as const TMap<FName, int>&in
	 * @Inputs three present keys
	 * @Return true when [] matches each stored value
	 */
	UFUNCTION()
	ReadIndexAccess_FName(const TMap<FName, int>&in Values)
	{
		return Values.Num() == 3
			&& Values[n"Red"] == 1
			&& Values[n"Green"] == 2
			&& Values[n"Blue"] == 3;
	}

	/**
	 * Out-only: fill an empty &out TMap<FName, int> for [] reads.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Result Destination received as TMap<FName, int>&out
	 * @Inputs Empty &out TMap<FName, int>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	FillMapForIndexAccess_FName(TMap<FName, int>&out Result)
	{
		Result.Add(n"Red", 1);
		Result.Add(n"Green", 2);
		Result.Add(n"Blue", 3);
	}

	/**
	 * Inout: Add the third key so [] can read it_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Map received as TMap<FName, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	AppendForIndexAccess_FName(TMap<FName, int>&inout Values)
	{
		Values.Add(n"Blue", 3);
	}


	/**
	 * Observe opIndex_bool: read the stored value, then write a replacement.
	 *
	 * @Kind Observe
	 * @Covers TMap.opIndex
	 * @Inputs TMap<int, bool> with one pair; read []; write []
	 * @Return true when read matches Add and write replaces the value
	 */
	UFUNCTION()
	IndexReadsAndWritesPresentKey_bool()
	{
		TMap<int, bool> Map;
		Map.Add(1, true);
		if (Map[1] != true)
		{
			return false;
		}

		Map[1] = false;
		return Map[1] == false && Map.Num() == 1;
	}

	/**
	 * In-only: read [] from a const&in TMap<int, bool> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Source map received as const TMap<int, bool>&in
	 * @Inputs three present keys
	 * @Return true when [] matches each stored value
	 */
	UFUNCTION()
	ReadIndexAccess_bool(const TMap<int, bool>&in Values)
	{
		return Values.Num() == 3
			&& Values[1] == true
			&& Values[2] == false
			&& Values[3] == true;
	}

	/**
	 * Out-only: fill an empty &out TMap<int, bool> for [] reads.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Result Destination received as TMap<int, bool>&out
	 * @Inputs Empty &out TMap<int, bool>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	FillMapForIndexAccess_bool(TMap<int, bool>&out Result)
	{
		Result.Add(1, true);
		Result.Add(2, false);
		Result.Add(3, true);
	}

	/**
	 * Inout: Add the third key so [] can read it_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Map received as TMap<int, bool>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	AppendForIndexAccess_bool(TMap<int, bool>&inout Values)
	{
		Values.Add(3, true);
	}


	/**
	 * Observe opIndex_FVector: read the stored value, then write a replacement.
	 *
	 * @Kind Observe
	 * @Covers TMap.opIndex
	 * @Inputs TMap<int, FVector> with one pair; read []; write []
	 * @Return true when read matches Add and write replaces the value
	 */
	UFUNCTION()
	IndexReadsAndWritesPresentKey_FVector()
	{
		TMap<int, FVector> Map;
		Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
		if (!Map[1].Equals(FVector(1.0f, 0.0f, 0.0f)))
		{
			return false;
		}

		Map[1] = FVector(9.0f, 9.0f, 9.0f);
		return Map[1].Equals(FVector(9.0f, 9.0f, 9.0f)) && Map.Num() == 1;
	}

	/**
	 * In-only: read [] from a const&in TMap<int, FVector> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Source map received as const TMap<int, FVector>&in
	 * @Inputs three present keys
	 * @Return true when [] matches each stored value
	 */
	UFUNCTION()
	ReadIndexAccess_FVector(const TMap<int, FVector>&in Values)
	{
		return Values.Num() == 3
			&& Values[1].Equals(FVector(1.0f, 0.0f, 0.0f))
			&& Values[2].Equals(FVector(0.0f, 1.0f, 0.0f))
			&& Values[3].Equals(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Out-only: fill an empty &out TMap<int, FVector> for [] reads.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Result Destination received as TMap<int, FVector>&out
	 * @Inputs Empty &out TMap<int, FVector>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	FillMapForIndexAccess_FVector(TMap<int, FVector>&out Result)
	{
		Result.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Result.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Result.Add(3, FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Inout: Add the third key so [] can read it_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Map received as TMap<int, FVector>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	AppendForIndexAccess_FVector(TMap<int, FVector>&inout Values)
	{
		Values.Add(3, FVector(0.0f, 0.0f, 1.0f));
	}


	/**
	 * Observe opIndex_UObject: read the stored value, then write a replacement.
	 *
	 * @Kind Observe
	 * @Covers TMap.opIndex
	 * @Inputs TMap<int, UObject> with one pair; read []; write []
	 * @Return true when read matches Add and write replaces the value
	 */
	UFUNCTION()
	IndexReadsAndWritesPresentKey_UObject()
	{
		TMap<int, UObject> Map;
		UObject First = NewObject(GetTransientPackage(), UTMapIndexObject::StaticClass(), n"TMapIndex_First", true);
		UObject Second = NewObject(GetTransientPackage(), UTMapIndexObject::StaticClass(), n"TMapIndex_Second", true);
		if (First == nullptr || Second == nullptr || First == Second)
		{
			return false;
		}
		Map.Add(10, First);
		if (Map[10] != First)
		{
			return false;
		}
		Map[10] = Second;
		return Map[10] == Second && Map.Num() == 1;
	}

	/**
	 * In-only: read [] from a const&in TMap<int, UObject> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Source map received as const TMap<int, UObject>&in
	 * @Inputs three present keys
	 * @Return true when [] matches each stored value
	 */
	UFUNCTION()
	ReadIndexAccess_UObject(const TMap<int, UObject>&in Values)
	{
		return Values.Num() == 3 && Values[10] != nullptr && Values[20] != nullptr && Values[30] != nullptr;
	}

	/**
	 * Out-only: fill an empty &out TMap<int, UObject> for [] reads.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Result Destination received as TMap<int, UObject>&out
	 * @Inputs Empty &out TMap<int, UObject>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	FillMapForIndexAccess_UObject(TMap<int, UObject>&out Result)
	{
		Result.Add(10, NewObject(GetTransientPackage(), UTMapIndexObject::StaticClass(), n"UTMapIndexObject_Fill_0", true));
		Result.Add(20, NewObject(GetTransientPackage(), UTMapIndexObject::StaticClass(), n"UTMapIndexObject_Fill_1", true));
		Result.Add(30, NewObject(GetTransientPackage(), UTMapIndexObject::StaticClass(), n"UTMapIndexObject_Fill_2", true));
	}

	/**
	 * Inout: Add the third key so [] can read it_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Map received as TMap<int, UObject>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	AppendForIndexAccess_UObject(TMap<int, UObject>&inout Values)
	{
		Values.Add(30, NewObject(GetTransientPackage(), UTMapIndexObject::StaticClass(), n"UTMapIndexObject_Append", true));
	}


}
