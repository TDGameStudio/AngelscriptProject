/**
 * TArray/TMap/TSet of USTRUCT as value/in/out/inout/return. ArrayValueCount 2,
 * ArrayInCount 2, MapValueCount 2, MapInCount 2, SetReturnContains true.
 * Empty out/inout/return containers before BeginPlay.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructContainerParameterShapeMatrix
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructContainerParameterShapeMatrix
 * @Provenance Theme: Definitions.UStruct. WorldStory: TArray/TMap/TSet of USTRUCT as value/in/out/inout/return.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructContainerParameterShapeMatrix spawn + BeginPlay.
 * @Provenance Oracle: ArrayValueCount 2, ArrayInCount 2, MapValueCount 2, MapInCount 2, SetReturnContains true.
 * @Provenance Extra: empty out/inout/return containers before BeginPlay. FixtureIsolated.
 */

USTRUCT(BlueprintType)
struct FStructContainerParamItem
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two items by ID and Tag.
	 *
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Inputs another FStructContainerParamItem
	 * @Return true when ID and Tag match
	 * @Param Other the other item
	 */
	bool opEquals(const FStructContainerParamItem&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 131 plus Tag.GetHash().
	 *
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Inputs none
	 * @Return uint32(ID * 131) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 131) + Tag.GetHash();
	}
}

UCLASS()
class ACoverageStructContainerParamActor : AActor
{
	UPROPERTY()
	TArray<FStructContainerParamItem> ArrayOut;

	UPROPERTY()
	TArray<FStructContainerParamItem> ArrayInout;

	UPROPERTY()
	TArray<FStructContainerParamItem> ArrayReturn;

	UPROPERTY()
	TMap<int, FStructContainerParamItem> MapOut;

	UPROPERTY()
	TMap<int, FStructContainerParamItem> MapInout;

	UPROPERTY()
	TMap<int, FStructContainerParamItem> MapReturn;

	UPROPERTY()
	TSet<FStructContainerParamItem> SetOut;

	UPROPERTY()
	TSet<FStructContainerParamItem> SetInout;

	UPROPERTY()
	TSet<FStructContainerParamItem> SetReturn;

	UPROPERTY()
	int ArrayValueCount = 0;

	UPROPERTY()
	int ArrayInCount = 0;

	UPROPERTY()
	int MapValueCount = 0;

	UPROPERTY()
	int MapInCount = 0;

	UPROPERTY()
	int SetValueCount = 0;

	UPROPERTY()
	int SetInCount = 0;

	UPROPERTY()
	bool SetReturnContains = false;

	/**
	 * Build a container item from an id and tag.
	 *
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Inputs ID and Tag
	 * @Return an item holding those fields
	 * @Param ID the item id
	 * @Param Tag the item tag
	 */
	FStructContainerParamItem MakeItem(int ID, FName Tag)
	{
		FStructContainerParamItem Item;
		Item.ID = ID;
		Item.Tag = Tag;
		return Item;
	}

	/**
	 * Count a TArray of items received by value.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Param Items Array received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	int CountArrayValue(TArray<FStructContainerParamItem> Items)
	{
		return Items.Num();
	}

	/**
	 * Count a const TArray of items received as &in.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Param Items Array received as const TArray<FStructContainerParamItem>&in
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	int CountArrayIn(const TArray<FStructContainerParamItem>&in Items)
	{
		return Items.Num();
	}

	/**
	 * Fill an &out array with two items.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Param Items Array received as TArray<FStructContainerParamItem>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	void FillArrayOut(TArray<FStructContainerParamItem>&out Items)
	{
		Items.Add(MakeItem(10, n"ArrayOutA"));
		Items.Add(MakeItem(11, n"ArrayOutB"));
	}

	/**
	 * Mutate an &inout array by appending and rewriting the first ID.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Param Items Array received as TArray<FStructContainerParamItem>&inout
	 * @Inputs Items
	 * @Return void
	 */
	void MutateArrayInout(TArray<FStructContainerParamItem>&inout Items)
	{
		Items.Add(MakeItem(12, n"ArrayInoutAdded"));
		FStructContainerParamItem First = Items[0];
		First.ID = 13;
		Items[0] = First;
	}

