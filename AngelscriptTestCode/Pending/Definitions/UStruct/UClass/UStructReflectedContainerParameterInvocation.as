/**
 * @version v1
 * @summary Reflected TArray/TMap/TSet UFUNCTION parameter invocation. CountArrayValue 2 with Items[1] ID 11. CountMapValue Find 12. CountSetValue Contains 11. Empty containers count 0. Fill*Out writes two entries.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Reflected TArray/TMap/TSet UFUNCTION parameter invocation. CountArrayValue 2 with Items[1] ID 11. CountMapValue Find 12. CountSetValue Contains 11. Empty containers count 0. Fill*Out writes two entries.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FReflectedContainerItem
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two items by ID and Tag.
	 *
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Inputs another FReflectedContainerItem
	 * @Return true when ID and Tag match
	 * @Param Other the other item
	 */
	bool opEquals(const FReflectedContainerItem&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 257 plus Tag.GetHash().
	 *
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Inputs none
	 * @Return uint32(ID * 257) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 257) + Tag.GetHash();
	}
}

UCLASS()
class ACoverageStructReflectedContainerActor : AActor
{
	UPROPERTY()
	int LastArrayValueCount = 0;

	UPROPERTY()
	int LastArrayInCount = 0;

	UPROPERTY()
	int LastMapValueCount = 0;

	UPROPERTY()
	int LastMapInCount = 0;

	UPROPERTY()
	int LastSetValueCount = 0;

	UPROPERTY()
	int LastSetInCount = 0;

	UPROPERTY()
	bool bArrayValuePreserved = false;

	UPROPERTY()
	bool bMapValuePreserved = false;

	UPROPERTY()
	bool bSetValuePreserved = false;

	/**
	 * Build a reflected container item from an id and tag.
	 *
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Inputs ID and Tag
	 * @Return an item holding those fields
	 * @Param ID the item id
	 * @Param Tag the item tag
	 */
	FReflectedContainerItem MakeItem(int ID, FName Tag)
	{
		FReflectedContainerItem Item;
		Item.ID = ID;
		Item.Tag = Tag;
		return Item;
	}

	/**
	 * Count an array by value and record Items[1] ID 11 Tag ArrayValueB.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Param Items Array received by value
	 * @Inputs Items
	 * @Return LastArrayValueCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountArrayValue(TArray<FReflectedContainerItem> Items)
	{
		LastArrayValueCount = Items.Num();
		bArrayValuePreserved = Items.Num() == 2 && Items[1].ID == 11 && Items[1].Tag == n"ArrayValueB";
		return LastArrayValueCount;
	}

	/**
	 * Count a const array as &in.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Param Items Array received as const TArray<FReflectedContainerItem>&in
	 * @Inputs Items
	 * @Return LastArrayInCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountArrayIn(const TArray<FReflectedContainerItem>&in Items)
	{
		LastArrayInCount = Items.Num();
		return LastArrayInCount;
	}

	/**
	 * Fill an &out array with two items.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Param Items Array received as TArray<FReflectedContainerItem>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void FillArrayOut(TArray<FReflectedContainerItem>&out Items)
	{
		Items.Add(MakeItem(20, n"ArrayOutA"));
		Items.Add(MakeItem(21, n"ArrayOutB"));
	}

	/**
	 * Mutate an &inout array by rewriting the first item and appending.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Param Items Array received as TArray<FReflectedContainerItem>&inout
	 * @Inputs Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void MutateArrayInout(TArray<FReflectedContainerItem>&inout Items)
	{
		FReflectedContainerItem First = Items[0];
		First.ID += 100;
		First.Tag = n"ArrayInoutMutated";
		Items[0] = First;
		Items.Add(MakeItem(22, n"ArrayInoutAdded"));
	}

	/**
	 * Return an array of two items.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Inputs none
	 * @Return IDs 23 and 24
	 */
	UFUNCTION(BlueprintCallable)
	TArray<FReflectedContainerItem> ReturnArray()
	{
		TArray<FReflectedContainerItem> Items;
		Items.Add(MakeItem(23, n"ArrayReturnA"));
		Items.Add(MakeItem(24, n"ArrayReturnB"));
		return Items;
	}

