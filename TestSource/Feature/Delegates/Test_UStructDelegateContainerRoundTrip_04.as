// Theme: Feature.Delegates. Positive block 4: array/map/key-map handler round-trips.
// C++: AngelscriptCoverageUStructTests.cpp::UStructDelegateContainerRoundTrip lines 5914-6049.
// Isolation=none: wrap MakeItem and handlers with FDelegateContainerStruct and the flags
// those handlers write. Oracle: HandleArrayValue Num 2 preserves ID 11; HandleArrayIn 12.
// Extra: empty array Num 0; zero-ID item Hash 0+Tag. DefaultSafe.

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
	bool bArrayValuePreserved = false;

	UPROPERTY()
	bool bArrayInPreserved = false;

	UPROPERTY()
	bool bMapValuePreserved = false;

	UPROPERTY()
	bool bMapInPreserved = false;

	UPROPERTY()
	bool bKeyMapValuePreserved = false;

	UPROPERTY()
	bool bKeyMapInPreserved = false;

	UPROPERTY()
	bool bKeyMapInoutPreserved = false;

	FDelegateContainerStruct MakeItem(int ID, FName Tag)
	{
		FDelegateContainerStruct Item;
		Item.ID = ID;
		Item.Tag = Tag;
		return Item;
	}

	UFUNCTION()
	int HandleArrayValue(TArray<FDelegateContainerStruct> Items)
	{
		bArrayValuePreserved = Items.Num() == 2 && Items[1].ID == 11 && Items[1].Tag == n"ArrayValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleArrayIn(const TArray<FDelegateContainerStruct>&in Items)
	{
		bArrayInPreserved = Items.Num() == 2 && Items[0].ID == 12 && Items[0].Tag == n"ArrayInA";
		return Items.Num() + 10;
	}

	UFUNCTION()
	void HandleArrayOut(TArray<FDelegateContainerStruct>&out Items)
	{
		Items.Add(MakeItem(20, n"ArrayOutA"));
		Items.Add(MakeItem(21, n"ArrayOutB"));
	}

	UFUNCTION()
	int HandleArrayInout(TArray<FDelegateContainerStruct>&inout Items)
	{
		FDelegateContainerStruct First = Items[0];
		First.ID += 100;
		First.Tag = n"ArrayInoutMutated";
		Items[0] = First;
		Items.Add(MakeItem(22, n"ArrayInoutAdded"));
		return Items.Num() + Items[0].ID;
	}

	UFUNCTION()
	TArray<FDelegateContainerStruct> HandleArrayReturn()
	{
		TArray<FDelegateContainerStruct> Items;
		Items.Add(MakeItem(30, n"ArrayReturnA"));
		Items.Add(MakeItem(31, n"ArrayReturnB"));
		return Items;
	}

	UFUNCTION()
	int HandleMapValue(TMap<int, FDelegateContainerStruct> Items)
	{
		FDelegateContainerStruct Found;
		bMapValuePreserved = Items.Find(11, Found) && Found.ID == 11 && Found.Tag == n"MapValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleMapIn(const TMap<int, FDelegateContainerStruct>&in Items)
	{
		FDelegateContainerStruct Found;
		bMapInPreserved = Items.Find(12, Found) && Found.ID == 12 && Found.Tag == n"MapInA";
		return Items.Num() + 20;
	}

	UFUNCTION()
	void HandleMapOut(TMap<int, FDelegateContainerStruct>&out Items)
	{
		Items.Add(20, MakeItem(20, n"MapOutA"));
		Items.Add(21, MakeItem(21, n"MapOutB"));
	}

	UFUNCTION()
	int HandleMapInout(TMap<int, FDelegateContainerStruct>&inout Items)
	{
		Items[10] = MakeItem(110, n"MapInoutMutated");
		Items.Add(22, MakeItem(22, n"MapInoutAdded"));
		return Items.Num() + Items[10].ID;
	}

	UFUNCTION()
	TMap<int, FDelegateContainerStruct> HandleMapReturn()
	{
		TMap<int, FDelegateContainerStruct> Items;
		Items.Add(30, MakeItem(30, n"MapReturnA"));
		Items.Add(31, MakeItem(31, n"MapReturnB"));
		return Items;
	}

	UFUNCTION()
	int HandleKeyMapValue(TMap<FDelegateContainerStruct, int> Items)
	{
		int Found = 0;
		bKeyMapValuePreserved = Items.Find(MakeItem(41, n"KeyMapValueB"), Found) && Found == 141;
		return Items.Num();
	}

	UFUNCTION()
	int HandleKeyMapIn(const TMap<FDelegateContainerStruct, int>&in Items)
	{
		int Found = 0;
		bKeyMapInPreserved = Items.Find(MakeItem(42, n"KeyMapInA"), Found) && Found == 142;
		return Items.Num() + 40;
	}

	UFUNCTION()
	void HandleKeyMapOut(TMap<FDelegateContainerStruct, int>&out Items)
	{
		Items.Add(MakeItem(50, n"KeyMapOutA"), 150);
		Items.Add(MakeItem(51, n"KeyMapOutB"), 151);
	}

	UFUNCTION()
	int HandleKeyMapInout(TMap<FDelegateContainerStruct, int>&inout Items)
	{
		FDelegateContainerStruct Existing = MakeItem(52, n"KeyMapInoutA");
		Items.Remove(Existing);
		Items.Add(Existing, 252);
		Items.Add(MakeItem(53, n"KeyMapInoutB"), 153);

		int Found = 0;
		bKeyMapInoutPreserved = Items.Find(Existing, Found) && Found == 252;
		return Items.Num() + Found;
	}

	UFUNCTION()
	TMap<FDelegateContainerStruct, int> HandleKeyMapReturn()
	{
		TMap<FDelegateContainerStruct, int> Items;
		Items.Add(MakeItem(54, n"KeyMapReturnA"), 154);
		Items.Add(MakeItem(55, n"KeyMapReturnB"), 155);
		return Items;
	}
}

int Observe_EmptyArray_DefaultNum()
{
	TArray<FDelegateContainerStruct> Items;
	return Items.Num();
}

int Observe_MakeItem_ZeroBoundary(ACoverageStructDelegateContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructDelegateContainerRoundTrip_04 setup: required Actor is null");
	}
	FDelegateContainerStruct Item = Actor.MakeItem(0, n"");
	return Item.ID;
}

bool Observe_Item_CopyIndependence()
{
	FDelegateContainerStruct Original;
	Original.ID = 11;
	Original.Tag = n"ArrayValueB";
	FDelegateContainerStruct Copy = Original;
	Copy.ID = 0;
	return Original.ID == 11 && Copy.ID == 0;
}
