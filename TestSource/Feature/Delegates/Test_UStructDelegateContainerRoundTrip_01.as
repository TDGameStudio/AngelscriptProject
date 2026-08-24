// Theme: Feature.Delegates. Positive block 1: hashable USTRUCT plus array/map delegate types.
// C++: AngelscriptCoverageUStructTests.cpp::UStructDelegateContainerRoundTrip lines 5643-5675.
// Isolation=none: this file is a complete program. Oracle: default ID 0; Hash(0)+empty Tag.
// Extra: empty TArray/TMap Num 0; copy independence of ID/Tag. DefaultSafe.

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

delegate int FStructArrayValueSignal(TArray<FDelegateContainerStruct> Items);
delegate int FStructArrayInSignal(const TArray<FDelegateContainerStruct>&in Items);
delegate void FStructArrayOutSignal(TArray<FDelegateContainerStruct>&out Items);
delegate int FStructArrayInoutSignal(TArray<FDelegateContainerStruct>&inout Items);
delegate TArray<FDelegateContainerStruct> FStructArrayReturnSignal();

delegate int FStructMapValueSignal(TMap<int, FDelegateContainerStruct> Items);
delegate int FStructMapInSignal(const TMap<int, FDelegateContainerStruct>&in Items);
delegate void FStructMapOutSignal(TMap<int, FDelegateContainerStruct>&out Items);
delegate int FStructMapInoutSignal(TMap<int, FDelegateContainerStruct>&inout Items);
delegate TMap<int, FDelegateContainerStruct> FStructMapReturnSignal();

int Observe_Item_DefaultZero()
{
	FDelegateContainerStruct Item;
	return Item.ID;
}

uint32 Observe_Item_DefaultHash()
{
	FDelegateContainerStruct Item;
	return Item.Hash();
}

int Observe_EmptyArray_DefaultNum()
{
	TArray<FDelegateContainerStruct> Items;
	return Items.Num();
}

bool Observe_Item_CopyIndependence()
{
	FDelegateContainerStruct Original;
	Original.ID = 11;
	Original.Tag = n"ArrayValueB";
	FDelegateContainerStruct Copy = Original;
	Copy.ID = 0;
	Copy.Tag = n"";
	return Original.ID == 11 && Original.Tag == n"ArrayValueB" && Copy.ID == 0;
}
