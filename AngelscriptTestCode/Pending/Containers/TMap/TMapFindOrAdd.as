/**
 * @version v1
 * @summary FindOrAdd returns a reference to the existing value, or inserts a default. The defaulted overload is the RoundTrip surface; FindOrAdd(Key, DefaultValue) stays int Observe. int/int is canonical; other shapes repeat the.
 * @topic Containers
 */
/**
 * @version root
 * @summary FindOrAdd returns a reference to the existing value, or inserts a default. The defaulted overload is the RoundTrip surface; FindOrAdd(Key, DefaultValue) stays int Observe. int/int is canonical; other shapes repeat the.
 * @topic Baseline
 */
UCLASS()
class UTMapFindOrAddObject : UObject
{
}

namespace TMapTest
{
	/**
	 * Observe FindOrAdd: existing key keeps its value; missing key inserts default.
	 *
	 * @Kind Observe
	 * @Covers TMap.FindOrAdd
	 * @Inputs TMap<int, int>; FindOrAdd present; FindOrAdd missing
	 * @Return true when present is unchanged identity/value and missing is inserted
	 */
	UFUNCTION()
	bool FindOrAddHitsOrInsertsDefault()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		Map.FindOrAdd(10) += 50;
		Map.FindOrAdd(20) += 200;
		return Map.Num() == 2
			&& Map[10] == 100 + 50
			&& Map[20] == 200;
	}

	/**
	 * In-only: read a map after FindOrAdd.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadFindOrAdd(const TMap<int, int>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: FindOrAdd three keys into an empty &out TMap<int, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByFindOrAdd(TMap<int, int>&out Result)
	{
		Result.FindOrAdd(10) = 100;
		Result.FindOrAdd(20) = 200;
		Result.FindOrAdd(30) = 300;
	}

	/**
	 * Inout: FindOrAdd the third key onto an existing two-pair map.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Values Map received as TMap<int, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AppendByFindOrAdd(TMap<int, int>&inout Values)
	{
		Values.FindOrAdd(30) = 300;
	}


	/**
	 * Observe FindOrAdd_FString: existing key keeps its value; missing key inserts default.
	 *
	 * @Kind Observe
	 * @Covers TMap.FindOrAdd
	 * @Inputs TMap<FString, int>; FindOrAdd present; FindOrAdd missing
	 * @Return true when present is unchanged identity/value and missing is inserted
	 */
	UFUNCTION()
	bool FindOrAddHitsOrInsertsDefault_FString()
	{
		TMap<FString, int> Map;
		Map.Add("alpha", 100);
		Map.FindOrAdd("alpha") += 50;
		Map.FindOrAdd("beta") += 200;
		return Map.Num() == 2
			&& Map["alpha"] == 100 + 50
			&& Map["beta"] == 200;
	}

	/**
	 * In-only: read a map after FindOrAdd_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Values Source map received as const TMap<FString, int>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadFindOrAdd_FString(const TMap<FString, int>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: FindOrAdd three keys into an empty &out TMap<FString, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Result Destination received as TMap<FString, int>&out
	 * @Inputs Empty &out TMap<FString, int>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByFindOrAdd_FString(TMap<FString, int>&out Result)
	{
		Result.FindOrAdd("alpha") = 100;
		Result.FindOrAdd("beta") = 200;
		Result.FindOrAdd("gamma") = 300;
	}

	/**
	 * Inout: FindOrAdd the third key onto an existing two-pair map_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Values Map received as TMap<FString, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AppendByFindOrAdd_FString(TMap<FString, int>&inout Values)
	{
		Values.FindOrAdd("gamma") = 300;
	}


	/**
	 * Observe FindOrAdd_FName: existing key keeps its value; missing key inserts default.
	 *
	 * @Kind Observe
	 * @Covers TMap.FindOrAdd
	 * @Inputs TMap<FName, int>; FindOrAdd present; FindOrAdd missing
	 * @Return true when present is unchanged identity/value and missing is inserted
	 */
	UFUNCTION()
	bool FindOrAddHitsOrInsertsDefault_FName()
	{
		TMap<FName, int> Map;
		Map.Add(n"Red", 1);
		Map.FindOrAdd(n"Red") += 5;
		Map.FindOrAdd(n"Green") += 20;
		return Map.Num() == 2
			&& Map[n"Red"] == 1 + 5
			&& Map[n"Green"] == 20;
	}

	/**
	 * In-only: read a map after FindOrAdd_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Values Source map received as const TMap<FName, int>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadFindOrAdd_FName(const TMap<FName, int>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: FindOrAdd three keys into an empty &out TMap<FName, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Result Destination received as TMap<FName, int>&out
	 * @Inputs Empty &out TMap<FName, int>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByFindOrAdd_FName(TMap<FName, int>&out Result)
	{
		Result.FindOrAdd(n"Red") = 1;
		Result.FindOrAdd(n"Green") = 2;
		Result.FindOrAdd(n"Blue") = 3;
	}

	/**
	 * Inout: FindOrAdd the third key onto an existing two-pair map_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Values Map received as TMap<FName, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AppendByFindOrAdd_FName(TMap<FName, int>&inout Values)
	{
		Values.FindOrAdd(n"Blue") = 3;
	}


	/**
	 * Observe FindOrAdd_bool: existing key keeps its value; missing key inserts default.
	 *
	 * @Kind Observe
	 * @Covers TMap.FindOrAdd
	 * @Inputs TMap<int, bool>; FindOrAdd present; FindOrAdd missing
	 * @Return true when present is unchanged identity/value and missing is inserted
	 */
	UFUNCTION()
	bool FindOrAddHitsOrInsertsDefault_bool()
	{
		TMap<int, bool> Map;
		Map.Add(1, true);
		if (Map.FindOrAdd(1) != true)
		{
			return false;
		}
		bool Added = Map.FindOrAdd(2);
		return Added == false && Map.Num() == 2 && Map.Contains(2);
	}

	/**
	 * In-only: read a map after FindOrAdd_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Values Source map received as const TMap<int, bool>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadFindOrAdd_bool(const TMap<int, bool>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: FindOrAdd three keys into an empty &out TMap<int, bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Result Destination received as TMap<int, bool>&out
	 * @Inputs Empty &out TMap<int, bool>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByFindOrAdd_bool(TMap<int, bool>&out Result)
	{
		Result.FindOrAdd(1) = true;
		Result.FindOrAdd(2) = false;
		Result.FindOrAdd(3) = true;
	}

	/**
	 * Inout: FindOrAdd the third key onto an existing two-pair map_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Values Map received as TMap<int, bool>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AppendByFindOrAdd_bool(TMap<int, bool>&inout Values)
	{
		Values.FindOrAdd(3) = true;
	}


	/**
	 * Observe FindOrAdd_FVector: existing key keeps its value; missing key inserts default.
	 *
	 * @Kind Observe
	 * @Covers TMap.FindOrAdd
	 * @Inputs TMap<int, FVector>; FindOrAdd present; FindOrAdd missing
	 * @Return true when present is unchanged identity/value and missing is inserted
	 */
	UFUNCTION()
	bool FindOrAddHitsOrInsertsDefault_FVector()
	{
		TMap<int, FVector> Map;
		Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
		if (!Map.FindOrAdd(1).Equals(FVector(1.0f, 0.0f, 0.0f)))
		{
			return false;
		}
		FVector Added = Map.FindOrAdd(2);
		return Added.Equals(FVector::ZeroVector) && Map.Num() == 2 && Map.Contains(2);
	}

	/**
	 * In-only: read a map after FindOrAdd_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Values Source map received as const TMap<int, FVector>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadFindOrAdd_FVector(const TMap<int, FVector>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: FindOrAdd three keys into an empty &out TMap<int, FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Result Destination received as TMap<int, FVector>&out
	 * @Inputs Empty &out TMap<int, FVector>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByFindOrAdd_FVector(TMap<int, FVector>&out Result)
	{
		Result.FindOrAdd(1) = FVector(1.0f, 0.0f, 0.0f);
		Result.FindOrAdd(2) = FVector(0.0f, 1.0f, 0.0f);
		Result.FindOrAdd(3) = FVector(0.0f, 0.0f, 1.0f);
	}

	/**
	 * Inout: FindOrAdd the third key onto an existing two-pair map_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Values Map received as TMap<int, FVector>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AppendByFindOrAdd_FVector(TMap<int, FVector>&inout Values)
	{
		Values.FindOrAdd(3) = FVector(0.0f, 0.0f, 1.0f);
	}


	/**
	 * Observe FindOrAdd_UObject: existing key keeps its value; missing key inserts default.
	 *
	 * @Kind Observe
	 * @Covers TMap.FindOrAdd
	 * @Inputs TMap<int, UObject>; FindOrAdd present; FindOrAdd missing
	 * @Return true when present is unchanged identity/value and missing is inserted
	 */
	UFUNCTION()
	bool FindOrAddHitsOrInsertsDefault_UObject()
	{
		TMap<int, UObject> Map;
		UObject First = NewObject(GetTransientPackage(), UTMapFindOrAddObject::StaticClass(), n"TMapFindOrAdd_First", true);
		Map.Add(10, First);
		if (Map.FindOrAdd(10) != First)
		{
			return false;
		}
		UObject Added = Map.FindOrAdd(20);
		return Added == nullptr && Map.Num() == 2 && Map.Contains(20);
	}

	/**
	 * In-only: read a map after FindOrAdd_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Values Source map received as const TMap<int, UObject>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadFindOrAdd_UObject(const TMap<int, UObject>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: FindOrAdd three keys into an empty &out TMap<int, UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Result Destination received as TMap<int, UObject>&out
	 * @Inputs Empty &out TMap<int, UObject>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByFindOrAdd_UObject(TMap<int, UObject>&out Result)
	{
		Result.FindOrAdd(10) = NewObject(GetTransientPackage(), UTMapFindOrAddObject::StaticClass(), n"TMapFindOrAdd_Fill_0", true);
		Result.FindOrAdd(20) = NewObject(GetTransientPackage(), UTMapFindOrAddObject::StaticClass(), n"TMapFindOrAdd_Fill_1", true);
		Result.FindOrAdd(30) = NewObject(GetTransientPackage(), UTMapFindOrAddObject::StaticClass(), n"TMapFindOrAdd_Fill_2", true);
	}

	/**
	 * Inout: FindOrAdd the third key onto an existing two-pair map_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Values Map received as TMap<int, UObject>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AppendByFindOrAdd_UObject(TMap<int, UObject>&inout Values)
	{
		Values.FindOrAdd(30) = NewObject(GetTransientPackage(), UTMapFindOrAddObject::StaticClass(), n"TMapFindOrAdd_Append", true);
	}


	/**
	 * Observe FindOrAdd with an explicit default: missing inserts DefaultValue; hit ignores it.
	 *
	 * @Kind Observe
	 * @Covers TMap.FindOrAdd
	 * @Inputs TMap<int, int> [10->100]; FindOrAdd(10, 7); FindOrAdd(20, 200)
	 * @Return true when 10 stays 100, 20 is 200, and Num is 2
	 */
	UFUNCTION()
	bool FindOrAddWithDefaultInsertsOnlyWhenMissing()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		if (Map.FindOrAdd(10, 7) != 100)
		{
			return false;
		}
		return Map.FindOrAdd(20, 200) == 200 && Map.Num() == 2 && Map[20] == 200;
	}

}
/** @end */
