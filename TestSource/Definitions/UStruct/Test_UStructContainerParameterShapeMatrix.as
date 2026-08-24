// Theme: Definitions.UStruct. WorldStory: TArray/TMap/TSet of USTRUCT as value/in/out/inout/return.
// C++: AngelscriptCoverageUStructTests.cpp::UStructContainerParameterShapeMatrix spawn + BeginPlay.
// Oracle: ArrayValueCount 2, ArrayInCount 2, MapValueCount 2, MapInCount 2, SetReturnContains true.
// Extra: empty out/inout/return containers before BeginPlay. FixtureIsolated.

USTRUCT(BlueprintType)
struct FStructContainerParamItem
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FStructContainerParamItem& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

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

	FStructContainerParamItem MakeItem(int ID, FName Tag)
	{
		FStructContainerParamItem Item;
		Item.ID = ID;
		Item.Tag = Tag;
		return Item;
	}

	int CountArrayValue(TArray<FStructContainerParamItem> Items)
	{
		return Items.Num();
	}

	int CountArrayIn(const TArray<FStructContainerParamItem>&in Items)
	{
		return Items.Num();
	}

	void FillArrayOut(TArray<FStructContainerParamItem>&out Items)
	{
		Items.Add(MakeItem(10, n"ArrayOutA"));
		Items.Add(MakeItem(11, n"ArrayOutB"));
	}

	void MutateArrayInout(TArray<FStructContainerParamItem>&inout Items)
	{
		Items.Add(MakeItem(12, n"ArrayInoutAdded"));
		FStructContainerParamItem First = Items[0];
		First.ID = 13;
		Items[0] = First;
	}

	TArray<FStructContainerParamItem> ReturnArray()
	{
		TArray<FStructContainerParamItem> Items;
		Items.Add(MakeItem(14, n"ArrayReturnA"));
		Items.Add(MakeItem(15, n"ArrayReturnB"));
		return Items;
	}

	int CountMapValue(TMap<int, FStructContainerParamItem> Items)
	{
		return Items.Num();
	}

	int CountMapIn(const TMap<int, FStructContainerParamItem>&in Items)
	{
		return Items.Num();
	}

	void FillMapOut(TMap<int, FStructContainerParamItem>&out Items)
	{
		Items.Add(20, MakeItem(20, n"MapOutA"));
		Items.Add(21, MakeItem(21, n"MapOutB"));
	}

	void MutateMapInout(TMap<int, FStructContainerParamItem>&inout Items)
	{
		Items.Add(22, MakeItem(22, n"MapInoutAdded"));
		Items[1] = MakeItem(23, n"MapInoutReplaced");
	}

	TMap<int, FStructContainerParamItem> ReturnMap()
	{
		TMap<int, FStructContainerParamItem> Items;
		Items.Add(24, MakeItem(24, n"MapReturnA"));
		Items.Add(25, MakeItem(25, n"MapReturnB"));
		return Items;
	}

	int CountSetValue(TSet<FStructContainerParamItem> Items)
	{
		return Items.Num();
	}

	int CountSetIn(const TSet<FStructContainerParamItem>&in Items)
	{
		return Items.Num();
	}

	void FillSetOut(TSet<FStructContainerParamItem>&out Items)
	{
		Items.Add(MakeItem(30, n"SetOutA"));
		Items.Add(MakeItem(31, n"SetOutB"));
	}

	void MutateSetInout(TSet<FStructContainerParamItem>&inout Items)
	{
		Items.Add(MakeItem(32, n"SetInoutAdded"));
		Items.Remove(MakeItem(2, n"SetInitialB"));
	}

	TSet<FStructContainerParamItem> ReturnSet()
	{
		TSet<FStructContainerParamItem> Items;
		Items.Add(MakeItem(33, n"SetReturnA"));
		Items.Add(MakeItem(34, n"SetReturnB"));
		return Items;
	}

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
}

bool Observe_ContainerParam_DefaultEmpty(ACoverageStructContainerParamActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructContainerParameterShapeMatrix setup: required Actor is null");
	}
	return Actor.ArrayOut.Num() == 0
		&& Actor.MapOut.Num() == 0
		&& Actor.SetOut.Num() == 0
		&& Actor.ArrayValueCount == 0
		&& !Actor.SetReturnContains;
}

bool Observe_ContainerParam_NominalBeginPlay(ACoverageStructContainerParamActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructContainerParameterShapeMatrix setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.ArrayValueCount == 2
		&& Actor.ArrayInCount == 2
		&& Actor.MapValueCount == 2
		&& Actor.MapInCount == 2
		&& Actor.SetValueCount == 2
		&& Actor.SetInCount == 2
		&& Actor.ArrayOut.Num() == 2
		&& Actor.ArrayInout.Num() == 3
		&& Actor.ArrayInout[0].ID == 13
		&& Actor.ArrayReturn.Num() == 2
		&& Actor.MapOut.Num() == 2
		&& Actor.MapReturn.Num() == 2
		&& Actor.SetOut.Num() == 2
		&& Actor.SetReturnContains;
}

int Observe_ContainerParam_EmptyCountBoundary(ACoverageStructContainerParamActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructContainerParameterShapeMatrix setup: required Actor is null");
	}
	TArray<FStructContainerParamItem> EmptyArray;
	TMap<int, FStructContainerParamItem> EmptyMap;
	TSet<FStructContainerParamItem> EmptySet;
	return Actor.CountArrayValue(EmptyArray) + Actor.CountMapValue(EmptyMap) + Actor.CountSetValue(EmptySet);
}
