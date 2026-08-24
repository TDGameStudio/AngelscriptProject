// Theme: Feature.Delegates. Positive block 5: struct-map and set handler round-trips.
// C++: AngelscriptCoverageUStructTests.cpp::UStructDelegateContainerRoundTrip lines 6050-6143.
// Isolation=none: wrap HandleStructMap* / HandleSet* with FDelegateContainerStruct and flags.
// Oracle: HandleStructMapValue preserves ID 161; HandleSetValue Contains SetValueB.
// Extra: empty TMap/TSet Num 0; zero-ID key miss. DefaultSafe.

USTRUCT(BlueprintType)
struct FDelegateContainerStruct
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FDelegateContainerStruct& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

UCLASS()
class ACoverageStructDelegateContainerActor : AActor
{
	UPROPERTY()
	bool bStructMapValuePreserved = false;

	UPROPERTY()
	bool bStructMapInPreserved = false;

	UPROPERTY()
	bool bStructMapInoutPreserved = false;

	UPROPERTY()
	bool bSetValuePreserved = false;

	UPROPERTY()
	bool bSetInPreserved = false;

	FDelegateContainerStruct MakeItem(int ID, FName Tag)
	{
		FDelegateContainerStruct Item;
		Item.ID = ID;
		Item.Tag = Tag;
		return Item;
	}

	UFUNCTION()
	int HandleStructMapValue(TMap<FDelegateContainerStruct, FDelegateContainerStruct> Items)
	{
		FDelegateContainerStruct Found;
		bStructMapValuePreserved =
			Items.Find(MakeItem(61, n"StructMapValueKeyB"), Found)
			&& Found.ID == 161
			&& Found.Tag == n"StructMapValueValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleStructMapIn(const TMap<FDelegateContainerStruct, FDelegateContainerStruct>&in Items)
	{
		FDelegateContainerStruct Found;
		bStructMapInPreserved =
			Items.Find(MakeItem(62, n"StructMapInKeyA"), Found)
			&& Found.ID == 162
			&& Found.Tag == n"StructMapInValueA";
		return Items.Num() + 60;
	}

	UFUNCTION()
	void HandleStructMapOut(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&out Items)
	{
		Items.Add(MakeItem(70, n"StructMapOutKeyA"), MakeItem(170, n"StructMapOutValueA"));
		Items.Add(MakeItem(71, n"StructMapOutKeyB"), MakeItem(171, n"StructMapOutValueB"));
	}

	UFUNCTION()
	int HandleStructMapInout(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&inout Items)
	{
		FDelegateContainerStruct Existing = MakeItem(72, n"StructMapInoutKeyA");
		Items.Remove(Existing);
		Items.Add(Existing, MakeItem(272, n"StructMapInoutMutated"));
		Items.Add(MakeItem(73, n"StructMapInoutKeyB"), MakeItem(173, n"StructMapInoutAdded"));

		FDelegateContainerStruct Found;
		bStructMapInoutPreserved =
			Items.Find(Existing, Found)
			&& Found.ID == 272
			&& Found.Tag == n"StructMapInoutMutated";
		return Items.Num() + Found.ID;
	}

	UFUNCTION()
	TMap<FDelegateContainerStruct, FDelegateContainerStruct> HandleStructMapReturn()
	{
		TMap<FDelegateContainerStruct, FDelegateContainerStruct> Items;
		Items.Add(MakeItem(74, n"StructMapReturnKeyA"), MakeItem(174, n"StructMapReturnValueA"));
		Items.Add(MakeItem(75, n"StructMapReturnKeyB"), MakeItem(175, n"StructMapReturnValueB"));
		return Items;
	}

	UFUNCTION()
	int HandleSetValue(TSet<FDelegateContainerStruct> Items)
	{
		bSetValuePreserved = Items.Contains(MakeItem(11, n"SetValueB"));
		return Items.Num();
	}

	UFUNCTION()
	int HandleSetIn(const TSet<FDelegateContainerStruct>&in Items)
	{
		bSetInPreserved = Items.Contains(MakeItem(12, n"SetInA"));
		return Items.Num() + 30;
	}

	UFUNCTION()
	void HandleSetOut(TSet<FDelegateContainerStruct>&out Items)
	{
		Items.Add(MakeItem(20, n"SetOutA"));
		Items.Add(MakeItem(21, n"SetOutB"));
	}

	UFUNCTION()
	int HandleSetInout(TSet<FDelegateContainerStruct>&inout Items)
	{
		Items.Remove(MakeItem(10, n"SetInoutA"));
		Items.Add(MakeItem(22, n"SetInoutAdded"));
		return Items.Num() + 40;
	}

	UFUNCTION()
	TSet<FDelegateContainerStruct> HandleSetReturn()
	{
		TSet<FDelegateContainerStruct> Items;
		Items.Add(MakeItem(30, n"SetReturnA"));
		Items.Add(MakeItem(31, n"SetReturnB"));
		return Items;
	}
}

int Observe_EmptyMap_DefaultNum()
{
	TMap<FDelegateContainerStruct, FDelegateContainerStruct> Items;
	return Items.Num();
}

int Observe_EmptySet_DefaultNum()
{
	TSet<FDelegateContainerStruct> Items;
	return Items.Num();
}

bool Observe_ZeroKey_MissingBoundary()
{
	TMap<FDelegateContainerStruct, int> Items;
	FDelegateContainerStruct Zero;
	int Found = 0;
	return !Items.Find(Zero, Found) && Found == 0;
}
