// Theme: Definitions.UStruct. Positive: empty USTRUCT TArray/TMap<int,FStruct> call shapes.
// C++: AngelscriptCoverageUStructTests.cpp::UStructEmptyContainerShapeMatrix block 2
// lines 2175-2256;
// sha256=5849f07b732abc0fd9815cf2cc2576b892682cce09243b4e544ed36267a552df.
// Oracle: CountArrayValue/CountMapValue return Items.Num(); Fill*Out add two entries;
// Mutate*Inout append one; ReturnArray/ReturnMap contain two entries.
// Extra: empty TArray/TMap Num 0; two MakeEmpty adds are the populated boundary.
// DefaultSafe. Fragment is wrapped so PlannedSymbols compile as a program.

USTRUCT(BlueprintType)
struct FEmptyContainerStruct
{
	bool opEquals(const FEmptyContainerStruct& Other) const
	{
		return true;
	}

	uint32 Hash() const
	{
		return 17;
	}
}

UCLASS()
class ACoverageEmptyStructContainerActor : AActor
{
	UPROPERTY()
	int ArrayValueCount = 0;

	UPROPERTY()
	int ArrayInCount = 0;

	UPROPERTY()
	TArray<FEmptyContainerStruct> ArrayInout;

	UPROPERTY()
	int MapValueCount = 0;

	UPROPERTY()
	int MapInCount = 0;

	UPROPERTY()
	TMap<int, FEmptyContainerStruct> MapInout;

	FEmptyContainerStruct MakeEmpty()
	{
		FEmptyContainerStruct Item;
		return Item;
	}

	UFUNCTION(BlueprintCallable)
	int CountArrayValue(TArray<FEmptyContainerStruct> Items)
	{
		ArrayValueCount = Items.Num();
		return ArrayValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountArrayIn(const TArray<FEmptyContainerStruct>&in Items)
	{
		ArrayInCount = Items.Num();
		return ArrayInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillArrayOut(TArray<FEmptyContainerStruct>&out Items)
	{
		Items.Add(MakeEmpty());
		Items.Add(MakeEmpty());
	}

	UFUNCTION(BlueprintCallable)
	void MutateArrayInout(TArray<FEmptyContainerStruct>&inout Items)
	{
		Items.Add(MakeEmpty());
		ArrayInout = Items;
	}

	UFUNCTION(BlueprintCallable)
	TArray<FEmptyContainerStruct> ReturnArray()
	{
		TArray<FEmptyContainerStruct> Items;
		Items.Add(MakeEmpty());
		Items.Add(MakeEmpty());
		return Items;
	}

	UFUNCTION(BlueprintCallable)
	int CountMapValue(TMap<int, FEmptyContainerStruct> Items)
	{
		MapValueCount = Items.Num();
		return MapValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountMapIn(const TMap<int, FEmptyContainerStruct>&in Items)
	{
		MapInCount = Items.Num();
		return MapInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillMapOut(TMap<int, FEmptyContainerStruct>&out Items)
	{
		Items.Add(10, MakeEmpty());
		Items.Add(11, MakeEmpty());
	}

	UFUNCTION(BlueprintCallable)
	void MutateMapInout(TMap<int, FEmptyContainerStruct>&inout Items)
	{
		Items.Add(12, MakeEmpty());
		MapInout = Items;
	}

	UFUNCTION(BlueprintCallable)
	TMap<int, FEmptyContainerStruct> ReturnMap()
	{
		TMap<int, FEmptyContainerStruct> Items;
		Items.Add(20, MakeEmpty());
		Items.Add(21, MakeEmpty());
		return Items;
	}
}

int Observe_ArrayValue_EmptyDefault()
{
	TArray<FEmptyContainerStruct> Items;
	return Items.Num();
}

int Observe_ArrayValue_TwoItems()
{
	TArray<FEmptyContainerStruct> Items;
	FEmptyContainerStruct Item;
	Items.Add(Item);
	Items.Add(Item);
	return Items.Num();
}

int Observe_MapValue_EmptyDefault()
{
	TMap<int, FEmptyContainerStruct> Items;
	return Items.Num();
}

int Observe_MapValue_TwoItems()
{
	TMap<int, FEmptyContainerStruct> Items;
	FEmptyContainerStruct Item;
	Items.Add(20, Item);
	Items.Add(21, Item);
	return Items.Num();
}

bool Observe_Array_CopyIndependence()
{
	TArray<FEmptyContainerStruct> Original;
	FEmptyContainerStruct Item;
	Original.Add(Item);
	TArray<FEmptyContainerStruct> Copy = Original;
	Copy.Add(Item);
	return Original.Num() == 1 && Copy.Num() == 2;
}
