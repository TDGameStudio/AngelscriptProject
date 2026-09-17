/**
 * @version v1
 * @summary GetKeys copies keys into a TArray. Order is native map iteration, not insertion; assert membership and Num, not slot order. GetKeys is the RoundTrip surface; GetValues stays int Observe. int/int is canonical; other.
 * @topic Containers
 */
/**
 * @version root
 * @summary GetKeys copies keys into a TArray. Order is native map iteration, not insertion; assert membership and Num, not slot order. GetKeys is the RoundTrip surface; GetValues stays int Observe. int/int is canonical; other.
 * @topic Baseline
 */
UCLASS()
class UTMapGetKeysObject : UObject
{
}

namespace TMapTest
{
	/**
	 * Observe GetKeys: Num matches, every key is present (order ignored).
	 *
	 * @Kind Observe
	 * @Covers TMap.GetKeys
	 * @Inputs TMap<int, int> with three pairs; GetKeys
	 * @Return true when the key array Num is 3 and Contains each key
	 */
	UFUNCTION()
	bool GetKeysContainsEveryKey()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		Map.Add(20, 200);
		Map.Add(30, 300);
		TArray<int> Keys;
		Map.GetKeys(Keys);
		return Keys.Num() == 3
			&& Keys.Contains(10)
			&& Keys.Contains(20)
			&& Keys.Contains(30);
	}

	/**
	 * In-only: GetKeys on a const&in TMap<int, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs three present keys
	 * @Return true when GetKeys Num is 3 and Contains each key
	 */
	UFUNCTION()
	bool ReadGetKeys(const TMap<int, int>&in Values)
	{
		TArray<int> Keys;
		Values.GetKeys(Keys);
		return Keys.Num() == 3
			&& Keys.Contains(10)
			&& Keys.Contains(20)
			&& Keys.Contains(30);
	}

	/**
	 * Out-only: fill an empty &out TMap<int, int> for GetKeys.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapForGetKeys(TMap<int, int>&out Result)
	{
		Result.Add(10, 100);
		Result.Add(20, 200);
		Result.Add(30, 300);
	}

	/**
	 * Inout: Add the third key so GetKeys Num becomes 3.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Values Map received as TMap<int, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AppendForGetKeys(TMap<int, int>&inout Values)
	{
		Values.Add(30, 300);
	}


	/**
	 * Observe GetKeys_FString: Num matches, every key is present (order ignored).
	 *
	 * @Kind Observe
	 * @Covers TMap.GetKeys
	 * @Inputs TMap<FString, int> with three pairs; GetKeys
	 * @Return true when the key array Num is 3 and Contains each key
	 */
	UFUNCTION()
	bool GetKeysContainsEveryKey_FString()
	{
		TMap<FString, int> Map;
		Map.Add("alpha", 100);
		Map.Add("beta", 200);
		Map.Add("gamma", 300);
		TArray<FString> Keys;
		Map.GetKeys(Keys);
		return Keys.Num() == 3
			&& Keys.Contains("alpha")
			&& Keys.Contains("beta")
			&& Keys.Contains("gamma");
	}

	/**
	 * In-only: GetKeys on a const&in TMap<FString, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Values Source map received as const TMap<FString, int>&in
	 * @Inputs three present keys
	 * @Return true when GetKeys Num is 3 and Contains each key
	 */
	UFUNCTION()
	bool ReadGetKeys_FString(const TMap<FString, int>&in Values)
	{
		TArray<FString> Keys;
		Values.GetKeys(Keys);
		return Keys.Num() == 3
			&& Keys.Contains("alpha")
			&& Keys.Contains("beta")
			&& Keys.Contains("gamma");
	}

	/**
	 * Out-only: fill an empty &out TMap<FString, int> for GetKeys.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Result Destination received as TMap<FString, int>&out
	 * @Inputs Empty &out TMap<FString, int>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapForGetKeys_FString(TMap<FString, int>&out Result)
	{
		Result.Add("alpha", 100);
		Result.Add("beta", 200);
		Result.Add("gamma", 300);
	}

	/**
	 * Inout: Add the third key so GetKeys Num becomes 3_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Values Map received as TMap<FString, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AppendForGetKeys_FString(TMap<FString, int>&inout Values)
	{
		Values.Add("gamma", 300);
	}


	/**
	 * Observe GetKeys_FName: Num matches, every key is present (order ignored).
	 *
	 * @Kind Observe
	 * @Covers TMap.GetKeys
	 * @Inputs TMap<FName, int> with three pairs; GetKeys
	 * @Return true when the key array Num is 3 and Contains each key
	 */
	UFUNCTION()
	bool GetKeysContainsEveryKey_FName()
	{
		TMap<FName, int> Map;
		Map.Add(n"Red", 1);
		Map.Add(n"Green", 2);
		Map.Add(n"Blue", 3);
		TArray<FName> Keys;
		Map.GetKeys(Keys);
		return Keys.Num() == 3
			&& Keys.Contains(n"Red")
			&& Keys.Contains(n"Green")
			&& Keys.Contains(n"Blue");
	}

	/**
	 * In-only: GetKeys on a const&in TMap<FName, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Values Source map received as const TMap<FName, int>&in
	 * @Inputs three present keys
	 * @Return true when GetKeys Num is 3 and Contains each key
	 */
	UFUNCTION()
	bool ReadGetKeys_FName(const TMap<FName, int>&in Values)
	{
		TArray<FName> Keys;
		Values.GetKeys(Keys);
		return Keys.Num() == 3
			&& Keys.Contains(n"Red")
			&& Keys.Contains(n"Green")
			&& Keys.Contains(n"Blue");
	}

	/**
	 * Out-only: fill an empty &out TMap<FName, int> for GetKeys.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Result Destination received as TMap<FName, int>&out
	 * @Inputs Empty &out TMap<FName, int>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapForGetKeys_FName(TMap<FName, int>&out Result)
	{
		Result.Add(n"Red", 1);
		Result.Add(n"Green", 2);
		Result.Add(n"Blue", 3);
	}

	/**
	 * Inout: Add the third key so GetKeys Num becomes 3_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Values Map received as TMap<FName, int>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AppendForGetKeys_FName(TMap<FName, int>&inout Values)
	{
		Values.Add(n"Blue", 3);
	}


	/**
	 * Observe GetKeys_bool: Num matches, every key is present (order ignored).
	 *
	 * @Kind Observe
	 * @Covers TMap.GetKeys
	 * @Inputs TMap<int, bool> with three pairs; GetKeys
	 * @Return true when the key array Num is 3 and Contains each key
	 */
	UFUNCTION()
	bool GetKeysContainsEveryKey_bool()
	{
		TMap<int, bool> Map;
		Map.Add(1, true);
		Map.Add(2, false);
		Map.Add(3, true);
		TArray<int> Keys;
		Map.GetKeys(Keys);
		return Keys.Num() == 3
			&& Keys.Contains(1)
			&& Keys.Contains(2)
			&& Keys.Contains(3);
	}

	/**
	 * In-only: GetKeys on a const&in TMap<int, bool> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Values Source map received as const TMap<int, bool>&in
	 * @Inputs three present keys
	 * @Return true when GetKeys Num is 3 and Contains each key
	 */
	UFUNCTION()
	bool ReadGetKeys_bool(const TMap<int, bool>&in Values)
	{
		TArray<int> Keys;
		Values.GetKeys(Keys);
		return Keys.Num() == 3
			&& Keys.Contains(1)
			&& Keys.Contains(2)
			&& Keys.Contains(3);
	}

	/**
	 * Out-only: fill an empty &out TMap<int, bool> for GetKeys.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Result Destination received as TMap<int, bool>&out
	 * @Inputs Empty &out TMap<int, bool>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapForGetKeys_bool(TMap<int, bool>&out Result)
	{
		Result.Add(1, true);
		Result.Add(2, false);
		Result.Add(3, true);
	}

	/**
	 * Inout: Add the third key so GetKeys Num becomes 3_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Values Map received as TMap<int, bool>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AppendForGetKeys_bool(TMap<int, bool>&inout Values)
	{
		Values.Add(3, true);
	}


	/**
	 * Observe GetKeys_FVector: Num matches, every key is present (order ignored).
	 *
	 * @Kind Observe
	 * @Covers TMap.GetKeys
	 * @Inputs TMap<int, FVector> with three pairs; GetKeys
	 * @Return true when the key array Num is 3 and Contains each key
	 */
	UFUNCTION()
	bool GetKeysContainsEveryKey_FVector()
	{
		TMap<int, FVector> Map;
		Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Map.Add(3, FVector(0.0f, 0.0f, 1.0f));
		TArray<int> Keys;
		Map.GetKeys(Keys);
		return Keys.Num() == 3
			&& Keys.Contains(1)
			&& Keys.Contains(2)
			&& Keys.Contains(3);
	}

	/**
	 * In-only: GetKeys on a const&in TMap<int, FVector> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Values Source map received as const TMap<int, FVector>&in
	 * @Inputs three present keys
	 * @Return true when GetKeys Num is 3 and Contains each key
	 */
	UFUNCTION()
	bool ReadGetKeys_FVector(const TMap<int, FVector>&in Values)
	{
		TArray<int> Keys;
		Values.GetKeys(Keys);
		return Keys.Num() == 3
			&& Keys.Contains(1)
			&& Keys.Contains(2)
			&& Keys.Contains(3);
	}

	/**
	 * Out-only: fill an empty &out TMap<int, FVector> for GetKeys.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Result Destination received as TMap<int, FVector>&out
	 * @Inputs Empty &out TMap<int, FVector>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapForGetKeys_FVector(TMap<int, FVector>&out Result)
	{
		Result.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Result.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Result.Add(3, FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Inout: Add the third key so GetKeys Num becomes 3_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Values Map received as TMap<int, FVector>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AppendForGetKeys_FVector(TMap<int, FVector>&inout Values)
	{
		Values.Add(3, FVector(0.0f, 0.0f, 1.0f));
	}


	/**
	 * Observe GetKeys_UObject: Num matches, every key is present (order ignored).
	 *
	 * @Kind Observe
	 * @Covers TMap.GetKeys
	 * @Inputs TMap<int, UObject> with three pairs; GetKeys
	 * @Return true when the key array Num is 3 and Contains each key
	 */
	UFUNCTION()
	bool GetKeysContainsEveryKey_UObject()
	{
		TMap<int, UObject> Map;
		UObject First = NewObject(GetTransientPackage(), UTMapGetKeysObject::StaticClass(), n"TMapKeys_First", true);
		Map.Add(10, First);
		Map.Add(20, First);
		Map.Add(30, First);
		TArray<int> Keys;
		Map.GetKeys(Keys);
		return Keys.Num() == 3 && Keys.Contains(10) && Keys.Contains(20) && Keys.Contains(30);
	}

	/**
	 * In-only: GetKeys on a const&in TMap<int, UObject> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Values Source map received as const TMap<int, UObject>&in
	 * @Inputs three present keys
	 * @Return true when GetKeys Num is 3 and Contains each key
	 */
	UFUNCTION()
	bool ReadGetKeys_UObject(const TMap<int, UObject>&in Values)
	{
		TArray<int> Keys;
		Values.GetKeys(Keys);
		return Keys.Num() == 3 && Keys.Contains(10) && Keys.Contains(20) && Keys.Contains(30);
	}

	/**
	 * Out-only: fill an empty &out TMap<int, UObject> for GetKeys.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Result Destination received as TMap<int, UObject>&out
	 * @Inputs Empty &out TMap<int, UObject>
	 * @Return void; Result holds the three canonical pairs
	 */
	UFUNCTION()
	void FillMapForGetKeys_UObject(TMap<int, UObject>&out Result)
	{
		Result.Add(10, NewObject(GetTransientPackage(), UTMapGetKeysObject::StaticClass(), n"UTMapGetKeysObject_Fill_0", true));
		Result.Add(20, NewObject(GetTransientPackage(), UTMapGetKeysObject::StaticClass(), n"UTMapGetKeysObject_Fill_1", true));
		Result.Add(30, NewObject(GetTransientPackage(), UTMapGetKeysObject::StaticClass(), n"UTMapGetKeysObject_Fill_2", true));
	}

	/**
	 * Inout: Add the third key so GetKeys Num becomes 3_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.GetKeys
	 * @Param Values Map received as TMap<int, UObject>&inout, starts with two keys
	 * @Inputs Values.Num() == 2
	 * @Return void; Values.Num() == 3
	 */
	UFUNCTION()
	void AppendForGetKeys_UObject(TMap<int, UObject>&inout Values)
	{
		Values.Add(30, NewObject(GetTransientPackage(), UTMapGetKeysObject::StaticClass(), n"UTMapGetKeysObject_Append", true));
	}


	/**
	 * Observe GetValues: Num matches and every stored value is present (order ignored).
	 *
	 * @Kind Observe
	 * @Covers TMap.GetValues
	 * @Inputs TMap<int, int> [10->100, 20->200, 30->300]; GetValues
	 * @Return true when the value array Num is 3 and Contains 100/200/300
	 */
	UFUNCTION()
	bool GetValuesContainsEveryValue()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		Map.Add(20, 200);
		Map.Add(30, 300);
		TArray<int> OutValues;
		Map.GetValues(OutValues);
		return OutValues.Num() == 3
			&& OutValues.Contains(100)
			&& OutValues.Contains(200)
			&& OutValues.Contains(300);
	}

}
/** @end */