	/**
	 * Count a map by value and record Find(12) ID 12 Tag MapValueB.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return LastMapValueCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountMapValue(TMap<int, FReflectedContainerItem> Items)
	{
		LastMapValueCount = Items.Num();
		FReflectedContainerItem Found;
		bMapValuePreserved = Items.Find(12, Found) && Found.ID == 12 && Found.Tag == n"MapValueB";
		return LastMapValueCount;
	}

	/**
	 * Count a const map as &in.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Param Items Map received as const TMap<int, FReflectedContainerItem>&in
	 * @Inputs Items
	 * @Return LastMapInCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountMapIn(const TMap<int, FReflectedContainerItem>&in Items)
	{
		LastMapInCount = Items.Num();
		return LastMapInCount;
	}

	/**
	 * Fill an &out map with two items.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Param Items Map received as TMap<int, FReflectedContainerItem>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void FillMapOut(TMap<int, FReflectedContainerItem>&out Items)
	{
		Items.Add(30, MakeItem(30, n"MapOutA"));
		Items.Add(31, MakeItem(31, n"MapOutB"));
	}

	/**
	 * Mutate an &inout map by rewriting key 10 and adding 32.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Param Items Map received as TMap<int, FReflectedContainerItem>&inout
	 * @Inputs Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void MutateMapInout(TMap<int, FReflectedContainerItem>&inout Items)
	{
		Items[10] = MakeItem(110, n"MapInoutMutated");
		Items.Add(32, MakeItem(32, n"MapInoutAdded"));
	}

	/**
	 * Return a map of two items.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Inputs none
	 * @Return keys 33 and 34
	 */
	UFUNCTION(BlueprintCallable)
	TMap<int, FReflectedContainerItem> ReturnMap()
	{
		TMap<int, FReflectedContainerItem> Items;
		Items.Add(33, MakeItem(33, n"MapReturnA"));
		Items.Add(34, MakeItem(34, n"MapReturnB"));
		return Items;
	}

	/**
	 * Count a set by value and record Contains ID 11 Tag SetValueB.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Param Items Set received by value
	 * @Inputs Items
	 * @Return LastSetValueCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountSetValue(TSet<FReflectedContainerItem> Items)
	{
		LastSetValueCount = Items.Num();
		bSetValuePreserved = Items.Contains(MakeItem(11, n"SetValueB"));
		return LastSetValueCount;
	}

	/**
	 * Count a const set as &in.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Param Items Set received as const TSet<FReflectedContainerItem>&in
	 * @Inputs Items
	 * @Return LastSetInCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountSetIn(const TSet<FReflectedContainerItem>&in Items)
	{
		LastSetInCount = Items.Num();
		return LastSetInCount;
	}

	/**
	 * Fill an &out set with two items.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Param Items Set received as TSet<FReflectedContainerItem>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void FillSetOut(TSet<FReflectedContainerItem>&out Items)
	{
		Items.Add(MakeItem(40, n"SetOutA"));
		Items.Add(MakeItem(41, n"SetOutB"));
	}

	/**
	 * Mutate an &inout set by removing SetValueA and adding SetInoutAdded.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Param Items Set received as TSet<FReflectedContainerItem>&inout
	 * @Inputs Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void MutateSetInout(TSet<FReflectedContainerItem>&inout Items)
	{
		Items.Remove(MakeItem(10, n"SetValueA"));
		Items.Add(MakeItem(42, n"SetInoutAdded"));
	}

	/**
	 * Return a set of two items.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Inputs none
	 * @Return IDs 43 and 44
	 */
	UFUNCTION(BlueprintCallable)
	TSet<FReflectedContainerItem> ReturnSet()
	{
		TSet<FReflectedContainerItem> Items;
		Items.Add(MakeItem(43, n"SetReturnA"));
		Items.Add(MakeItem(44, n"SetReturnB"));
		return Items;
	}

