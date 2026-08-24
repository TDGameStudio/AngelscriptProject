// Theme: Definitions.UStruct. WorldStory: reflected TArray/TMap/TSet UFUNCTION parameter invocation.
// C++: AngelscriptCoverageUStructTests.cpp::UStructReflectedContainerParameterInvocation.
// Oracle: CountArrayValue 2 with Items[1] ID 11; CountMapValue Find 12; CountSetValue Contains 11.
// Extra: empty containers count 0; Fill*Out writes two entries. FixtureIsolated.

USTRUCT(BlueprintType)
struct FReflectedContainerItem
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FReflectedContainerItem& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

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

	FReflectedContainerItem MakeItem(int ID, FName Tag)
	{
		FReflectedContainerItem Item;
		Item.ID = ID;
		Item.Tag = Tag;
		return Item;
	}

	UFUNCTION(BlueprintCallable)
	int CountArrayValue(TArray<FReflectedContainerItem> Items)
	{
		LastArrayValueCount = Items.Num();
		bArrayValuePreserved = Items.Num() == 2 && Items[1].ID == 11 && Items[1].Tag == n"ArrayValueB";
		return LastArrayValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountArrayIn(const TArray<FReflectedContainerItem>&in Items)
	{
		LastArrayInCount = Items.Num();
		return LastArrayInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillArrayOut(TArray<FReflectedContainerItem>&out Items)
	{
		Items.Add(MakeItem(20, n"ArrayOutA"));
		Items.Add(MakeItem(21, n"ArrayOutB"));
	}

	UFUNCTION(BlueprintCallable)
	void MutateArrayInout(TArray<FReflectedContainerItem>&inout Items)
	{
		FReflectedContainerItem First = Items[0];
		First.ID += 100;
		First.Tag = n"ArrayInoutMutated";
		Items[0] = First;
		Items.Add(MakeItem(22, n"ArrayInoutAdded"));
	}

	UFUNCTION(BlueprintCallable)
	TArray<FReflectedContainerItem> ReturnArray()
	{
		TArray<FReflectedContainerItem> Items;
		Items.Add(MakeItem(23, n"ArrayReturnA"));
		Items.Add(MakeItem(24, n"ArrayReturnB"));
		return Items;
	}

	UFUNCTION(BlueprintCallable)
	int CountMapValue(TMap<int, FReflectedContainerItem> Items)
	{
		LastMapValueCount = Items.Num();
		FReflectedContainerItem Found;
		bMapValuePreserved = Items.Find(12, Found) && Found.ID == 12 && Found.Tag == n"MapValueB";
		return LastMapValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountMapIn(const TMap<int, FReflectedContainerItem>&in Items)
	{
		LastMapInCount = Items.Num();
		return LastMapInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillMapOut(TMap<int, FReflectedContainerItem>&out Items)
	{
		Items.Add(30, MakeItem(30, n"MapOutA"));
		Items.Add(31, MakeItem(31, n"MapOutB"));
	}

	UFUNCTION(BlueprintCallable)
	void MutateMapInout(TMap<int, FReflectedContainerItem>&inout Items)
	{
		Items[10] = MakeItem(110, n"MapInoutMutated");
		Items.Add(32, MakeItem(32, n"MapInoutAdded"));
	}

	UFUNCTION(BlueprintCallable)
	TMap<int, FReflectedContainerItem> ReturnMap()
	{
		TMap<int, FReflectedContainerItem> Items;
		Items.Add(33, MakeItem(33, n"MapReturnA"));
		Items.Add(34, MakeItem(34, n"MapReturnB"));
		return Items;
	}

	UFUNCTION(BlueprintCallable)
	int CountSetValue(TSet<FReflectedContainerItem> Items)
	{
		LastSetValueCount = Items.Num();
		bSetValuePreserved = Items.Contains(MakeItem(11, n"SetValueB"));
		return LastSetValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountSetIn(const TSet<FReflectedContainerItem>&in Items)
	{
		LastSetInCount = Items.Num();
		return LastSetInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillSetOut(TSet<FReflectedContainerItem>&out Items)
	{
		Items.Add(MakeItem(40, n"SetOutA"));
		Items.Add(MakeItem(41, n"SetOutB"));
	}

	UFUNCTION(BlueprintCallable)
	void MutateSetInout(TSet<FReflectedContainerItem>&inout Items)
	{
		Items.Remove(MakeItem(10, n"SetValueA"));
		Items.Add(MakeItem(42, n"SetInoutAdded"));
	}

	UFUNCTION(BlueprintCallable)
	TSet<FReflectedContainerItem> ReturnSet()
	{
		TSet<FReflectedContainerItem> Items;
		Items.Add(MakeItem(43, n"SetReturnA"));
		Items.Add(MakeItem(44, n"SetReturnB"));
		return Items;
	}
}

bool Observe_ReflectedContainer_DefaultEmpty(ACoverageStructReflectedContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructReflectedContainerParameterInvocation setup: required Actor is null");
	}
	TArray<FReflectedContainerItem> EmptyArray;
	TMap<int, FReflectedContainerItem> EmptyMap;
	TSet<FReflectedContainerItem> EmptySet;
	return Actor.CountArrayValue(EmptyArray) == 0
		&& Actor.CountMapValue(EmptyMap) == 0
		&& Actor.CountSetValue(EmptySet) == 0
		&& !Actor.bArrayValuePreserved
		&& !Actor.bMapValuePreserved
		&& !Actor.bSetValuePreserved;
}

bool Observe_ReflectedContainer_NominalCounts(ACoverageStructReflectedContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructReflectedContainerParameterInvocation setup: required Actor is null");
	}
	TArray<FReflectedContainerItem> ArrayItems;
	ArrayItems.Add(Actor.MakeItem(10, n"ArrayValueA"));
	ArrayItems.Add(Actor.MakeItem(11, n"ArrayValueB"));
	TMap<int, FReflectedContainerItem> MapItems;
	MapItems.Add(11, Actor.MakeItem(11, n"MapValueA"));
	MapItems.Add(12, Actor.MakeItem(12, n"MapValueB"));
	TSet<FReflectedContainerItem> SetItems;
	SetItems.Add(Actor.MakeItem(10, n"SetValueA"));
	SetItems.Add(Actor.MakeItem(11, n"SetValueB"));
	return Actor.CountArrayValue(ArrayItems) == 2
		&& Actor.bArrayValuePreserved
		&& Actor.CountArrayIn(ArrayItems) == 2
		&& Actor.CountMapValue(MapItems) == 2
		&& Actor.bMapValuePreserved
		&& Actor.CountSetValue(SetItems) == 2
		&& Actor.bSetValuePreserved;
}

bool Observe_ReflectedContainer_OutAndReturn(ACoverageStructReflectedContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructReflectedContainerParameterInvocation setup: required Actor is null");
	}
	TArray<FReflectedContainerItem> ArrayOut;
	Actor.FillArrayOut(ArrayOut);
	TMap<int, FReflectedContainerItem> MapOut;
	Actor.FillMapOut(MapOut);
	TSet<FReflectedContainerItem> SetOut;
	Actor.FillSetOut(SetOut);
	TArray<FReflectedContainerItem> ArrayReturn = Actor.ReturnArray();
	TMap<int, FReflectedContainerItem> MapReturn = Actor.ReturnMap();
	TSet<FReflectedContainerItem> SetReturn = Actor.ReturnSet();
	return ArrayOut.Num() == 2
		&& MapOut.Num() == 2
		&& SetOut.Num() == 2
		&& ArrayReturn.Num() == 2
		&& ArrayReturn[0].ID == 23
		&& MapReturn.Num() == 2
		&& SetReturn.Contains(Actor.MakeItem(44, n"SetReturnB"));
}
