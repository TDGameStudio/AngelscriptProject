// Theme: Definitions.UStruct. WorldStory: TMap<FStruct,FStruct> value/in/out/inout/return.
// C++: AngelscriptCoverageUStructTests.cpp::UStructStructToStructMapParameterAndReturnMatrix.
// Oracle: Count value preserves Score 111 Label ValueB; inout mutates 430/InoutMutated; return 441/ReturnB.
// Extra: empty map count 0. FixtureIsolated.

USTRUCT(BlueprintType)
struct FStructToStructMapKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FStructToStructMapKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 941) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FStructToStructMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructToStructMapMatrixActor : AActor
{
	UPROPERTY()
	int StructStructMapValueCount = 0;

	UPROPERTY()
	int StructStructMapInCount = 0;

	UPROPERTY()
	TMap<FStructToStructMapKey, FStructToStructMapValue> StructStructMapInout;

	UPROPERTY()
	bool StructStructMapValuePreserved = false;

	UPROPERTY()
	bool StructStructMapInPreserved = false;

	UPROPERTY()
	bool StructStructMapInoutSawOriginal = false;

	UPROPERTY()
	bool StructStructMapInoutMutated = false;

	UPROPERTY()
	bool StructStructMapReturnPreserved = false;

	FStructToStructMapKey MakeKey(int ID, FName Tag)
	{
		FStructToStructMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	FStructToStructMapValue MakeValue(int Score, FString Label)
	{
		FStructToStructMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructStructMapValue(TMap<FStructToStructMapKey, FStructToStructMapValue> Items)
	{
		StructStructMapValueCount = Items.Num();
		FStructToStructMapValue Found;
		StructStructMapValuePreserved =
			Items.Find(MakeKey(11, n"MapValueB"), Found)
			&& Found.Score == 111
			&& Found.Label == "ValueB";
		return StructStructMapValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructStructMapIn(const TMap<FStructToStructMapKey, FStructToStructMapValue>&in Items)
	{
		StructStructMapInCount = Items.Num();
		FStructToStructMapValue Found;
		StructStructMapInPreserved =
			Items.Find(MakeKey(13, n"MapInB"), Found)
			&& Found.Score == 113
			&& Found.Label == "InB";
		return StructStructMapInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillStructStructMapOut(TMap<FStructToStructMapKey, FStructToStructMapValue>&out Items)
	{
		Items.Add(MakeKey(20, n"MapOutA"), MakeValue(220, "OutA"));
		Items.Add(MakeKey(21, n"MapOutB"), MakeValue(221, "OutB"));
	}

	UFUNCTION(BlueprintCallable)
	void MutateStructStructMapInout(TMap<FStructToStructMapKey, FStructToStructMapValue>&inout Items)
	{
		FStructToStructMapKey Existing = MakeKey(30, n"MapInoutA");
		FStructToStructMapValue Found;
		StructStructMapInoutSawOriginal =
			Items.Find(Existing, Found)
			&& Found.Score == 330
			&& Found.Label == "InoutA";

		Items.Remove(Existing);
		Items.Add(Existing, MakeValue(430, "InoutMutated"));
		Items.Add(MakeKey(31, n"MapInoutB"), MakeValue(431, "InoutAdded"));
		StructStructMapInout = Items;

		FStructToStructMapValue Mutated;
		StructStructMapInoutMutated =
			Items.Find(Existing, Mutated)
			&& Mutated.Score == 430
			&& Mutated.Label == "InoutMutated";
	}

	UFUNCTION(BlueprintCallable)
	TMap<FStructToStructMapKey, FStructToStructMapValue> ReturnStructStructMap()
	{
		TMap<FStructToStructMapKey, FStructToStructMapValue> Items;
		Items.Add(MakeKey(40, n"MapReturnA"), MakeValue(440, "ReturnA"));
		Items.Add(MakeKey(41, n"MapReturnB"), MakeValue(441, "ReturnB"));

		FStructToStructMapValue Found;
		StructStructMapReturnPreserved =
			Items.Find(MakeKey(41, n"MapReturnB"), Found)
			&& Found.Score == 441
			&& Found.Label == "ReturnB";
		return Items;
	}
}

bool Observe_StructStructMap_DefaultEmpty(ACoverageStructToStructMapMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructStructToStructMapParameterAndReturnMatrix setup: required Actor is null");
	}
	TMap<FStructToStructMapKey, FStructToStructMapValue> Empty;
	return Actor.CountStructStructMapValue(Empty) == 0
		&& !Actor.StructStructMapValuePreserved
		&& Actor.StructStructMapInout.Num() == 0;
}

bool Observe_StructStructMap_NominalMatrix(ACoverageStructToStructMapMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructStructToStructMapParameterAndReturnMatrix setup: required Actor is null");
	}
	TMap<FStructToStructMapKey, FStructToStructMapValue> ValueItems;
	ValueItems.Add(Actor.MakeKey(10, n"MapValueA"), Actor.MakeValue(110, "ValueA"));
	ValueItems.Add(Actor.MakeKey(11, n"MapValueB"), Actor.MakeValue(111, "ValueB"));
	TMap<FStructToStructMapKey, FStructToStructMapValue> InItems;
	InItems.Add(Actor.MakeKey(12, n"MapInA"), Actor.MakeValue(112, "InA"));
	InItems.Add(Actor.MakeKey(13, n"MapInB"), Actor.MakeValue(113, "InB"));
	TMap<FStructToStructMapKey, FStructToStructMapValue> OutItems;
	Actor.FillStructStructMapOut(OutItems);
	TMap<FStructToStructMapKey, FStructToStructMapValue> InoutItems;
	InoutItems.Add(Actor.MakeKey(30, n"MapInoutA"), Actor.MakeValue(330, "InoutA"));
	Actor.MutateStructStructMapInout(InoutItems);
	TMap<FStructToStructMapKey, FStructToStructMapValue> Returned = Actor.ReturnStructStructMap();
	return Actor.CountStructStructMapValue(ValueItems) == 2
		&& Actor.StructStructMapValuePreserved
		&& Actor.CountStructStructMapIn(InItems) == 2
		&& Actor.StructStructMapInPreserved
		&& OutItems.Num() == 2
		&& Actor.StructStructMapInoutSawOriginal
		&& Actor.StructStructMapInoutMutated
		&& Actor.StructStructMapReturnPreserved
		&& Returned.Num() == 2;
}

bool Observe_StructStructMap_ZeroKeyBoundary(ACoverageStructToStructMapMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructStructToStructMapParameterAndReturnMatrix setup: required Actor is null");
	}
	FStructToStructMapKey Zero = Actor.MakeKey(0, n"");
	FStructToStructMapValue Empty = Actor.MakeValue(0, "");
	TMap<FStructToStructMapKey, FStructToStructMapValue> Items;
	Items.Add(Zero, Empty);
	FStructToStructMapValue Found;
	return Items.Find(Actor.MakeKey(0, n""), Found) && Found.Score == 0 && Found.Label.Len() == 0;
}
