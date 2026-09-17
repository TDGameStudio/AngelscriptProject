/**
 * @version v1
 * @summary Default-constructed TMap<K,V> is empty; read-only / no-op ops do not crash. int/int is the canonical case (all six invariants). Other shapes repeat Key-depth entries with a type suffix. Do not invent new function names.
 * @topic Containers
 */
/**
 * @version root
 * @summary Default-constructed TMap<K,V> is empty; read-only / no-op ops do not crash. int/int is the canonical case (all six invariants). Other shapes repeat Key-depth entries with a type suffix. Do not invent new function names.
 * @topic Baseline
 */
UCLASS()
class UTMapEmptyConstructionObject : UObject
{
}

namespace TMapTest
{
	/**
	 * Default-constructed TMap is empty.
	 *
	 * @Kind Observe
	 * @Covers TMap.IsEmpty
	 * @Inputs Default-constructed TMap<int, int>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty()
	{
		TMap<int, int> Map;
		return Map.Num() == 0 && Map.IsEmpty();
	}

	/**
	 * Empty TMap does not contain the probe key.
	 *
	 * @Kind Observe
	 * @Covers TMap.Contains
	 * @Inputs Default-constructed TMap<int, int>; Contains(42)
	 * @Return true when Contains(42) is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain()
	{
		TMap<int, int> Map;
		return !Map.Contains(42);
	}

	/**
	 * Empty TMap Find of the probe key is false.
	 *
	 * @Kind Observe
	 * @Covers TMap.Find
	 * @Inputs Default-constructed TMap<int, int>; Find(42, Out)
	 * @Return true when Find returns false
	 */
	UFUNCTION()
	bool EmptyFindIsFalse()
	{
		TMap<int, int> Map;
		int Out = 0;
		return !Map.Find(42, Out);
	}

	/**
	 * Copy of an empty TMap is also empty.
	 *
	 * @Kind Observe
	 * @Covers TMap copy
	 * @Inputs Default-constructed TMap<int, int>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty()
	{
		TMap<int, int> Map;
		TMap<int, int> Copy = Map;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}

	/**
	 * Two empty TMaps compare equal.
	 *
	 * @Kind Observe
	 * @Covers TMap.opEquals
	 * @Inputs Two default-constructed TMap<int, int>
	 * @Return true when Left == Right
	 */
	UFUNCTION()
	bool EmptyEqualsEmpty()
	{
		TMap<int, int> Left;
		TMap<int, int> Right;
		return Left == Right;
	}

	/**
	 * GetKeys on an empty TMap yields an empty array.
	 *
	 * @Kind Observe
	 * @Covers TMap.GetKeys
	 * @Inputs Default-constructed TMap<int, int>; GetKeys
	 * @Return true when OutKeys.Num() == 0
	 */
	UFUNCTION()
	bool EmptyGetKeysIsEmpty()
	{
		TMap<int, int> Map;
		TArray<int> Keys;
		Map.GetKeys(Keys);
		return Keys.Num() == 0;
	}


