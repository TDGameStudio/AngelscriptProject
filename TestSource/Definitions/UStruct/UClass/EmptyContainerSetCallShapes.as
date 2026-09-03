/**
 * Empty USTRUCT TSet call shapes plus BeginPlay fills of array/map/set members.
 * C++ reads EmptySetDeduplicated after BeginPlay. Keep EmptyArray, IntToEmpty,
 * EmptyToInt, EmptyToEmpty, EmptySet, and the Count/Fill/Mutate/Return names.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.EmptyContainerSetCallShapes
 * @Harness UClass
 * @Tag Definitions.UStruct.EmptyContainerSetCallShapes
 * @Provenance Theme: Definitions.UStruct. WorldStory: empty USTRUCT TSet call shapes plus BeginPlay fills.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructEmptyContainerShapeMatrix block 4
 * @Provenance lines 2339-2396;
 * @Provenance sha256=0ef1870faa9300d35bf2220b167ce0858a6b8a99473fc3e177eaf253d5642bf3.
 * @Provenance Oracle after BeginPlay: EmptyArray Num=2, IntToEmpty Num=2, EmptyToInt Num=1 (overwrite),
 * @Provenance EmptyToEmpty Num=1, EmptySet Num=1 (dedup). CountSetValue treats Num==1 as EmptySetDeduplicated.
 * @Provenance Extra: empty TSet Num 0; two Add of equivalent elements collapse to 1.
 * @Provenance FixtureIsolated. Fragment is wrapped so PlannedSymbols compile as a program.
 */

USTRUCT(BlueprintType)
struct FEmptyContainerStruct
{
	/**
	 * Empty structs compare equal.
	 *
	 * @Covers UStruct.EmptyContainerSetCallShapes
	 * @Inputs another FEmptyContainerStruct
	 * @Return true
	 * @Param Other the other instance
	 */
	bool opEquals(const FEmptyContainerStruct&in Other) const
	{
		return true;
	}

	/**
	 * Hash empty structs as the constant 17.
	 *
	 * @Covers UStruct.EmptyContainerSetCallShapes
	 * @Inputs none
	 * @Return 17
	 */
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

	/**
	 * Build a default empty container struct.
	 *
	 * @Covers UStruct.EmptyContainerSetCallShapes
	 * @Inputs none
	 * @Return a default FEmptyContainerStruct
	 */
	FEmptyContainerStruct MakeEmpty()
	{
		FEmptyContainerStruct Item;
		return Item;
	}

	/**
	 * Count a by-value empty-struct set and record Num==1 as EmptySetDeduplicated.
	 *
	 * @Covers UStruct.EmptyContainerSetCallShapes
	 * @Inputs a TSet of FEmptyContainerStruct
	 * @Return Items.Num() stored in SetValueCount
	 * @Param Items the set
	 */
	UFUNCTION(BlueprintCallable)
	int CountSetValue(TSet<FEmptyContainerStruct> Items)
	{
		SetValueCount = Items.Num();
		EmptySetDeduplicated = Items.Num() == 1 && Items.Contains(MakeEmpty());
		return SetValueCount;
	}

	/**
	 * Count a const-in empty-struct set.
	 *
	 * @Covers UStruct.EmptyContainerSetCallShapes
	 * @Inputs a const &in TSet of FEmptyContainerStruct
	 * @Return Items.Num() stored in SetInCount
	 * @Param Items the set
	 */
	UFUNCTION(BlueprintCallable)
	int CountSetIn(const TSet<FEmptyContainerStruct>&in Items)
	{
		SetInCount = Items.Num();
		return SetInCount;
	}

	/**
	 * Fill an out empty-struct set with one item.
	 *
	 * @Covers UStruct.EmptyContainerSetCallShapes
	 * @Inputs an &out TSet of FEmptyContainerStruct
	 * @Return Items containing MakeEmpty
	 * @Param Items the out set
	 */
	UFUNCTION(BlueprintCallable)
	void FillSetOut(TSet<FEmptyContainerStruct>&out Items)
	{
		Items.Add(MakeEmpty());
	}

	/**
	 * Append one empty struct to an inout set.
	 *
	 * @Covers UStruct.EmptyContainerSetCallShapes
	 * @Inputs an &inout TSet of FEmptyContainerStruct
	 * @Return SetInout copied from Items after the add
	 * @Param Items the inout set
	 */
	UFUNCTION(BlueprintCallable)
	void MutateSetInout(TSet<FEmptyContainerStruct>&inout Items)
	{
		Items.Add(MakeEmpty());
		SetInout = Items;
	}

	/**
	 * Return a set containing one empty struct.
	 *
	 * @Covers UStruct.EmptyContainerSetCallShapes
	 * @Inputs none
	 * @Return a TSet with one MakeEmpty entry
	 */
	UFUNCTION(BlueprintCallable)
	TSet<FEmptyContainerStruct> ReturnSet()
	{
		TSet<FEmptyContainerStruct> Items;
		Items.Add(MakeEmpty());
		return Items;
	}

	/**
	 * WorldStory: BeginPlay fills array/map/set members, including empty-key overwrite.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.EmptyContainerSetCallShapes
	 * @Inputs none
	 * @Return EmptyArray Num 2, IntToEmpty Num 2, EmptyToInt Num 1, EmptyToEmpty Num 1, EmptySet Num 1
	 */
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

	/**
	 * Observe that a local empty-struct set has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerSetCallShapes
	 * @Inputs a default TSet of FEmptyContainerStruct
	 * @Return 0
	 * @Boundary empty set
	 */
	UFUNCTION()
	int SetEmptyDefault()
	{
		TSet<FEmptyContainerStruct> Items;
		return Items.Num();
	}

	/**
	 * Observe that two equivalent empty structs collapse to one set element.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerSetCallShapes
	 * @Inputs two Add of the same empty item
	 * @Return true when Num is 1 and Contains succeeds
	 * @Boundary set dedup
	 */
	UFUNCTION()
	bool SetDedupBoundary()
	{
		TSet<FEmptyContainerStruct> Items;
		FEmptyContainerStruct Item;
		Items.Add(Item);
		Items.Add(Item);
		if (Items.Num() != 1)
		{
			return false;
		}
		return Items.Contains(Item);
	}

	/**
	 * Observe two empty-struct array adds.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerSetCallShapes
	 * @Inputs two Add of a default empty struct
	 * @Return 2
	 */
	UFUNCTION()
	int ArrayTwoValueAdds()
	{
		TArray<FEmptyContainerStruct> Items;
		FEmptyContainerStruct Item;
		Items.Add(Item);
		Items.Add(Item);
		return Items.Num();
	}

	/**
	 * Observe that two equivalent empty keys overwrite so Find yields 200.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerSetCallShapes
	 * @Inputs Add 100 then Add 200 with the same empty key
	 * @Return true when Num is 1 and Find yields 200
	 * @Boundary key overwrite
	 */
	UFUNCTION()
	bool MapKeyOverwriteBoundary()
	{
		TMap<FEmptyContainerStruct, int> Items;
		FEmptyContainerStruct Key;
		Items.Add(Key, 100);
		Items.Add(Key, 200);
		int Found = 0;
		if (Items.Num() != 1)
		{
			return false;
		}
		if (!Items.Find(Key, Found))
		{
			return false;
		}
		return Found == 200;
	}
}
