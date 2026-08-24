// Theme: Definitions.UStruct. WorldStory block 2: TMap<bool,FStruct> value/in/out/inout/return.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapPrimitiveKeyValueParameterAndReturnMatrix lines 13582-13801.
// Isolation=none: complete program wrapping CountBoolStruct*. Oracle: Find(false) Score 102
// Label BoolValueFalse; inout mutates true to 231. Extra: empty count 0. FixtureIsolated.

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

USTRUCT(BlueprintType)
struct FMapPrimitiveValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class UCoverageStructMapPrimitiveKeyObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapPrimitiveMatrixActor : AActor
{
	UPROPERTY()
	int BoolStructValueCount = 0;

	UPROPERTY()
	int BoolStructInCount = 0;

	UPROPERTY()
	TMap<bool, FMapPrimitiveValue> BoolStructInout;

	UPROPERTY()
	bool BoolStructValuePreserved = false;

	UPROPERTY()
	bool BoolStructInPreserved = false;

	UPROPERTY()
	bool BoolStructInoutSawOriginal = false;

	UPROPERTY()
	bool BoolStructInoutMutated = false;

	UPROPERTY()
	bool BoolStructReturnPreserved = false;

	UPROPERTY()
	int FloatStructValueCount = 0;

	UPROPERTY()
	int FloatStructInCount = 0;

	UPROPERTY()
	TMap<float, FMapPrimitiveValue> FloatStructInout;

	UPROPERTY()
	bool FloatStructValuePreserved = false;

	UPROPERTY()
	bool FloatStructInPreserved = false;

	UPROPERTY()
	bool FloatStructInoutSawOriginal = false;

	UPROPERTY()
	bool FloatStructInoutMutated = false;

	UPROPERTY()
	bool FloatStructReturnPreserved = false;

	UPROPERTY()
	int ObjectStructValueCount = 0;

	UPROPERTY()
	int ObjectStructInCount = 0;

	UPROPERTY()
	TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> ObjectStructInout;

	UPROPERTY()
	bool ObjectStructValuePreserved = false;

	UPROPERTY()
	bool ObjectStructInPreserved = false;

	UPROPERTY()
	bool ObjectStructInoutSawOriginal = false;

	UPROPERTY()
	bool ObjectStructInoutMutated = false;

	UPROPERTY()
	bool ObjectStructReturnPreserved = false;

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

	UPROPERTY()
	int StructFloatValueCount = 0;

	UPROPERTY()
	int StructFloatInCount = 0;

	UPROPERTY()
	TMap<FMapPrimitiveKey, float> StructFloatInout;

	UPROPERTY()
	bool StructFloatValuePreserved = false;

	UPROPERTY()
	bool StructFloatInPreserved = false;

	UPROPERTY()
	bool StructFloatInoutSawOriginal = false;

	UPROPERTY()
	bool StructFloatInoutMutated = false;

	UPROPERTY()
	bool StructFloatReturnPreserved = false;