	/**
	 * Default-constructed TMap is empty.
	 *
	 * @Kind Observe
	 * @Covers TMap.IsEmpty
	 * @Inputs Default-constructed TMap<FString, int>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_FString()
	{
		TMap<FString, int> Map;
		return Map.Num() == 0 && Map.IsEmpty();
	}

	/**
	 * Empty TMap does not contain the probe key.
	 *
	 * @Kind Observe
	 * @Covers TMap.Contains
	 * @Inputs Default-constructed TMap<FString, int>; Contains("hello")
	 * @Return true when Contains("hello") is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_FString()
	{
		TMap<FString, int> Map;
		return !Map.Contains("hello");
	}

	/**
	 * Copy of an empty TMap is also empty.
	 *
	 * @Kind Observe
	 * @Covers TMap copy
	 * @Inputs Default-constructed TMap<FString, int>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_FString()
	{
		TMap<FString, int> Map;
		TMap<FString, int> Copy = Map;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}


	/**
	 * Default-constructed TMap is empty.
	 *
	 * @Kind Observe
	 * @Covers TMap.IsEmpty
	 * @Inputs Default-constructed TMap<FName, int>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_FName()
	{
		TMap<FName, int> Map;
		return Map.Num() == 0 && Map.IsEmpty();
	}

	/**
	 * Empty TMap does not contain the probe key.
	 *
	 * @Kind Observe
	 * @Covers TMap.Contains
	 * @Inputs Default-constructed TMap<FName, int>; Contains(n"Probe")
	 * @Return true when Contains(n"Probe") is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_FName()
	{
		TMap<FName, int> Map;
		return !Map.Contains(n"Probe");
	}

	/**
	 * Copy of an empty TMap is also empty.
	 *
	 * @Kind Observe
	 * @Covers TMap copy
	 * @Inputs Default-constructed TMap<FName, int>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_FName()
	{
		TMap<FName, int> Map;
		TMap<FName, int> Copy = Map;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}


	/**
	 * Default-constructed TMap is empty.
	 *
	 * @Kind Observe
	 * @Covers TMap.IsEmpty
	 * @Inputs Default-constructed TMap<int, bool>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_bool()
	{
		TMap<int, bool> Map;
		return Map.Num() == 0 && Map.IsEmpty();
	}

	/**
	 * Empty TMap does not contain the probe key.
	 *
	 * @Kind Observe
	 * @Covers TMap.Contains
	 * @Inputs Default-constructed TMap<int, bool>; Contains(42)
	 * @Return true when Contains(42) is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_bool()
	{
		TMap<int, bool> Map;
		return !Map.Contains(42);
	}

	/**
	 * Copy of an empty TMap is also empty.
	 *
	 * @Kind Observe
	 * @Covers TMap copy
	 * @Inputs Default-constructed TMap<int, bool>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_bool()
	{
		TMap<int, bool> Map;
		TMap<int, bool> Copy = Map;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}


	/**
	 * Default-constructed TMap is empty.
	 *
	 * @Kind Observe
	 * @Covers TMap.IsEmpty
	 * @Inputs Default-constructed TMap<int, FVector>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_FVector()
	{
		TMap<int, FVector> Map;
		return Map.Num() == 0 && Map.IsEmpty();
	}

	/**
	 * Empty TMap does not contain the probe key.
	 *
	 * @Kind Observe
	 * @Covers TMap.Contains
	 * @Inputs Default-constructed TMap<int, FVector>; Contains(42)
	 * @Return true when Contains(42) is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_FVector()
	{
		TMap<int, FVector> Map;
		return !Map.Contains(42);
	}

	/**
	 * Copy of an empty TMap is also empty.
	 *
	 * @Kind Observe
	 * @Covers TMap copy
	 * @Inputs Default-constructed TMap<int, FVector>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_FVector()
	{
		TMap<int, FVector> Map;
		TMap<int, FVector> Copy = Map;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}


	/**
	 * Default-constructed TMap is empty.
	 *
	 * @Kind Observe
	 * @Covers TMap.IsEmpty
	 * @Inputs Default-constructed TMap<int, UObject>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_UObject()
	{
		TMap<int, UObject> Map;
		return Map.Num() == 0 && Map.IsEmpty();
	}

	/**
	 * Empty TMap does not contain the probe key.
	 *
	 * @Kind Observe
	 * @Covers TMap.Contains
	 * @Inputs Default-constructed TMap<int, UObject>; Contains(42)
	 * @Return true when Contains(42) is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_UObject()
	{
		TMap<int, UObject> Map;
		return !Map.Contains(42);
	}

	/**
	 * Copy of an empty TMap is also empty.
	 *
	 * @Kind Observe
	 * @Covers TMap copy
	 * @Inputs Default-constructed TMap<int, UObject>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_UObject()
	{
		TMap<int, UObject> Map;
		TMap<int, UObject> Copy = Map;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}


}
/** @end */
