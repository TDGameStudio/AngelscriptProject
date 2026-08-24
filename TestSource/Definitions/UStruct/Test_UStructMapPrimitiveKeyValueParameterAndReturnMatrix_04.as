// Theme: Definitions.UStruct. Positive block 4: TMap<FStruct,bool> value/in/out/inout/return.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapPrimitiveKeyValueParameterAndReturnMatrix lines 13954-14016.
// Isolation=none: complete program wrapping CountStructBool*. Oracle: ValueFalse finds !Found;
// InTrue finds true; inout mutates true to false. Extra: empty count 0. DefaultSafe.

USTRUCT(BlueprintType)
struct FMapPrimitiveKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FMapPrimitiveKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

UCLASS()
class ACoverageStructMapPrimitiveMatrixActor : AActor
{
	UPROPERTY()
	int StructBoolValueCount = 0;

	UPROPERTY()
	int StructBoolInCount = 0;

	UPROPERTY()
	TMap<FMapPrimitiveKey, bool> StructBoolInout;

	UPROPERTY()
	bool StructBoolValuePreserved = false;

	UPROPERTY()
	bool StructBoolInPreserved = false;

	UPROPERTY()
	bool StructBoolInoutSawOriginal = false;

	UPROPERTY()
	bool StructBoolInoutMutated = false;

	UPROPERTY()
	bool StructBoolReturnPreserved = false;

	FMapPrimitiveKey MakeKey(int ID, FName Tag)
	{
		FMapPrimitiveKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructBoolValue(TMap<FMapPrimitiveKey, bool> Items)
	{
		StructBoolValueCount = Items.Num();
		bool Found = true;
		StructBoolValuePreserved =
			Items.Find(MakeKey(301, n"ValueFalse"), Found)
			&& !Found;
		return StructBoolValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructBoolIn(const TMap<FMapPrimitiveKey, bool>&in Items)
	{
		StructBoolInCount = Items.Num();
		bool Found = false;
		StructBoolInPreserved =
			Items.Find(MakeKey(310, n"InTrue"), Found)
			&& Found;
		return StructBoolInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillStructBoolOut(TMap<FMapPrimitiveKey, bool>&out Items)
	{
		Items.Add(MakeKey(320, n"OutTrue"), true);
		Items.Add(MakeKey(321, n"OutFalse"), false);
	}

	UFUNCTION(BlueprintCallable)
	void MutateStructBoolInout(TMap<FMapPrimitiveKey, bool>&inout Items)
	{
		FMapPrimitiveKey Existing = MakeKey(330, n"InoutTrue");
		bool Found = false;
		StructBoolInoutSawOriginal =
			Items.Find(Existing, Found)
			&& Found;
		Items.Add(Existing, false);
		Items.Add(MakeKey(331, n"InoutAdded"), true);
		StructBoolInout = Items;

		bool Mutated = true;
		StructBoolInoutMutated =
			Items.Find(Existing, Mutated)
			&& !Mutated;
	}

	UFUNCTION(BlueprintCallable)
	TMap<FMapPrimitiveKey, bool> ReturnStructBool()
	{
		TMap<FMapPrimitiveKey, bool> Items;
		Items.Add(MakeKey(340, n"ReturnTrue"), true);
		Items.Add(MakeKey(341, n"ReturnFalse"), false);

		bool Found = true;
		StructBoolReturnPreserved =
			Items.Find(MakeKey(341, n"ReturnFalse"), Found)
			&& !Found;
		return Items;
	}
}

bool Observe_StructBool_DefaultEmpty(ACoverageStructMapPrimitiveMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapPrimitiveKeyValueParameterAndReturnMatrix_04 setup: required Actor is null");
	}
	TMap<FMapPrimitiveKey, bool> Empty;
	return Actor.CountStructBoolValue(Empty) == 0 && !Actor.StructBoolValuePreserved && Actor.StructBoolInout.Num() == 0;
}

bool Observe_StructBool_NominalMatrix(ACoverageStructMapPrimitiveMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapPrimitiveKeyValueParameterAndReturnMatrix_04 setup: required Actor is null");
	}
	TMap<FMapPrimitiveKey, bool> ValueItems;
	ValueItems.Add(Actor.MakeKey(300, n"ValueTrue"), true);
	ValueItems.Add(Actor.MakeKey(301, n"ValueFalse"), false);
	TMap<FMapPrimitiveKey, bool> InItems;
	InItems.Add(Actor.MakeKey(310, n"InTrue"), true);
	TMap<FMapPrimitiveKey, bool> OutItems;
	Actor.FillStructBoolOut(OutItems);
	TMap<FMapPrimitiveKey, bool> InoutItems;
	InoutItems.Add(Actor.MakeKey(330, n"InoutTrue"), true);
	Actor.MutateStructBoolInout(InoutItems);
	TMap<FMapPrimitiveKey, bool> Returned = Actor.ReturnStructBool();
	bool Found = true;
	return Actor.CountStructBoolValue(ValueItems) == 2
		&& Actor.StructBoolValuePreserved
		&& Actor.CountStructBoolIn(InItems) == 1
		&& Actor.StructBoolInPreserved
		&& OutItems.Num() == 2
		&& Actor.StructBoolInoutSawOriginal
		&& Actor.StructBoolInoutMutated
		&& Actor.StructBoolReturnPreserved
		&& Returned.Find(Actor.MakeKey(341, n"ReturnFalse"), Found)
		&& !Found;
}

bool Observe_StructBool_FalseValueBoundary(ACoverageStructMapPrimitiveMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapPrimitiveKeyValueParameterAndReturnMatrix_04 setup: required Actor is null");
	}
	TMap<FMapPrimitiveKey, bool> Items;
	Items.Add(Actor.MakeKey(301, n"ValueFalse"), false);
	return Actor.CountStructBoolValue(Items) == 1 && Actor.StructBoolValuePreserved;
}
