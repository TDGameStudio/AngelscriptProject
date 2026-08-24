// Theme: Definitions.UStruct. Positive block 5: TMap<FStruct,float> value/in/out/inout/return.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapPrimitiveKeyValueParameterAndReturnMatrix lines 14017-14080.
// Isolation=none: complete program wrapping CountStructFloat*. Oracle: ValueFloatB 502.5f;
// inout mutates 631.5f. Extra: empty count 0. DefaultSafe.

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

	UFUNCTION(BlueprintCallable)
	int CountStructFloatValue(TMap<FMapPrimitiveKey, float> Items)
	{
		StructFloatValueCount = Items.Num();
		float Found = 0.0f;
		StructFloatValuePreserved =
			Items.Find(MakeKey(501, n"ValueFloatB"), Found)
			&& Found == 502.5f;
		return StructFloatValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructFloatIn(const TMap<FMapPrimitiveKey, float>&in Items)
	{
		StructFloatInCount = Items.Num();
		float Found = 0.0f;
		StructFloatInPreserved =
			Items.Find(MakeKey(511, n"InFloatB"), Found)
			&& Found == 512.5f;
		return StructFloatInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillStructFloatOut(TMap<FMapPrimitiveKey, float>&out Items)
	{
		Items.Add(MakeKey(520, n"OutFloatA"), 521.5f);
		Items.Add(MakeKey(521, n"OutFloatB"), 522.5f);
	}

	UFUNCTION(BlueprintCallable)
	void MutateStructFloatInout(TMap<FMapPrimitiveKey, float>&inout Items)
	{
		FMapPrimitiveKey Existing = MakeKey(530, n"InoutFloatA");
		float Found = 0.0f;
		StructFloatInoutSawOriginal =
			Items.Find(Existing, Found)
			&& Found == 531.5f;
		Items.Add(Existing, 631.5f);
		Items.Add(MakeKey(531, n"InoutFloatB"), 632.5f);
		StructFloatInout = Items;

		float Mutated = 0.0f;
		StructFloatInoutMutated =
			Items.Find(Existing, Mutated)
			&& Mutated == 631.5f;
	}

	UFUNCTION(BlueprintCallable)
	TMap<FMapPrimitiveKey, float> ReturnStructFloat()
	{
		TMap<FMapPrimitiveKey, float> Items;
		Items.Add(MakeKey(540, n"ReturnFloatA"), 541.5f);
		Items.Add(MakeKey(541, n"ReturnFloatB"), 542.5f);

		float Found = 0.0f;
		StructFloatReturnPreserved =
			Items.Find(MakeKey(541, n"ReturnFloatB"), Found)
			&& Found == 542.5f;
		return Items;
	}
}

bool Observe_StructFloat_DefaultEmpty(ACoverageStructMapPrimitiveMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapPrimitiveKeyValueParameterAndReturnMatrix_05 setup: required Actor is null");
	}
	TMap<FMapPrimitiveKey, float> Empty;
	return Actor.CountStructFloatValue(Empty) == 0 && !Actor.StructFloatValuePreserved && Actor.StructFloatInout.Num() == 0;
}

bool Observe_StructFloat_NominalMatrix(ACoverageStructMapPrimitiveMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapPrimitiveKeyValueParameterAndReturnMatrix_05 setup: required Actor is null");
	}
	TMap<FMapPrimitiveKey, float> ValueItems;
	ValueItems.Add(Actor.MakeKey(500, n"ValueFloatA"), 501.5f);
	ValueItems.Add(Actor.MakeKey(501, n"ValueFloatB"), 502.5f);
	TMap<FMapPrimitiveKey, float> InItems;
	InItems.Add(Actor.MakeKey(510, n"InFloatA"), 511.5f);
	InItems.Add(Actor.MakeKey(511, n"InFloatB"), 512.5f);
	TMap<FMapPrimitiveKey, float> OutItems;
	Actor.FillStructFloatOut(OutItems);
	TMap<FMapPrimitiveKey, float> InoutItems;
	InoutItems.Add(Actor.MakeKey(530, n"InoutFloatA"), 531.5f);
	Actor.MutateStructFloatInout(InoutItems);
	TMap<FMapPrimitiveKey, float> Returned = Actor.ReturnStructFloat();
	float Found = 0.0f;
	return Actor.CountStructFloatValue(ValueItems) == 2
		&& Actor.StructFloatValuePreserved
		&& Actor.CountStructFloatIn(InItems) == 2
		&& Actor.StructFloatInPreserved
		&& OutItems.Num() == 2
		&& Actor.StructFloatInoutSawOriginal
		&& Actor.StructFloatInoutMutated
		&& Actor.StructFloatReturnPreserved
		&& Returned.Find(Actor.MakeKey(541, n"ReturnFloatB"), Found)
		&& Found == 542.5f;
}

bool Observe_StructFloat_ZeroValueBoundary(ACoverageStructMapPrimitiveMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapPrimitiveKeyValueParameterAndReturnMatrix_05 setup: required Actor is null");
	}
	TMap<FMapPrimitiveKey, float> Items;
	Items.Add(Actor.MakeKey(0, n""), 0.0f);
	float Found = 1.0f;
	return Items.Find(Actor.MakeKey(0, n""), Found) && Found == 0.0f && Actor.CountStructFloatValue(Items) == 1 && !Actor.StructFloatValuePreserved;
}