	FMapPrimitiveKey MakeKey(int ID, FName Tag)
	{
		FMapPrimitiveKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	FMapPrimitiveValue MakeValue(int Score, FString Label)
	{
		FMapPrimitiveValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	UCoverageStructMapPrimitiveKeyObject MakeObjectKey(int Value)
	{
		UCoverageStructMapPrimitiveKeyObject Object = Cast<UCoverageStructMapPrimitiveKeyObject>(NewObject(this, UCoverageStructMapPrimitiveKeyObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	UFUNCTION(BlueprintCallable)
	int CountBoolStructValue(TMap<bool, FMapPrimitiveValue> Items)
	{
		BoolStructValueCount = Items.Num();
		FMapPrimitiveValue Found;
		BoolStructValuePreserved =
			Items.Find(false, Found)
			&& Found.Score == 102
			&& Found.Label == "BoolValueFalse";
		return BoolStructValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountBoolStructIn(const TMap<bool, FMapPrimitiveValue>&in Items)
	{
		BoolStructInCount = Items.Num();
		FMapPrimitiveValue Found;
		BoolStructInPreserved =
			Items.Find(true, Found)
			&& Found.Score == 111
			&& Found.Label == "BoolInTrue";
		return BoolStructInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillBoolStructOut(TMap<bool, FMapPrimitiveValue>&out Items)
	{
		Items.Add(true, MakeValue(121, "BoolOutTrue"));
		Items.Add(false, MakeValue(122, "BoolOutFalse"));
	}

	UFUNCTION(BlueprintCallable)
	void MutateBoolStructInout(TMap<bool, FMapPrimitiveValue>&inout Items)
	{
		FMapPrimitiveValue Found;
		BoolStructInoutSawOriginal =
			Items.Find(true, Found)
			&& Found.Score == 131
			&& Found.Label == "BoolInoutTrue";
		Items.Add(true, MakeValue(231, "BoolInoutMutated"));
		Items.Add(false, MakeValue(232, "BoolInoutAdded"));
		BoolStructInout = Items;

		FMapPrimitiveValue Mutated;
		BoolStructInoutMutated =
			Items.Find(true, Mutated)
			&& Mutated.Score == 231
			&& Mutated.Label == "BoolInoutMutated";
	}

	UFUNCTION(BlueprintCallable)
	TMap<bool, FMapPrimitiveValue> ReturnBoolStruct()
	{
		TMap<bool, FMapPrimitiveValue> Items;
		Items.Add(true, MakeValue(141, "BoolReturnTrue"));
		Items.Add(false, MakeValue(142, "BoolReturnFalse"));

		FMapPrimitiveValue Found;
		BoolStructReturnPreserved =
			Items.Find(false, Found)
			&& Found.Score == 142
			&& Found.Label == "BoolReturnFalse";
		return Items;
	}
}

bool Observe_BoolStruct_DefaultEmpty(ACoverageStructMapPrimitiveMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapPrimitiveKeyValueParameterAndReturnMatrix_02 setup: required Actor is null");
	}
	TMap<bool, FMapPrimitiveValue> Empty;
	return Actor.CountBoolStructValue(Empty) == 0
		&& !Actor.BoolStructValuePreserved
		&& Actor.BoolStructInout.Num() == 0
		&& Actor.FloatStructValueCount == 0;
}

bool Observe_BoolStruct_NominalMatrix(ACoverageStructMapPrimitiveMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapPrimitiveKeyValueParameterAndReturnMatrix_02 setup: required Actor is null");
	}
	TMap<bool, FMapPrimitiveValue> ValueItems;
	ValueItems.Add(true, Actor.MakeValue(101, "BoolValueTrue"));
	ValueItems.Add(false, Actor.MakeValue(102, "BoolValueFalse"));
	TMap<bool, FMapPrimitiveValue> InItems;
	InItems.Add(true, Actor.MakeValue(111, "BoolInTrue"));
	TMap<bool, FMapPrimitiveValue> OutItems;
	Actor.FillBoolStructOut(OutItems);
	TMap<bool, FMapPrimitiveValue> InoutItems;
	InoutItems.Add(true, Actor.MakeValue(131, "BoolInoutTrue"));
	Actor.MutateBoolStructInout(InoutItems);
	TMap<bool, FMapPrimitiveValue> Returned = Actor.ReturnBoolStruct();
	FMapPrimitiveValue Found;
	return Actor.CountBoolStructValue(ValueItems) == 2
		&& Actor.BoolStructValuePreserved
		&& Actor.CountBoolStructIn(InItems) == 1
		&& Actor.BoolStructInPreserved
		&& OutItems.Num() == 2
		&& Actor.BoolStructInoutSawOriginal
		&& Actor.BoolStructInoutMutated
		&& Actor.BoolStructReturnPreserved
		&& Returned.Find(false, Found) && Found.Score == 142;
}

bool Observe_BoolStruct_FalseKeyBoundary(ACoverageStructMapPrimitiveMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapPrimitiveKeyValueParameterAndReturnMatrix_02 setup: required Actor is null");
	}
	TMap<bool, FMapPrimitiveValue> Items;
	Items.Add(false, Actor.MakeValue(102, "BoolValueFalse"));
	return Actor.CountBoolStructValue(Items) == 1 && Actor.BoolStructValuePreserved;
}
