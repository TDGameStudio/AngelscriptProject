// Theme: Definitions.UStruct. WorldStory: empty USTRUCT TSet call shapes plus BeginPlay fills.
// C++: AngelscriptCoverageUStructTests.cpp::UStructEmptyContainerShapeMatrix block 4
// lines 2339-2396;
// sha256=0ef1870faa9300d35bf2220b167ce0858a6b8a99473fc3e177eaf253d5642bf3.
// Oracle after BeginPlay: EmptyArray Num=2, IntToEmpty Num=2, EmptyToInt Num=1 (overwrite),
// EmptyToEmpty Num=1, EmptySet Num=1 (dedup). CountSetValue treats Num==1 as EmptySetDeduplicated.
// Extra: empty TSet Num 0; two Add of equivalent elements collapse to 1.
// FixtureIsolated. Fragment is wrapped so PlannedSymbols compile as a program.

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
	TArray<FEmptyContainerStruct> EmptyArray;

	UPROPERTY()
	TMap<int, FEmptyContainerStruct> IntToEmpty;

	UPROPERTY()
	TMap<FEmptyContainerStruct, int> EmptyToInt;

	UPROPERTY()
	TMap<FEmptyContainerStruct, FEmptyContainerStruct> EmptyToEmpty;

	UPROPERTY()
	TSet<FEmptyContainerStruct> EmptySet;

	UPROPERTY()
	int SetValueCount = 0;

	UPROPERTY()
	int SetInCount = 0;

	UPROPERTY()
	TSet<FEmptyContainerStruct> SetInout;

	UPROPERTY()
	bool EmptySetDeduplicated = false;

	FEmptyContainerStruct MakeEmpty()
	{
		FEmptyContainerStruct Item;
		return Item;
	}

	UFUNCTION(BlueprintCallable)
	int CountSetValue(TSet<FEmptyContainerStruct> Items)
	{
		SetValueCount = Items.Num();
		EmptySetDeduplicated = Items.Num() == 1 && Items.Contains(MakeEmpty());
		return SetValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountSetIn(const TSet<FEmptyContainerStruct>&in Items)
	{
		SetInCount = Items.Num();
		return SetInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillSetOut(TSet<FEmptyContainerStruct>&out Items)
	{
		Items.Add(MakeEmpty());
	}

	UFUNCTION(BlueprintCallable)
	void MutateSetInout(TSet<FEmptyContainerStruct>&inout Items)
	{
		Items.Add(MakeEmpty());
		SetInout = Items;
	}

	UFUNCTION(BlueprintCallable)
	TSet<FEmptyContainerStruct> ReturnSet()
	{
		TSet<FEmptyContainerStruct> Items;
		Items.Add(MakeEmpty());
		return Items;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EmptyArray.Add(MakeEmpty());
		EmptyArray.Add(MakeEmpty());

		IntToEmpty.Add(1, MakeEmpty());
		IntToEmpty.Add(2, MakeEmpty());

		EmptyToInt.Add(MakeEmpty(), 100);
		EmptyToInt.Add(MakeEmpty(), 200);

		EmptyToEmpty.Add(MakeEmpty(), MakeEmpty());
		EmptyToEmpty.Add(MakeEmpty(), MakeEmpty());

		EmptySet.Add(MakeEmpty());
		EmptySet.Add(MakeEmpty());
	}
}

int Observe_Set_EmptyDefault()
{
	TSet<FEmptyContainerStruct> Items;
	return Items.Num();
}

bool Observe_Set_DedupBoundary()
{
	TSet<FEmptyContainerStruct> Items;
	FEmptyContainerStruct Item;
	Items.Add(Item);
	Items.Add(Item);
	return Items.Num() == 1 && Items.Contains(Item);
}

int Observe_Array_TwoValueAdds()
{
	TArray<FEmptyContainerStruct> Items;
	FEmptyContainerStruct Item;
	Items.Add(Item);
	Items.Add(Item);
	return Items.Num();
}

bool Observe_MapKey_OverwriteBoundary()
{
	TMap<FEmptyContainerStruct, int> Items;
	FEmptyContainerStruct Key;
	Items.Add(Key, 100);
	Items.Add(Key, 200);
	int Found = 0;
	return Items.Num() == 1 && Items.Find(Key, Found) && Found == 200;
}
