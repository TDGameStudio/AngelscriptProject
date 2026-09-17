/**
 * @version v1
 * @summary Empty USTRUCT as a TMap key and as a struct-to-struct map. Equivalent empty keys overwrite so Num is 1. Keep the Count/Fill/Mutate/Return UFUNCTION names.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Empty USTRUCT as a TMap key and as a struct-to-struct map. Equivalent empty keys overwrite so Num is 1. Keep the Count/Fill/Mutate/Return UFUNCTION names.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FEmptyContainerStruct
{
	/**
	 * Empty structs compare equal.
	 *
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs another FEmptyContainerStruct
	 * @Return true
	 * @Param Other the other instance
	 */
	bool opEquals(const FEmptyContainerStruct&in Other) const
	{
		return true;
	}

	/**
	 * Hash empty structs as the constant 17.
	 *
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs none
	 * @Return 17
	 */
	uint32 Hash() const
	{
		return 17;
	}
}

UCLASS()
class ACoverageEmptyStructContainerActor : AActor
{
	UPROPERTY()
	int StructKeyMapValueCount = 0;

	UPROPERTY()
	int StructKeyMapInCount = 0;

	UPROPERTY()
	TMap<FEmptyContainerStruct, int> StructKeyMapInout;

	UPROPERTY()
	TMap<FEmptyContainerStruct, int> StructKeyMapOut;

	UPROPERTY()
	int StructStructMapValueCount = 0;

	UPROPERTY()
	int StructStructMapInCount = 0;

	UPROPERTY()
	TMap<FEmptyContainerStruct, FEmptyContainerStruct> StructStructMapInout;

	UPROPERTY()
	TMap<FEmptyContainerStruct, FEmptyContainerStruct> StructStructMapOut;

	UPROPERTY()
	bool EmptyKeyMapOverwrote = false;

	UPROPERTY()
	bool EmptyKeyMapInFound = false;

	UPROPERTY()
	bool EmptyStructStructMapFound = false;

	UPROPERTY()
	bool EmptyStructStructMapInFound = false;

	/**
	 * Build a default empty container struct.
	 *
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs none
	 * @Return a default FEmptyContainerStruct
	 */
	FEmptyContainerStruct MakeEmpty()
	{
		FEmptyContainerStruct Item;
		return Item;
	}

	/**
	 * Count a by-value empty-struct-key map and record overwrite of value 200.
	 *
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs a TMap of FEmptyContainerStruct to int
	 * @Return Items.Num() stored in StructKeyMapValueCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructKeyMapValue(TMap<FEmptyContainerStruct, int> Items)
	{
		StructKeyMapValueCount = Items.Num();
		int Found = 0;
		EmptyKeyMapOverwrote = Items.Find(MakeEmpty(), Found) && Found == 200;
		return StructKeyMapValueCount;
	}

	/**
	 * Count a const-in empty-struct-key map and record find of value 220.
	 *
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs a const &in TMap of FEmptyContainerStruct to int
	 * @Return Items.Num() stored in StructKeyMapInCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructKeyMapIn(const TMap<FEmptyContainerStruct, int>&in Items)
	{
		StructKeyMapInCount = Items.Num();
		int Found = 0;
		EmptyKeyMapInFound = Items.Find(MakeEmpty(), Found) && Found == 220;
		return StructKeyMapInCount;
	}

	/**
	 * Fill an out empty-struct-key map with one entry.
	 *
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs an &out TMap of FEmptyContainerStruct to int
	 * @Return Items with value 500, copied to StructKeyMapOut
	 * @Param Items the out map
	 */
	UFUNCTION(BlueprintCallable)
	void FillStructKeyMapOut(TMap<FEmptyContainerStruct, int>&out Items)
	{
		Items.Add(MakeEmpty(), 500);
		StructKeyMapOut = Items;
	}

	/**
	 * Append one empty-struct-key entry to an inout map.
	 *
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs an &inout TMap of FEmptyContainerStruct to int
	 * @Return StructKeyMapInout copied from Items after adding 300
	 * @Param Items the inout map
	 */
	UFUNCTION(BlueprintCallable)
	void MutateStructKeyMapInout(TMap<FEmptyContainerStruct, int>&inout Items)
	{
		Items.Add(MakeEmpty(), 300);
		StructKeyMapInout = Items;
	}

	/**
	 * Return an empty-struct-key map with value 400.
	 *
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs none
	 * @Return a TMap with one empty key mapped to 400
	 */
	UFUNCTION(BlueprintCallable)
	TMap<FEmptyContainerStruct, int> ReturnStructKeyMap()
	{
		TMap<FEmptyContainerStruct, int> Items;
		Items.Add(MakeEmpty(), 400);
		return Items;
	}

