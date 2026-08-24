// Theme: Definitions.UStruct. Positive: empty USTRUCT as TMap key and struct-to-struct map.
// C++: AngelscriptCoverageUStructTests.cpp::UStructEmptyContainerShapeMatrix block 3
// lines 2257-2338;
// sha256=baeac903ad1cd68f94d4f58d004c75be4e04b5ee1baa84f68ff3e060c3d47b81.
// Oracle: empty keys overwrite so Num is 1; Find(MakeEmpty()) succeeds.
// Extra: empty TMap Num 0; two Add of equivalent keys collapse to 1.
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

	FEmptyContainerStruct MakeEmpty()
	{
		FEmptyContainerStruct Item;
		return Item;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructKeyMapValue(TMap<FEmptyContainerStruct, int> Items)
	{
		StructKeyMapValueCount = Items.Num();
		int Found = 0;
		EmptyKeyMapOverwrote = Items.Find(MakeEmpty(), Found) && Found == 200;
		return StructKeyMapValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructKeyMapIn(const TMap<FEmptyContainerStruct, int>&in Items)
	{
		StructKeyMapInCount = Items.Num();
		int Found = 0;
		EmptyKeyMapInFound = Items.Find(MakeEmpty(), Found) && Found == 220;
		return StructKeyMapInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillStructKeyMapOut(TMap<FEmptyContainerStruct, int>&out Items)
	{
		Items.Add(MakeEmpty(), 500);
		StructKeyMapOut = Items;
	}

	UFUNCTION(BlueprintCallable)
	void MutateStructKeyMapInout(TMap<FEmptyContainerStruct, int>&inout Items)
	{
		Items.Add(MakeEmpty(), 300);
		StructKeyMapInout = Items;
	}

	UFUNCTION(BlueprintCallable)
	TMap<FEmptyContainerStruct, int> ReturnStructKeyMap()
	{
		TMap<FEmptyContainerStruct, int> Items;
		Items.Add(MakeEmpty(), 400);
		return Items;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructStructMapValue(TMap<FEmptyContainerStruct, FEmptyContainerStruct> Items)
	{
		StructStructMapValueCount = Items.Num();
		FEmptyContainerStruct Found;
		EmptyStructStructMapFound = Items.Find(MakeEmpty(), Found);
		return StructStructMapValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructStructMapIn(const TMap<FEmptyContainerStruct, FEmptyContainerStruct>&in Items)
	{
		StructStructMapInCount = Items.Num();
		FEmptyContainerStruct Found;
		EmptyStructStructMapInFound = Items.Find(MakeEmpty(), Found);
		return StructStructMapInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillStructStructMapOut(TMap<FEmptyContainerStruct, FEmptyContainerStruct>&out Items)
	{
		Items.Add(MakeEmpty(), MakeEmpty());
		StructStructMapOut = Items;
	}

	UFUNCTION(BlueprintCallable)
	void MutateStructStructMapInout(TMap<FEmptyContainerStruct, FEmptyContainerStruct>&inout Items)
	{
		Items.Add(MakeEmpty(), MakeEmpty());
		StructStructMapInout = Items;
	}

	UFUNCTION(BlueprintCallable)
	TMap<FEmptyContainerStruct, FEmptyContainerStruct> ReturnStructStructMap()
	{
		TMap<FEmptyContainerStruct, FEmptyContainerStruct> Items;
		Items.Add(MakeEmpty(), MakeEmpty());
		return Items;
	}
}

int Observe_StructKeyMap_EmptyDefault()
{
	TMap<FEmptyContainerStruct, int> Items;
	return Items.Num();
}

int Observe_StructKeyMap_OverwriteBoundary()
{
	TMap<FEmptyContainerStruct, int> Items;
	FEmptyContainerStruct Key;
	Items.Add(Key, 100);
	Items.Add(Key, 200);
	int Found = 0;
	bool bFound = Items.Find(Key, Found) && Found == 200;
	return (Items.Num() == 1 && bFound) ? 1 : 0;
}

int Observe_StructStructMap_EmptyDefault()
{
	TMap<FEmptyContainerStruct, FEmptyContainerStruct> Items;
	return Items.Num();
}

bool Observe_StructStructMap_FindBoundary()
{
	TMap<FEmptyContainerStruct, FEmptyContainerStruct> Items;
	FEmptyContainerStruct Key;
	Items.Add(Key, Key);
	FEmptyContainerStruct Found;
	return Items.Find(Key, Found) && Items.Num() == 1;
}
