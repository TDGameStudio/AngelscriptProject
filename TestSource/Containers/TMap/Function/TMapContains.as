/**
 * Contains is true for present keys and false for absent ones.
 * Empty Contains is also a first step here; EmptyConstruction owns the empty
 * type matrix. Presence is observed locally, then through UFUNCTION in, out, and inout.
 * int/int is canonical; other key/value shapes repeat the same four entries with a type suffix.
 *
 * @Theme Containers.TMap
 * @Subject TMap.Contains
 * @Harness Function
 * @Tag Containers.TMap.TMapContains
 * @Namespace TMapTest
 */

UCLASS()
class UTMapContainsObject : UObject
{
}

namespace TMapTest
{
	/**
	 * Empty map contains nothing; after Add, present keys match and others do not.
	 *
	 * @Kind Observe
	 * @Covers TMap.Contains
	 * @Inputs Default-constructed TMap<int, int>; Contains miss; Add present keys
	 * @Return true when present keys match and absent keys do not
	 */
	UFUNCTION()
	ContainsPresentAndAbsent()
	{
		TMap<int, int> Map;
		if (Map.Contains(10))
		{
			return false;
		}

		Map.Add(10, 100);
		if (!Map.Contains(10) || Map.Contains(99))
		{
			return false;
		}

		Map.Add(20, 200);
		Map.Add(30, 300);
		return Map.Contains(10)
			&& Map.Contains(20)
			&& Map.Contains(30)
			&& !Map.Contains(99);
	}

	/**
	 * In-only: Contains on a const&in TMap<int, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs three present keys
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	ReadContains(const TMap<int, int>&in Values)
	{
		return Values.Contains(10)
			&& Values.Contains(20)
			&& Values.Contains(30)
			&& !Values.Contains(99);
	}

	/**
	 * Out-only: fill an empty &out TMap<int, int> with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result holds the three present keys
	 */
	UFUNCTION()
	FillMapForContains(TMap<int, int>&out Result)
	{
		Result.Add(10, 100);
		Result.Add(20, 200);
		Result.Add(30, 300);
	}

	/**
	 * Inout: Add the third key so Contains becomes true.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Values Map received as TMap<int, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	AppendForContains(TMap<int, int>&inout Values)
	{
		Values.Add(30, 300);
	}


	/**
	 * Empty map contains nothing; after Add, present keys match and others do not_FString.
	 *
	 * @Kind Observe
	 * @Covers TMap.Contains
	 * @Inputs Default-constructed TMap<FString, int>; Contains miss; Add present keys
	 * @Return true when present keys match and absent keys do not
	 */
	UFUNCTION()
	ContainsPresentAndAbsent_FString()
	{
		TMap<FString, int> Map;
		if (Map.Contains("alpha"))
		{
			return false;
		}

		Map.Add("alpha", 100);
		if (!Map.Contains("alpha") || Map.Contains("missing"))
		{
			return false;
		}

		Map.Add("beta", 200);
		Map.Add("gamma", 300);
		return Map.Contains("alpha")
			&& Map.Contains("beta")
			&& Map.Contains("gamma")
			&& !Map.Contains("missing");
	}

	/**
	 * In-only: Contains on a const&in TMap<FString, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Values Source map received as const TMap<FString, int>&in
	 * @Inputs three present keys
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	ReadContains_FString(const TMap<FString, int>&in Values)
	{
		return Values.Contains("alpha")
			&& Values.Contains("beta")
			&& Values.Contains("gamma")
			&& !Values.Contains("missing");
	}

	/**
	 * Out-only: fill an empty &out TMap<FString, int> with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Result Destination received as TMap<FString, int>&out
	 * @Inputs Empty &out TMap<FString, int>
	 * @Return void; Result holds the three present keys
	 */
	UFUNCTION()
	FillMapForContains_FString(TMap<FString, int>&out Result)
	{
		Result.Add("alpha", 100);
		Result.Add("beta", 200);
		Result.Add("gamma", 300);
	}