	/**
	 * Count a by-value struct-to-struct map and record Find of the empty key.
	 *
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs a TMap of FEmptyContainerStruct to FEmptyContainerStruct
	 * @Return Items.Num() stored in StructStructMapValueCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructStructMapValue(TMap<FEmptyContainerStruct, FEmptyContainerStruct> Items)
	{
		StructStructMapValueCount = Items.Num();
		FEmptyContainerStruct Found;
		EmptyStructStructMapFound = Items.Find(MakeEmpty(), Found);
		return StructStructMapValueCount;
	}

	/**
	 * Count a const-in struct-to-struct map and record Find of the empty key.
	 *
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs a const &in TMap of FEmptyContainerStruct to FEmptyContainerStruct
	 * @Return Items.Num() stored in StructStructMapInCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructStructMapIn(const TMap<FEmptyContainerStruct, FEmptyContainerStruct>&in Items)
	{
		StructStructMapInCount = Items.Num();
		FEmptyContainerStruct Found;
		EmptyStructStructMapInFound = Items.Find(MakeEmpty(), Found);
		return StructStructMapInCount;
	}

	/**
	 * Fill an out struct-to-struct map with one empty-to-empty entry.
	 *
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs an &out TMap of FEmptyContainerStruct to FEmptyContainerStruct
	 * @Return StructStructMapOut copied from Items
	 * @Param Items the out map
	 */
	UFUNCTION(BlueprintCallable)
	void FillStructStructMapOut(TMap<FEmptyContainerStruct, FEmptyContainerStruct>&out Items)
	{
		Items.Add(MakeEmpty(), MakeEmpty());
		StructStructMapOut = Items;
	}

	/**
	 * Append one empty-to-empty entry to an inout map.
	 *
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs an &inout TMap of FEmptyContainerStruct to FEmptyContainerStruct
	 * @Return StructStructMapInout copied from Items
	 * @Param Items the inout map
	 */
	UFUNCTION(BlueprintCallable)
	void MutateStructStructMapInout(TMap<FEmptyContainerStruct, FEmptyContainerStruct>&inout Items)
	{
		Items.Add(MakeEmpty(), MakeEmpty());
		StructStructMapInout = Items;
	}

	/**
	 * Return a struct-to-struct map with one empty-to-empty entry.
	 *
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs none
	 * @Return a TMap with one empty key
	 */
	UFUNCTION(BlueprintCallable)
	TMap<FEmptyContainerStruct, FEmptyContainerStruct> ReturnStructStructMap()
	{
		TMap<FEmptyContainerStruct, FEmptyContainerStruct> Items;
		Items.Add(MakeEmpty(), MakeEmpty());
		return Items;
	}

	/**
	 * Observe that a local empty-struct-key map has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs a default TMap of FEmptyContainerStruct to int
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int StructKeyMapEmptyDefault()
	{
		TMap<FEmptyContainerStruct, int> Items;
		return Items.Num();
	}

	/**
	 * Observe that two equivalent empty keys overwrite so Num is 1 and Find is 200.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs Add 100 then Add 200 with the same empty key
	 * @Return 1 when Num is 1 and Find yields 200, otherwise 0
	 * @Boundary key overwrite
	 */
	UFUNCTION()
	int StructKeyMapOverwriteBoundary()
	{
		TMap<FEmptyContainerStruct, int> Items;
		FEmptyContainerStruct Key;
		Items.Add(Key, 100);
		Items.Add(Key, 200);
		int Found = 0;
		if (Items.Num() != 1)
		{
			return 0;
		}
		if (!Items.Find(Key, Found))
		{
			return 0;
		}
		if (Found != 200)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a local struct-to-struct map has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs a default TMap of FEmptyContainerStruct to FEmptyContainerStruct
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int StructStructMapEmptyDefault()
	{
		TMap<FEmptyContainerStruct, FEmptyContainerStruct> Items;
		return Items.Num();
	}

	/**
	 * Observe Find of an empty-to-empty map entry.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerStructKeyMapCallShapes
	 * @Inputs Add of an empty key to itself
	 * @Return true when Find succeeds and Num is 1
	 * @Boundary find empty key
	 */
	UFUNCTION()
	bool StructStructMapFindBoundary()
	{
		TMap<FEmptyContainerStruct, FEmptyContainerStruct> Items;
		FEmptyContainerStruct Key;
		Items.Add(Key, Key);
		FEmptyContainerStruct Found;
		if (!Items.Find(Key, Found))
		{
			return false;
		}
		return Items.Num() == 1;
	}
}
/** @end */