	/**
	 * Return an array of two items.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Inputs none
	 * @Return two ArrayReturn items
	 */
	TArray<FStructContainerParamItem> ReturnArray()
	{
		TArray<FStructContainerParamItem> Items;
		Items.Add(MakeItem(14, n"ArrayReturnA"));
		Items.Add(MakeItem(15, n"ArrayReturnB"));
		return Items;
	}

	/**
	 * Count a TMap of items received by value.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	int CountMapValue(TMap<int, FStructContainerParamItem> Items)
	{
		return Items.Num();
	}

	/**
	 * Count a const TMap of items received as &in.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Param Items Map received as const TMap<int, FStructContainerParamItem>&in
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	int CountMapIn(const TMap<int, FStructContainerParamItem>&in Items)
	{
		return Items.Num();
	}

	/**
	 * Fill an &out map with two items.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Param Items Map received as TMap<int, FStructContainerParamItem>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	void FillMapOut(TMap<int, FStructContainerParamItem>&out Items)
	{
		Items.Add(20, MakeItem(20, n"MapOutA"));
		Items.Add(21, MakeItem(21, n"MapOutB"));
	}

	/**
	 * Mutate an &inout map by adding 22 and replacing key 1.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Param Items Map received as TMap<int, FStructContainerParamItem>&inout
	 * @Inputs Items
	 * @Return void
	 */
	void MutateMapInout(TMap<int, FStructContainerParamItem>&inout Items)
	{
		Items.Add(22, MakeItem(22, n"MapInoutAdded"));
		Items[1] = MakeItem(23, n"MapInoutReplaced");
	}

	/**
	 * Return a map of two items.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Inputs none
	 * @Return two MapReturn items
	 */
	TMap<int, FStructContainerParamItem> ReturnMap()
	{
		TMap<int, FStructContainerParamItem> Items;
		Items.Add(24, MakeItem(24, n"MapReturnA"));
		Items.Add(25, MakeItem(25, n"MapReturnB"));
		return Items;
	}

	/**
	 * Count a TSet of items received by value.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Param Items Set received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	int CountSetValue(TSet<FStructContainerParamItem> Items)
	{
		return Items.Num();
	}

	/**
	 * Count a const TSet of items received as &in.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Param Items Set received as const TSet<FStructContainerParamItem>&in
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	int CountSetIn(const TSet<FStructContainerParamItem>&in Items)
	{
		return Items.Num();
	}

	/**
	 * Fill an &out set with two items.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Param Items Set received as TSet<FStructContainerParamItem>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	void FillSetOut(TSet<FStructContainerParamItem>&out Items)
	{
		Items.Add(MakeItem(30, n"SetOutA"));
		Items.Add(MakeItem(31, n"SetOutB"));
	}

	/**
	 * Mutate an &inout set by adding 32 and removing SetInitialB.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Param Items Set received as TSet<FStructContainerParamItem>&inout
	 * @Inputs Items
	 * @Return void
	 */
	void MutateSetInout(TSet<FStructContainerParamItem>&inout Items)
	{
		Items.Add(MakeItem(32, n"SetInoutAdded"));
		Items.Remove(MakeItem(2, n"SetInitialB"));
	}

	/**
	 * Return a set of two items.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Inputs none
	 * @Return two SetReturn items
	 */
	TSet<FStructContainerParamItem> ReturnSet()
	{
		TSet<FStructContainerParamItem> Items;
		Items.Add(MakeItem(33, n"SetReturnA"));
		Items.Add(MakeItem(34, n"SetReturnB"));
		return Items;
	}

