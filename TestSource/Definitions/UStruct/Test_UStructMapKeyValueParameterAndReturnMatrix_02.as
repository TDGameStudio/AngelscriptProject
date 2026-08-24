// Theme: Definitions.UStruct. Positive block 2: TMap<FName,FStruct> value/in/out/inout/return.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueParameterAndReturnMatrix lines 12312-12401.
// Isolation=none: complete program wrapping the raw helpers. Oracle: CountNameStructValue 2
// preserves Score 102; inout mutates 231; return preserves 142. Extra: empty map count 0.
// DefaultSafe.

UCLASS()
class UCoverageStructMapParamValueObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

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

USTRUCT(BlueprintType)
struct FMapParamValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructMapParamMatrixActor : AActor
{
	UPROPERTY()
	int NameStructValueCount = 0;

	UPROPERTY()
	int NameStructInCount = 0;

	UPROPERTY()
	TMap<FName, FMapParamValue> NameStructInout;

	UPROPERTY()
	bool NameStructValuePreserved = false;

	UPROPERTY()
	bool NameStructInPreserved = false;

	UPROPERTY()
	bool NameStructInoutSawOriginal = false;

	UPROPERTY()
	bool NameStructInoutMutated = false;

	UPROPERTY()
	bool NameStructReturnPreserved = false;

	FMapParamKey MakeKey(int ID, FName Tag)
	{
		FMapParamKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	FMapParamValue MakeValue(int Score, FString Label)
	{
		FMapParamValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	UCoverageStructMapParamValueObject MakeObject(int Value)
	{
		UCoverageStructMapParamValueObject Object = Cast<UCoverageStructMapParamValueObject>(NewObject(this, UCoverageStructMapParamValueObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	UFUNCTION(BlueprintCallable)
	int CountNameStructValue(TMap<FName, FMapParamValue> Items)
	{
		NameStructValueCount = Items.Num();
		FMapParamValue Found;
		NameStructValuePreserved =
			Items.Find(n"ValueB", Found)
			&& Found.Score == 102
			&& Found.Label == "NameValueB";
		return NameStructValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountNameStructIn(const TMap<FName, FMapParamValue>&in Items)
	{
		NameStructInCount = Items.Num();
		FMapParamValue Found;
		NameStructInPreserved =
			Items.Find(n"InB", Found)
			&& Found.Score == 112
			&& Found.Label == "NameInB";
		return NameStructInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillNameStructOut(TMap<FName, FMapParamValue>&out Items)
	{
		Items.Add(n"OutA", MakeValue(121, "NameOutA"));
		Items.Add(n"OutB", MakeValue(122, "NameOutB"));
	}

	UFUNCTION(BlueprintCallable)
	void MutateNameStructInout(TMap<FName, FMapParamValue>&inout Items)
	{
		FMapParamValue Found;
		NameStructInoutSawOriginal =
			Items.Find(n"InoutA", Found)
			&& Found.Score == 131
			&& Found.Label == "NameInoutA";
		Items.Add(n"InoutA", MakeValue(231, "NameInoutMutated"));
		Items.Add(n"InoutB", MakeValue(232, "NameInoutAdded"));
		NameStructInout = Items;

		FMapParamValue Mutated;
		NameStructInoutMutated =
			Items.Find(n"InoutA", Mutated)
			&& Mutated.Score == 231
			&& Mutated.Label == "NameInoutMutated";
	}

	UFUNCTION(BlueprintCallable)
	TMap<FName, FMapParamValue> ReturnNameStruct()
	{
		TMap<FName, FMapParamValue> Items;
		Items.Add(n"ReturnA", MakeValue(141, "NameReturnA"));
		Items.Add(n"ReturnB", MakeValue(142, "NameReturnB"));

		FMapParamValue Found;
		NameStructReturnPreserved =
			Items.Find(n"ReturnB", Found)
			&& Found.Score == 142
			&& Found.Label == "NameReturnB";
		return Items;
	}
}

bool Observe_NameStruct_DefaultEmpty(ACoverageStructMapParamMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueParameterAndReturnMatrix_02 setup: required Actor is null");
	}
	TMap<FName, FMapParamValue> Empty;
	return Actor.CountNameStructValue(Empty) == 0 && !Actor.NameStructValuePreserved && Actor.NameStructInout.Num() == 0;
}

bool Observe_NameStruct_NominalMatrix(ACoverageStructMapParamMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueParameterAndReturnMatrix_02 setup: required Actor is null");
	}
	TMap<FName, FMapParamValue> ValueItems;
	ValueItems.Add(n"ValueA", Actor.MakeValue(101, "NameValueA"));
	ValueItems.Add(n"ValueB", Actor.MakeValue(102, "NameValueB"));
	TMap<FName, FMapParamValue> InItems;
	InItems.Add(n"InA", Actor.MakeValue(111, "NameInA"));
	InItems.Add(n"InB", Actor.MakeValue(112, "NameInB"));
	TMap<FName, FMapParamValue> OutItems;
	Actor.FillNameStructOut(OutItems);
	TMap<FName, FMapParamValue> InoutItems;
	InoutItems.Add(n"InoutA", Actor.MakeValue(131, "NameInoutA"));
	Actor.MutateNameStructInout(InoutItems);
	TMap<FName, FMapParamValue> Returned = Actor.ReturnNameStruct();
	FMapParamValue Found;
	return Actor.CountNameStructValue(ValueItems) == 2
		&& Actor.NameStructValuePreserved
		&& Actor.CountNameStructIn(InItems) == 2
		&& Actor.NameStructInPreserved
		&& OutItems.Num() == 2
		&& OutItems.Find(n"OutB", Found) && Found.Score == 122
		&& Actor.NameStructInoutSawOriginal
		&& Actor.NameStructInoutMutated
		&& Actor.NameStructReturnPreserved
		&& Returned.Find(n"ReturnB", Found) && Found.Score == 142;
}

int Observe_NameStruct_MakeObjectBoundary(ACoverageStructMapParamMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueParameterAndReturnMatrix_02 setup: required Actor is null");
	}
	UCoverageStructMapParamValueObject Object = Actor.MakeObject(0);
	return Object != nullptr ? Object.Value : -1;
}
