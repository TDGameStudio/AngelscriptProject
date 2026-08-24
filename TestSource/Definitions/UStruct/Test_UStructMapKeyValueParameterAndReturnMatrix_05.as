// Theme: Definitions.UStruct. Positive block 5: TMap<FStruct,UObject> value/in/out/inout/return.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueParameterAndReturnMatrix lines 12593-12661.
// Isolation=none: complete program wrapping CountStructObject*. Oracle: ValueB object Value 502,
// inout mutates 631. Extra: empty count 0; null object is not preserved. DefaultSafe.

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

UCLASS()
class ACoverageStructMapParamMatrixActor : AActor
{
	UPROPERTY()
	int StructObjectValueCount = 0;

	UPROPERTY()
	int StructObjectInCount = 0;

	UPROPERTY()
	TMap<FMapParamKey, UCoverageStructMapParamValueObject> StructObjectInout;

	UPROPERTY()
	bool StructObjectValuePreserved = false;

	UPROPERTY()
	bool StructObjectInPreserved = false;

	UPROPERTY()
	bool StructObjectInoutSawOriginal = false;

	UPROPERTY()
	bool StructObjectInoutMutated = false;

	UPROPERTY()
	bool StructObjectReturnPreserved = false;

	FMapParamKey MakeKey(int ID, FName Tag)
	{
		FMapParamKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	UCoverageStructMapParamValueObject MakeObject(int Value)
	{
		UCoverageStructMapParamValueObject Object = Cast<UCoverageStructMapParamValueObject>(NewObject(this, UCoverageStructMapParamValueObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructObjectValue(TMap<FMapParamKey, UCoverageStructMapParamValueObject> Items)
	{
		StructObjectValueCount = Items.Num();
		UCoverageStructMapParamValueObject Found = nullptr;
		StructObjectValuePreserved =
			Items.Find(MakeKey(501, n"ValueB"), Found)
			&& Found != nullptr
			&& Found.Value == 502;
		return StructObjectValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructObjectIn(const TMap<FMapParamKey, UCoverageStructMapParamValueObject>&in Items)
	{
		StructObjectInCount = Items.Num();
		UCoverageStructMapParamValueObject Found = nullptr;
		StructObjectInPreserved =
			Items.Find(MakeKey(511, n"InB"), Found)
			&& Found != nullptr
			&& Found.Value == 512;
		return StructObjectInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillStructObjectOut(TMap<FMapParamKey, UCoverageStructMapParamValueObject>&out Items)
	{
		Items.Add(MakeKey(520, n"OutA"), MakeObject(521));
		Items.Add(MakeKey(521, n"OutB"), MakeObject(522));
	}

	UFUNCTION(BlueprintCallable)
	void MutateStructObjectInout(TMap<FMapParamKey, UCoverageStructMapParamValueObject>&inout Items)
	{
		FMapParamKey Existing = MakeKey(530, n"InoutA");
		UCoverageStructMapParamValueObject Found = nullptr;
		StructObjectInoutSawOriginal =
			Items.Find(Existing, Found)
			&& Found != nullptr
			&& Found.Value == 531;
		Items.Add(Existing, MakeObject(631));
		Items.Add(MakeKey(531, n"InoutB"), MakeObject(632));
		StructObjectInout = Items;

		UCoverageStructMapParamValueObject Mutated = nullptr;
		StructObjectInoutMutated =
			Items.Find(Existing, Mutated)
			&& Mutated != nullptr
			&& Mutated.Value == 631;
	}

	UFUNCTION(BlueprintCallable)
	TMap<FMapParamKey, UCoverageStructMapParamValueObject> ReturnStructObject()
	{
		TMap<FMapParamKey, UCoverageStructMapParamValueObject> Items;
		Items.Add(MakeKey(540, n"ReturnA"), MakeObject(541));
		Items.Add(MakeKey(541, n"ReturnB"), MakeObject(542));

		UCoverageStructMapParamValueObject Found = nullptr;
		StructObjectReturnPreserved =
			Items.Find(MakeKey(541, n"ReturnB"), Found)
			&& Found != nullptr
			&& Found.Value == 542;
		return Items;
	}
}

bool Observe_StructObject_DefaultEmpty(ACoverageStructMapParamMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueParameterAndReturnMatrix_05 setup: required Actor is null");
	}
	TMap<FMapParamKey, UCoverageStructMapParamValueObject> Empty;
	return Actor.CountStructObjectValue(Empty) == 0 && !Actor.StructObjectValuePreserved && Actor.StructObjectInout.Num() == 0;
}

bool Observe_StructObject_NominalMatrix(ACoverageStructMapParamMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueParameterAndReturnMatrix_05 setup: required Actor is null");
	}
	TMap<FMapParamKey, UCoverageStructMapParamValueObject> ValueItems;
	ValueItems.Add(Actor.MakeKey(500, n"ValueA"), Actor.MakeObject(501));
	ValueItems.Add(Actor.MakeKey(501, n"ValueB"), Actor.MakeObject(502));
	TMap<FMapParamKey, UCoverageStructMapParamValueObject> InItems;
	InItems.Add(Actor.MakeKey(510, n"InA"), Actor.MakeObject(511));
	InItems.Add(Actor.MakeKey(511, n"InB"), Actor.MakeObject(512));
	TMap<FMapParamKey, UCoverageStructMapParamValueObject> OutItems;
	Actor.FillStructObjectOut(OutItems);
	TMap<FMapParamKey, UCoverageStructMapParamValueObject> InoutItems;
	InoutItems.Add(Actor.MakeKey(530, n"InoutA"), Actor.MakeObject(531));
	Actor.MutateStructObjectInout(InoutItems);
	TMap<FMapParamKey, UCoverageStructMapParamValueObject> Returned = Actor.ReturnStructObject();
	return Actor.CountStructObjectValue(ValueItems) == 2
		&& Actor.StructObjectValuePreserved
		&& Actor.CountStructObjectIn(InItems) == 2
		&& Actor.StructObjectInPreserved
		&& OutItems.Num() == 2
		&& Actor.StructObjectInoutSawOriginal
		&& Actor.StructObjectInoutMutated
		&& Actor.StructObjectReturnPreserved
		&& Returned.Num() == 2;
}

bool Observe_StructObject_NullValueBoundary(ACoverageStructMapParamMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueParameterAndReturnMatrix_05 setup: required Actor is null");
	}
	TMap<FMapParamKey, UCoverageStructMapParamValueObject> Items;
	Items.Add(Actor.MakeKey(501, n"ValueB"), nullptr);
	return Actor.CountStructObjectValue(Items) == 1 && !Actor.StructObjectValuePreserved;
}