	/**
	 * WorldStory: BeginPlay fills array/map/set value, in, out, inout, and return shapes.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Inputs none
	 * @Return ArrayValueCount 2, ArrayInCount 2, MapValueCount 2, MapInCount 2, SetReturnContains true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<FStructContainerParamItem> LocalArray;
		LocalArray.Add(MakeItem(1, n"ArrayInitialA"));
		LocalArray.Add(MakeItem(2, n"ArrayInitialB"));
		ArrayValueCount = CountArrayValue(LocalArray);
		ArrayInCount = CountArrayIn(LocalArray);
		FillArrayOut(ArrayOut);
		ArrayInout = LocalArray;
		MutateArrayInout(ArrayInout);
		ArrayReturn = ReturnArray();

		TMap<int, FStructContainerParamItem> LocalMap;
		LocalMap.Add(1, MakeItem(1, n"MapInitialA"));
		LocalMap.Add(2, MakeItem(2, n"MapInitialB"));
		MapValueCount = CountMapValue(LocalMap);
		MapInCount = CountMapIn(LocalMap);
		FillMapOut(MapOut);
		MapInout = LocalMap;
		MutateMapInout(MapInout);
		MapReturn = ReturnMap();

		TSet<FStructContainerParamItem> LocalSet;
		LocalSet.Add(MakeItem(1, n"SetInitialA"));
		LocalSet.Add(MakeItem(2, n"SetInitialB"));
		SetValueCount = CountSetValue(LocalSet);
		SetInCount = CountSetIn(LocalSet);
		FillSetOut(SetOut);
		SetInout = LocalSet;
		MutateSetInout(SetInout);
		SetReturn = ReturnSet();
		SetReturnContains = SetReturn.Contains(MakeItem(34, n"SetReturnB"));
	}

	/**
	 * Observe empty out containers and default counts before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Inputs an actor that has not begun play
	 * @Return true when ArrayOut/MapOut/SetOut are empty, ArrayValueCount 0, SetReturnContains false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool ContainerParamDefaultEmpty()
	{
		if (ArrayOut.Num() != 0)
		{
			return false;
		}
		if (MapOut.Num() != 0)
		{
			return false;
		}
		if (SetOut.Num() != 0)
		{
			return false;
		}
		if (ArrayValueCount != 0)
		{
			return false;
		}
		return !SetReturnContains;
	}

	/**
	 * Observe BeginPlay container counts and mutated first array ID.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Inputs BeginPlay
	 * @Return true when counts are 2, ArrayInout Num 3 ID 13, and SetReturnContains
	 */
	UFUNCTION()
	bool ContainerParamNominalBeginPlay()
	{
		BeginPlay();
		if (ArrayValueCount != 2)
		{
			return false;
		}
		if (ArrayInCount != 2)
		{
			return false;
		}
		if (MapValueCount != 2)
		{
			return false;
		}
		if (MapInCount != 2)
		{
			return false;
		}
		if (SetValueCount != 2)
		{
			return false;
		}
		if (SetInCount != 2)
		{
			return false;
		}
		if (ArrayOut.Num() != 2)
		{
			return false;
		}
		if (ArrayInout.Num() != 3)
		{
			return false;
		}
		if (ArrayInout[0].ID != 13)
		{
			return false;
		}
		if (ArrayReturn.Num() != 2)
		{
			return false;
		}
		if (MapOut.Num() != 2)
		{
			return false;
		}
		if (MapReturn.Num() != 2)
		{
			return false;
		}
		if (SetOut.Num() != 2)
		{
			return false;
		}
		return SetReturnContains;
	}

	/**
	 * Observe empty container value counts.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerParameterShapeMatrix
	 * @Inputs empty array, map, and set
	 * @Return 0
	 * @Boundary empty containers
	 */
	UFUNCTION()
	int ContainerParamEmptyCountBoundary()
	{
		TArray<FStructContainerParamItem> EmptyArray;
		TMap<int, FStructContainerParamItem> EmptyMap;
		TSet<FStructContainerParamItem> EmptySet;
		return CountArrayValue(EmptyArray) + CountMapValue(EmptyMap) + CountSetValue(EmptySet);
	}
}
