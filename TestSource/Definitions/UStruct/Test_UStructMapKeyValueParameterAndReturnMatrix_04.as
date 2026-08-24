// Theme: Definitions.UStruct. Positive block 4: TMap<FStruct,FName> value/in/out/inout/return.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueParameterAndReturnMatrix lines 12530-12592.
// Isolation=none: complete program wrapping CountStructName*. Oracle: ValueB n"StructNameValueB",
// inout mutates n"StructNameInoutMutated". Extra: empty count 0. DefaultSafe.

USTRUCT(BlueprintType)
struct FMapParamKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FMapParamKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

UCLASS()
class ACoverageStructMapParamMatrixActor : AActor
{
	UPROPERTY()
	int StructNameValueCount = 0;

	UPROPERTY()
	int StructNameInCount = 0;

	UPROPERTY()
	TMap<FMapParamKey, FName> StructNameInout;

	UPROPERTY()
	bool StructNameValuePreserved = false;

	UPROPERTY()
	bool StructNameInPreserved = false;

	UPROPERTY()
	bool StructNameInoutSawOriginal = false;

	UPROPERTY()
	bool StructNameInoutMutated = false;

	UPROPERTY()
	bool StructNameReturnPreserved = false;

	FMapParamKey MakeKey(int ID, FName Tag)
	{
		FMapParamKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructNameValue(TMap<FMapParamKey, FName> Items)
	{
		StructNameValueCount = Items.Num();
		FName Found;
		StructNameValuePreserved =
			Items.Find(MakeKey(401, n"ValueB"), Found)
			&& Found == n"StructNameValueB";
		return StructNameValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructNameIn(const TMap<FMapParamKey, FName>&in Items)
	{
		StructNameInCount = Items.Num();
		FName Found;
		StructNameInPreserved =
			Items.Find(MakeKey(411, n"InB"), Found)
			&& Found == n"StructNameInB";
		return StructNameInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillStructNameOut(TMap<FMapParamKey, FName>&out Items)
	{
		Items.Add(MakeKey(420, n"OutA"), n"StructNameOutA");
		Items.Add(MakeKey(421, n"OutB"), n"StructNameOutB");
	}

	UFUNCTION(BlueprintCallable)
	void MutateStructNameInout(TMap<FMapParamKey, FName>&inout Items)
	{
		FMapParamKey Existing = MakeKey(430, n"InoutA");
		FName Found;
		StructNameInoutSawOriginal =
			Items.Find(Existing, Found)
			&& Found == n"StructNameInoutA";
		Items.Add(Existing, n"StructNameInoutMutated");
		Items.Add(MakeKey(431, n"InoutB"), n"StructNameInoutAdded");
		StructNameInout = Items;

		FName Mutated;
		StructNameInoutMutated =
			Items.Find(Existing, Mutated)
			&& Mutated == n"StructNameInoutMutated";
	}

	UFUNCTION(BlueprintCallable)
	TMap<FMapParamKey, FName> ReturnStructName()
	{
		TMap<FMapParamKey, FName> Items;
		Items.Add(MakeKey(440, n"ReturnA"), n"StructNameReturnA");
		Items.Add(MakeKey(441, n"ReturnB"), n"StructNameReturnB");

		FName Found;
		StructNameReturnPreserved =
			Items.Find(MakeKey(441, n"ReturnB"), Found)
			&& Found == n"StructNameReturnB";
		return Items;
	}
}

bool Observe_StructName_DefaultEmpty(ACoverageStructMapParamMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueParameterAndReturnMatrix_04 setup: required Actor is null");
	}
	TMap<FMapParamKey, FName> Empty;
	return Actor.CountStructNameValue(Empty) == 0 && !Actor.StructNameValuePreserved && Actor.StructNameInout.Num() == 0;
}

bool Observe_StructName_NominalMatrix(ACoverageStructMapParamMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueParameterAndReturnMatrix_04 setup: required Actor is null");
	}
	TMap<FMapParamKey, FName> ValueItems;
	ValueItems.Add(Actor.MakeKey(400, n"ValueA"), n"StructNameValueA");
	ValueItems.Add(Actor.MakeKey(401, n"ValueB"), n"StructNameValueB");
	TMap<FMapParamKey, FName> InItems;
	InItems.Add(Actor.MakeKey(410, n"InA"), n"StructNameInA");
	InItems.Add(Actor.MakeKey(411, n"InB"), n"StructNameInB");
	TMap<FMapParamKey, FName> OutItems;
	Actor.FillStructNameOut(OutItems);
	TMap<FMapParamKey, FName> InoutItems;
	InoutItems.Add(Actor.MakeKey(430, n"InoutA"), n"StructNameInoutA");
	Actor.MutateStructNameInout(InoutItems);
	TMap<FMapParamKey, FName> Returned = Actor.ReturnStructName();
	FName Found;
	return Actor.CountStructNameValue(ValueItems) == 2
		&& Actor.StructNameValuePreserved
		&& Actor.CountStructNameIn(InItems) == 2
		&& Actor.StructNameInPreserved
		&& OutItems.Num() == 2
		&& Actor.StructNameInoutSawOriginal
		&& Actor.StructNameInoutMutated
		&& Actor.StructNameReturnPreserved
		&& Returned.Find(Actor.MakeKey(441, n"ReturnB"), Found)
		&& Found == n"StructNameReturnB";
}

bool Observe_StructName_NoneNameBoundary(ACoverageStructMapParamMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueParameterAndReturnMatrix_04 setup: required Actor is null");
	}
	TMap<FMapParamKey, FName> Items;
	Items.Add(Actor.MakeKey(0, n""), n"");
	FName Found = n"Sentinel";
	return Items.Find(Actor.MakeKey(0, n""), Found) && Found == n"";
}
