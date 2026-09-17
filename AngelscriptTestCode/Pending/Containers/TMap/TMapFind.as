/**
 * @version v1
 * @summary Find copies the value for a present key and returns false when absent. Hits and misses are observed locally, then through UFUNCTION in, out, and inout. int/int is canonical; other shapes repeat the same four entries with.
 * @topic Containers
 */
/**
 * @version root
 * @summary Find copies the value for a present key and returns false when absent. Hits and misses are observed locally, then through UFUNCTION in, out, and inout. int/int is canonical; other shapes repeat the same four entries with.
 * @topic Baseline
 */
UCLASS()
class UTMapFindObject : UObject
{
}

namespace TMapTest
{
	/**
	 * Observe Find: hit copies the value; miss returns false.
	 *
	 * @Kind Observe
	 * @Covers TMap.Find
	 * @Inputs TMap<int, int> with pairs; Find present; Find missing
	 * @Return true when hit copies the value and miss is false
	 */
	UFUNCTION()
	bool FindHitsAndMissesAbsent()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		Map.Add(20, 200);
		int Found = 0;
		if (!Map.Find(10, Found) || Found != 100)
		{
			return false;
		}
		int Miss = 0;
		return !Map.Find(99, Miss);
	}

	/**
	 * In-only: Find on a const&in TMap<int, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs three present keys
	 * @Return true when a present Find hits and a missing Find misses
	 */
	UFUNCTION()
	bool ReadFind(const TMap<int, int>&in Values)
	{
		int Found = 0;
		return Values.Find(10, Found)
			&& Found == 100
			&& !Values.Find(99, Found);
	}

	/**
	 * Out-only: fill an empty &out TMap<int, int> for Find.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapForFind(TMap<int, int>&out Result)
	{
		Result.Add(10, 100);
		Result.Add(20, 200);
		Result.Add(30, 300);
	}

	/**
	 * Inout: Add the third key so Find can hit it.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Values Map received as TMap<int, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	void AppendForFind(TMap<int, int>&inout Values)
	{
		Values.Add(30, 300);
	}


	/**
	 * Observe Find_FString: hit copies the value; miss returns false.
	 *
	 * @Kind Observe
	 * @Covers TMap.Find
	 * @Inputs TMap<FString, int> with pairs; Find present; Find missing
	 * @Return true when hit copies the value and miss is false
	 */
	UFUNCTION()
	bool FindHitsAndMissesAbsent_FString()
	{
		TMap<FString, int> Map;
		Map.Add("alpha", 100);
		Map.Add("beta", 200);
		int Found = 0;
		if (!Map.Find("alpha", Found) || Found != 100)
		{
			return false;
		}
		int Miss = 0;
		return !Map.Find("missing", Miss);
	}

	/**
	 * In-only: Find on a const&in TMap<FString, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Values Source map received as const TMap<FString, int>&in
	 * @Inputs three present keys
	 * @Return true when a present Find hits and a missing Find misses
	 */
	UFUNCTION()
	bool ReadFind_FString(const TMap<FString, int>&in Values)
	{
		int Found = 0;
		return Values.Find("alpha", Found)
			&& Found == 100
			&& !Values.Find("missing", Found);
	}

	/**
	 * Out-only: fill an empty &out TMap<FString, int> for Find.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Result Destination received as TMap<FString, int>&out
	 * @Inputs Empty &out TMap<FString, int>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapForFind_FString(TMap<FString, int>&out Result)
	{
		Result.Add("alpha", 100);
		Result.Add("beta", 200);
		Result.Add("gamma", 300);
	}

	/**
	 * Inout: Add the third key so Find can hit it_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Values Map received as TMap<FString, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	void AppendForFind_FString(TMap<FString, int>&inout Values)
	{
		Values.Add("gamma", 300);
	}


	/**
	 * Observe Find_FName: hit copies the value; miss returns false.
	 *
	 * @Kind Observe
	 * @Covers TMap.Find
	 * @Inputs TMap<FName, int> with pairs; Find present; Find missing
	 * @Return true when hit copies the value and miss is false
	 */
	UFUNCTION()
	bool FindHitsAndMissesAbsent_FName()
	{
		TMap<FName, int> Map;
		Map.Add(n"Red", 1);
		Map.Add(n"Green", 2);
		int Found = 0;
		if (!Map.Find(n"Red", Found) || Found != 1)
		{
			return false;
		}
		int Miss = 0;
		return !Map.Find(n"Missing", Miss);
	}

	/**
	 * In-only: Find on a const&in TMap<FName, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Values Source map received as const TMap<FName, int>&in
	 * @Inputs three present keys
	 * @Return true when a present Find hits and a missing Find misses
	 */
	UFUNCTION()
	bool ReadFind_FName(const TMap<FName, int>&in Values)
	{
		int Found = 0;
		return Values.Find(n"Red", Found)
			&& Found == 1
			&& !Values.Find(n"Missing", Found);
	}

	/**
	 * Out-only: fill an empty &out TMap<FName, int> for Find.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Result Destination received as TMap<FName, int>&out
	 * @Inputs Empty &out TMap<FName, int>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapForFind_FName(TMap<FName, int>&out Result)
	{
		Result.Add(n"Red", 1);
		Result.Add(n"Green", 2);
		Result.Add(n"Blue", 3);
	}

	/**
	 * Inout: Add the third key so Find can hit it_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Values Map received as TMap<FName, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	void AppendForFind_FName(TMap<FName, int>&inout Values)
	{
		Values.Add(n"Blue", 3);
	}


	/**
	 * Observe Find_bool: hit copies the value; miss returns false.
	 *
	 * @Kind Observe
	 * @Covers TMap.Find
	 * @Inputs TMap<int, bool> with pairs; Find present; Find missing
	 * @Return true when hit copies the value and miss is false
	 */
	UFUNCTION()
	bool FindHitsAndMissesAbsent_bool()
	{
		TMap<int, bool> Map;
		Map.Add(1, true);
		Map.Add(2, false);
		bool Found = false;
		if (!Map.Find(1, Found) || Found != true)
		{
			return false;
		}
		bool Miss = false;
		return !Map.Find(99, Miss);
	}

	/**
	 * In-only: Find on a const&in TMap<int, bool> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Values Source map received as const TMap<int, bool>&in
	 * @Inputs three present keys
	 * @Return true when a present Find hits and a missing Find misses
	 */
	UFUNCTION()
	bool ReadFind_bool(const TMap<int, bool>&in Values)
	{
		bool Found = false;
		return Values.Find(1, Found)
			&& Found == true
			&& !Values.Find(99, Found);
	}

	/**
	 * Out-only: fill an empty &out TMap<int, bool> for Find.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Result Destination received as TMap<int, bool>&out
	 * @Inputs Empty &out TMap<int, bool>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapForFind_bool(TMap<int, bool>&out Result)
	{
		Result.Add(1, true);
		Result.Add(2, false);
		Result.Add(3, true);
	}

	/**
	 * Inout: Add the third key so Find can hit it_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Values Map received as TMap<int, bool>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	void AppendForFind_bool(TMap<int, bool>&inout Values)
	{
		Values.Add(3, true);
	}


	/**
	 * Observe Find_FVector: hit copies the value; miss returns false.
	 *
	 * @Kind Observe
	 * @Covers TMap.Find
	 * @Inputs TMap<int, FVector> with pairs; Find present; Find missing
	 * @Return true when hit copies the value and miss is false
	 */
	UFUNCTION()
	bool FindHitsAndMissesAbsent_FVector()
	{
		TMap<int, FVector> Map;
		Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
		FVector Found = FVector::ZeroVector;
		if (!Map.Find(1, Found) || !Found.Equals(FVector(1.0f, 0.0f, 0.0f)))
		{
			return false;
		}
		FVector Miss = FVector::ZeroVector;
		return !Map.Find(99, Miss);
	}

	/**
	 * In-only: Find on a const&in TMap<int, FVector> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Values Source map received as const TMap<int, FVector>&in
	 * @Inputs three present keys
	 * @Return true when a present Find hits and a missing Find misses
	 */
	UFUNCTION()
	bool ReadFind_FVector(const TMap<int, FVector>&in Values)
	{
		FVector Found = FVector::ZeroVector;
		return Values.Find(1, Found)
			&& Found.Equals(FVector(1.0f, 0.0f, 0.0f))
			&& !Values.Find(99, Found);
	}

	/**
	 * Out-only: fill an empty &out TMap<int, FVector> for Find.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Result Destination received as TMap<int, FVector>&out
	 * @Inputs Empty &out TMap<int, FVector>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapForFind_FVector(TMap<int, FVector>&out Result)
	{
		Result.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Result.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Result.Add(3, FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Inout: Add the third key so Find can hit it_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Values Map received as TMap<int, FVector>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	void AppendForFind_FVector(TMap<int, FVector>&inout Values)
	{
		Values.Add(3, FVector(0.0f, 0.0f, 1.0f));
	}


	/**
	 * Observe Find_UObject: hit copies the value; miss returns false.
	 *
	 * @Kind Observe
	 * @Covers TMap.Find
	 * @Inputs TMap<int, UObject> with pairs; Find present; Find missing
	 * @Return true when hit copies the value and miss is false
	 */
	UFUNCTION()
	bool FindHitsAndMissesAbsent_UObject()
	{
		TMap<int, UObject> Map;
		UObject First = NewObject(GetTransientPackage(), UTMapFindObject::StaticClass(), n"TMapFind_First", true);
		Map.Add(10, First);
		UObject Found = nullptr;
		UObject Miss = First;
		return Map.Find(10, Found) && Found == First && !Map.Find(99, Miss) && Miss == First;
	}

	/**
	 * In-only: Find on a const&in TMap<int, UObject> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Values Source map received as const TMap<int, UObject>&in
	 * @Inputs three present keys
	 * @Return true when a present Find hits and a missing Find misses
	 */
	UFUNCTION()
	bool ReadFind_UObject(const TMap<int, UObject>&in Values)
	{
		UObject Found = nullptr;
		return Values.Find(10, Found) && Found != nullptr && !Values.Find(99, Found);
	}

	/**
	 * Out-only: fill an empty &out TMap<int, UObject> for Find.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Result Destination received as TMap<int, UObject>&out
	 * @Inputs Empty &out TMap<int, UObject>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapForFind_UObject(TMap<int, UObject>&out Result)
	{
		Result.Add(10, NewObject(GetTransientPackage(), UTMapFindObject::StaticClass(), n"UTMapFindObject_Fill_0", true));
		Result.Add(20, NewObject(GetTransientPackage(), UTMapFindObject::StaticClass(), n"UTMapFindObject_Fill_1", true));
		Result.Add(30, NewObject(GetTransientPackage(), UTMapFindObject::StaticClass(), n"UTMapFindObject_Fill_2", true));
	}

	/**
	 * Inout: Add the third key so Find can hit it_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Find
	 * @Param Values Map received as TMap<int, UObject>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; third key is present
	 */
	UFUNCTION()
	void AppendForFind_UObject(TMap<int, UObject>&inout Values)
	{
		Values.Add(30, NewObject(GetTransientPackage(), UTMapFindObject::StaticClass(), n"UTMapFindObject_Append", true));
	}


}
/** @end */