	/**
	 * Inout: Add the third key so Contains becomes true_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Values Map received as TMap<FString, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	AppendForContains_FString(TMap<FString, int>&inout Values)
	{
		Values.Add("gamma", 300);
	}


	/**
	 * Empty map contains nothing; after Add, present keys match and others do not_FName.
	 *
	 * @Kind Observe
	 * @Covers TMap.Contains
	 * @Inputs Default-constructed TMap<FName, int>; Contains miss; Add present keys
	 * @Return true when present keys match and absent keys do not
	 */
	UFUNCTION()
	ContainsPresentAndAbsent_FName()
	{
		TMap<FName, int> Map;
		if (Map.Contains(n"Red"))
		{
			return false;
		}

		Map.Add(n"Red", 1);
		if (!Map.Contains(n"Red") || Map.Contains(n"Missing"))
		{
			return false;
		}

		Map.Add(n"Green", 2);
		Map.Add(n"Blue", 3);
		return Map.Contains(n"Red")
			&& Map.Contains(n"Green")
			&& Map.Contains(n"Blue")
			&& !Map.Contains(n"Missing");
	}

	/**
	 * In-only: Contains on a const&in TMap<FName, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Values Source map received as const TMap<FName, int>&in
	 * @Inputs three present keys
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	ReadContains_FName(const TMap<FName, int>&in Values)
	{
		return Values.Contains(n"Red")
			&& Values.Contains(n"Green")
			&& Values.Contains(n"Blue")
			&& !Values.Contains(n"Missing");
	}

	/**
	 * Out-only: fill an empty &out TMap<FName, int> with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Result Destination received as TMap<FName, int>&out
	 * @Inputs Empty &out TMap<FName, int>
	 * @Return void; Result holds the three present keys
	 */
	UFUNCTION()
	FillMapForContains_FName(TMap<FName, int>&out Result)
	{
		Result.Add(n"Red", 1);
		Result.Add(n"Green", 2);
		Result.Add(n"Blue", 3);
	}

	/**
	 * Inout: Add the third key so Contains becomes true_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Values Map received as TMap<FName, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	AppendForContains_FName(TMap<FName, int>&inout Values)
	{
		Values.Add(n"Blue", 3);
	}


	/**
	 * Empty map contains nothing; after Add, present keys match and others do not_bool.
	 *
	 * @Kind Observe
	 * @Covers TMap.Contains
	 * @Inputs Default-constructed TMap<int, bool>; Contains miss; Add present keys
	 * @Return true when present keys match and absent keys do not
	 */
	UFUNCTION()
	ContainsPresentAndAbsent_bool()
	{
		TMap<int, bool> Map;
		if (Map.Contains(1))
		{
			return false;
		}

		Map.Add(1, true);
		if (!Map.Contains(1) || Map.Contains(99))
		{
			return false;
		}

		Map.Add(2, false);
		Map.Add(3, true);
		return Map.Contains(1)
			&& Map.Contains(2)
			&& Map.Contains(3)
			&& !Map.Contains(99);
	}

	/**
	 * In-only: Contains on a const&in TMap<int, bool> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Values Source map received as const TMap<int, bool>&in
	 * @Inputs three present keys
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	ReadContains_bool(const TMap<int, bool>&in Values)
	{
		return Values.Contains(1)
			&& Values.Contains(2)
			&& Values.Contains(3)
			&& !Values.Contains(99);
	}

	/**
	 * Out-only: fill an empty &out TMap<int, bool> with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Result Destination received as TMap<int, bool>&out
	 * @Inputs Empty &out TMap<int, bool>
	 * @Return void; Result holds the three present keys
	 */
	UFUNCTION()
	FillMapForContains_bool(TMap<int, bool>&out Result)
	{
		Result.Add(1, true);
		Result.Add(2, false);
		Result.Add(3, true);
	}