	/**
	 * Observe empty container counts and default preserved flags.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Inputs empty array, map, and set
	 * @Return true when all counts are 0 and flags are false
	 * @Boundary empty containers
	 */
	UFUNCTION()
	bool ReflectedContainerDefaultEmpty()
	{
		TArray<FReflectedContainerItem> EmptyArray;
		TMap<int, FReflectedContainerItem> EmptyMap;
		TSet<FReflectedContainerItem> EmptySet;
		if (CountArrayValue(EmptyArray) != 0)
		{
			return false;
		}
		if (CountMapValue(EmptyMap) != 0)
		{
			return false;
		}
		if (CountSetValue(EmptySet) != 0)
		{
			return false;
		}
		if (bArrayValuePreserved)
		{
			return false;
		}
		if (bMapValuePreserved)
		{
			return false;
		}
		return !bSetValuePreserved;
	}

	/**
	 * Observe nominal array/map/set value and in counts.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Inputs two-entry array, map, and set
	 * @Return true when counts are 2 and preserved flags are true
	 */
	UFUNCTION()
	bool ReflectedContainerNominalCounts()
	{
		TArray<FReflectedContainerItem> ArrayItems;
		ArrayItems.Add(MakeItem(10, n"ArrayValueA"));
		ArrayItems.Add(MakeItem(11, n"ArrayValueB"));
		TMap<int, FReflectedContainerItem> MapItems;
		MapItems.Add(11, MakeItem(11, n"MapValueA"));
		MapItems.Add(12, MakeItem(12, n"MapValueB"));
		TSet<FReflectedContainerItem> SetItems;
		SetItems.Add(MakeItem(10, n"SetValueA"));
		SetItems.Add(MakeItem(11, n"SetValueB"));
		if (CountArrayValue(ArrayItems) != 2)
		{
			return false;
		}
		if (!bArrayValuePreserved)
		{
			return false;
		}
		if (CountArrayIn(ArrayItems) != 2)
		{
			return false;
		}
		if (CountMapValue(MapItems) != 2)
		{
			return false;
		}
		if (!bMapValuePreserved)
		{
			return false;
		}
		if (CountSetValue(SetItems) != 2)
		{
			return false;
		}
		return bSetValuePreserved;
	}

	/**
	 * Observe Fill*Out and Return* writing two entries.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructReflectedContainerParameterInvocation
	 * @Inputs empty out destinations
	 * @Return true when all out and return containers have two entries and ReturnArray[0].ID 23
	 */
	UFUNCTION()
	bool ReflectedContainerOutAndReturn()
	{
		TArray<FReflectedContainerItem> ArrayOut;
		FillArrayOut(ArrayOut);
		TMap<int, FReflectedContainerItem> MapOut;
		FillMapOut(MapOut);
		TSet<FReflectedContainerItem> SetOut;
		FillSetOut(SetOut);
		TArray<FReflectedContainerItem> ArrayReturn = ReturnArray();
		TMap<int, FReflectedContainerItem> MapReturn = ReturnMap();
		TSet<FReflectedContainerItem> SetReturn = ReturnSet();
		if (ArrayOut.Num() != 2)
		{
			return false;
		}
		if (MapOut.Num() != 2)
		{
			return false;
		}
		if (SetOut.Num() != 2)
		{
			return false;
		}
		if (ArrayReturn.Num() != 2)
		{
			return false;
		}
		if (ArrayReturn[0].ID != 23)
		{
			return false;
		}
		if (MapReturn.Num() != 2)
		{
			return false;
		}
		return SetReturn.Contains(MakeItem(44, n"SetReturnB"));
	}
}
/** @end */