	/**
	 * Inout: Add the third key so Contains becomes true_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Values Map received as TMap<int, bool>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	AppendForContains_bool(TMap<int, bool>&inout Values)
	{
		Values.Add(3, true);
	}


	/**
	 * Empty map contains nothing; after Add, present keys match and others do not_FVector.
	 *
	 * @Kind Observe
	 * @Covers TMap.Contains
	 * @Inputs Default-constructed TMap<int, FVector>; Contains miss; Add present keys
	 * @Return true when present keys match and absent keys do not
	 */
	UFUNCTION()
	ContainsPresentAndAbsent_FVector()
	{
		TMap<int, FVector> Map;
		if (Map.Contains(1))
		{
			return false;
		}

		Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
		if (!Map.Contains(1) || Map.Contains(99))
		{
			return false;
		}

		Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Map.Add(3, FVector(0.0f, 0.0f, 1.0f));
		return Map.Contains(1)
			&& Map.Contains(2)
			&& Map.Contains(3)
			&& !Map.Contains(99);
	}

	/**
	 * In-only: Contains on a const&in TMap<int, FVector> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Values Source map received as const TMap<int, FVector>&in
	 * @Inputs three present keys
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	ReadContains_FVector(const TMap<int, FVector>&in Values)
	{
		return Values.Contains(1)
			&& Values.Contains(2)
			&& Values.Contains(3)
			&& !Values.Contains(99);
	}

	/**
	 * Out-only: fill an empty &out TMap<int, FVector> with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Result Destination received as TMap<int, FVector>&out
	 * @Inputs Empty &out TMap<int, FVector>
	 * @Return void; Result holds the three present keys
	 */
	UFUNCTION()
	FillMapForContains_FVector(TMap<int, FVector>&out Result)
	{
		Result.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Result.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Result.Add(3, FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Inout: Add the third key so Contains becomes true_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Values Map received as TMap<int, FVector>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	AppendForContains_FVector(TMap<int, FVector>&inout Values)
	{
		Values.Add(3, FVector(0.0f, 0.0f, 1.0f));
	}


	/**
	 * Empty map contains nothing; after Add, present keys match and others do not_UObject.
	 *
	 * @Kind Observe
	 * @Covers TMap.Contains
	 * @Inputs Default-constructed TMap<int, UObject>; Contains miss; Add present keys
	 * @Return true when present keys match and absent keys do not
	 */
	UFUNCTION()
	ContainsPresentAndAbsent_UObject()
	{
		TMap<int, UObject> Map;
		UObject First = NewObject(GetTransientPackage(), UTMapContainsObject::StaticClass(), n"TMapContains_First", true);
		if (Map.Contains(10) || First == nullptr)
		{
			return false;
		}
		Map.Add(10, First);
		Map.Add(20, First);
		return Map.Contains(10) && Map.Contains(20) && !Map.Contains(99);
	}

	/**
	 * In-only: Contains on a const&in TMap<int, UObject> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Values Source map received as const TMap<int, UObject>&in
	 * @Inputs three present keys
	 * @Return true when present match and absent do not
	 */
	UFUNCTION()
	ReadContains_UObject(const TMap<int, UObject>&in Values)
	{
		return Values.Contains(10) && Values.Contains(20) && Values.Contains(30) && !Values.Contains(99);
	}

	/**
	 * Out-only: fill an empty &out TMap<int, UObject> with the Contains sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Result Destination received as TMap<int, UObject>&out
	 * @Inputs Empty &out TMap<int, UObject>
	 * @Return void; Result holds the three present keys
	 */
	UFUNCTION()
	FillMapForContains_UObject(TMap<int, UObject>&out Result)
	{
		Result.Add(10, NewObject(GetTransientPackage(), UTMapContainsObject::StaticClass(), n"UTMapContainsObject_Fill_0", true));
		Result.Add(20, NewObject(GetTransientPackage(), UTMapContainsObject::StaticClass(), n"UTMapContainsObject_Fill_1", true));
		Result.Add(30, NewObject(GetTransientPackage(), UTMapContainsObject::StaticClass(), n"UTMapContainsObject_Fill_2", true));
	}

	/**
	 * Inout: Add the third key so Contains becomes true_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Values Map received as TMap<int, UObject>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	AppendForContains_UObject(TMap<int, UObject>&inout Values)
	{
		Values.Add(30, NewObject(GetTransientPackage(), UTMapContainsObject::StaticClass(), n"UTMapContainsObject_Append", true));
	}


}
