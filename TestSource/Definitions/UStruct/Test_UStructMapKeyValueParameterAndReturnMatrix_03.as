// Theme: Definitions.UStruct. Positive block 3: TMap<FString,FStruct> and TMap<FStruct,FString>.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueParameterAndReturnMatrix lines 12402-12529.
// Isolation=none: complete program wrapping the raw methods. Oracle: StringStruct value 202,
// StructString value StructStringValueB. Extra: empty counts 0. DefaultSafe.

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
	int StringStructValueCount = 0;

	UPROPERTY()
	int StringStructInCount = 0;

	UPROPERTY()
	TMap<FString, FMapParamValue> StringStructInout;

	UPROPERTY()
	bool StringStructValuePreserved = false;

	UPROPERTY()
	bool StringStructInPreserved = false;

	UPROPERTY()
	bool StringStructInoutSawOriginal = false;

	UPROPERTY()
	bool StringStructInoutMutated = false;

	UPROPERTY()
	bool StringStructReturnPreserved = false;

	UPROPERTY()
	int StructStringValueCount = 0;

	UPROPERTY()
	int StructStringInCount = 0;

	UPROPERTY()
	TMap<FMapParamKey, FString> StructStringInout;

	UPROPERTY()
	bool StructStringValuePreserved = false;

	UPROPERTY()
	bool StructStringInPreserved = false;

	UPROPERTY()
	bool StructStringInoutSawOriginal = false;

	UPROPERTY()
	bool StructStringInoutMutated = false;

	UPROPERTY()
	bool StructStringReturnPreserved = false;

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

	UFUNCTION(BlueprintCallable)
	int CountStringStructValue(TMap<FString, FMapParamValue> Items)
	{
		StringStructValueCount = Items.Num();
		FMapParamValue Found;
		StringStructValuePreserved =
			Items.Find("ValueB", Found)
			&& Found.Score == 202
			&& Found.Label == "StringValueB";
		return StringStructValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountStringStructIn(const TMap<FString, FMapParamValue>&in Items)
	{
		StringStructInCount = Items.Num();
		FMapParamValue Found;
		StringStructInPreserved =
			Items.Find("InB", Found)
			&& Found.Score == 212
			&& Found.Label == "StringInB";
		return StringStructInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillStringStructOut(TMap<FString, FMapParamValue>&out Items)
	{
		Items.Add("OutA", MakeValue(221, "StringOutA"));
		Items.Add("OutB", MakeValue(222, "StringOutB"));
	}

	UFUNCTION(BlueprintCallable)
	void MutateStringStructInout(TMap<FString, FMapParamValue>&inout Items)
	{
		FMapParamValue Found;
		StringStructInoutSawOriginal =
			Items.Find("InoutA", Found)
			&& Found.Score == 231
			&& Found.Label == "StringInoutA";
		Items.Add("InoutA", MakeValue(331, "StringInoutMutated"));
		Items.Add("InoutB", MakeValue(332, "StringInoutAdded"));
		StringStructInout = Items;

		FMapParamValue Mutated;
		StringStructInoutMutated =
			Items.Find("InoutA", Mutated)
			&& Mutated.Score == 331
			&& Mutated.Label == "StringInoutMutated";
	}

	UFUNCTION(BlueprintCallable)
	TMap<FString, FMapParamValue> ReturnStringStruct()
	{
		TMap<FString, FMapParamValue> Items;
		Items.Add("ReturnA", MakeValue(241, "StringReturnA"));
		Items.Add("ReturnB", MakeValue(242, "StringReturnB"));

		FMapParamValue Found;
		StringStructReturnPreserved =
			Items.Find("ReturnB", Found)
			&& Found.Score == 242
			&& Found.Label == "StringReturnB";
		return Items;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructStringValue(TMap<FMapParamKey, FString> Items)
	{
		StructStringValueCount = Items.Num();
		FString Found;
		StructStringValuePreserved =
			Items.Find(MakeKey(301, n"ValueB"), Found)
			&& Found == "StructStringValueB";
		return StructStringValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructStringIn(const TMap<FMapParamKey, FString>&in Items)
	{
		StructStringInCount = Items.Num();
		FString Found;
		StructStringInPreserved =
			Items.Find(MakeKey(311, n"InB"), Found)
			&& Found == "StructStringInB";
		return StructStringInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillStructStringOut(TMap<FMapParamKey, FString>&out Items)
	{
		Items.Add(MakeKey(320, n"OutA"), "StructStringOutA");
		Items.Add(MakeKey(321, n"OutB"), "StructStringOutB");
	}

	UFUNCTION(BlueprintCallable)
	void MutateStructStringInout(TMap<FMapParamKey, FString>&inout Items)
	{
		FMapParamKey Existing = MakeKey(330, n"InoutA");
		FString Found;
		StructStringInoutSawOriginal =
			Items.Find(Existing, Found)
			&& Found == "StructStringInoutA";
		Items.Add(Existing, "StructStringInoutMutated");
		Items.Add(MakeKey(331, n"InoutB"), "StructStringInoutAdded");
		StructStringInout = Items;

		FString Mutated;
		StructStringInoutMutated =
			Items.Find(Existing, Mutated)
			&& Mutated == "StructStringInoutMutated";
	}

	UFUNCTION(BlueprintCallable)
	TMap<FMapParamKey, FString> ReturnStructString()
	{
		TMap<FMapParamKey, FString> Items;
		Items.Add(MakeKey(340, n"ReturnA"), "StructStringReturnA");
		Items.Add(MakeKey(341, n"ReturnB"), "StructStringReturnB");

		FString Found;
		StructStringReturnPreserved =
			Items.Find(MakeKey(341, n"ReturnB"), Found)
			&& Found == "StructStringReturnB";
		return Items;
	}
}

bool Observe_StringStruct_DefaultEmpty(ACoverageStructMapParamMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueParameterAndReturnMatrix_03 setup: required Actor is null");
	}
	TMap<FString, FMapParamValue> EmptyString;
	TMap<FMapParamKey, FString> EmptyStruct;
	return Actor.CountStringStructValue(EmptyString) == 0
		&& Actor.CountStructStringValue(EmptyStruct) == 0
		&& !Actor.StringStructValuePreserved
		&& !Actor.StructStringValuePreserved;
}

bool Observe_StringStruct_NominalMatrix(ACoverageStructMapParamMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueParameterAndReturnMatrix_03 setup: required Actor is null");
	}
	TMap<FString, FMapParamValue> StringValue;
	StringValue.Add("ValueA", Actor.MakeValue(201, "StringValueA"));
	StringValue.Add("ValueB", Actor.MakeValue(202, "StringValueB"));
	TMap<FString, FMapParamValue> StringIn;
	StringIn.Add("InA", Actor.MakeValue(211, "StringInA"));
	StringIn.Add("InB", Actor.MakeValue(212, "StringInB"));
	TMap<FString, FMapParamValue> StringOut;
	Actor.FillStringStructOut(StringOut);
	TMap<FString, FMapParamValue> StringInout;
	StringInout.Add("InoutA", Actor.MakeValue(231, "StringInoutA"));
	Actor.MutateStringStructInout(StringInout);
	TMap<FString, FMapParamValue> StringReturned = Actor.ReturnStringStruct();

	TMap<FMapParamKey, FString> StructValue;
	StructValue.Add(Actor.MakeKey(300, n"ValueA"), "StructStringValueA");
	StructValue.Add(Actor.MakeKey(301, n"ValueB"), "StructStringValueB");
	TMap<FMapParamKey, FString> StructIn;
	StructIn.Add(Actor.MakeKey(310, n"InA"), "StructStringInA");
	StructIn.Add(Actor.MakeKey(311, n"InB"), "StructStringInB");
	TMap<FMapParamKey, FString> StructOut;
	Actor.FillStructStringOut(StructOut);
	TMap<FMapParamKey, FString> StructInout;
	StructInout.Add(Actor.MakeKey(330, n"InoutA"), "StructStringInoutA");
	Actor.MutateStructStringInout(StructInout);
	TMap<FMapParamKey, FString> StructReturned = Actor.ReturnStructString();
	return Actor.CountStringStructValue(StringValue) == 2
		&& Actor.StringStructValuePreserved
		&& Actor.CountStringStructIn(StringIn) == 2
		&& Actor.StringStructInPreserved
		&& StringOut.Num() == 2
		&& Actor.StringStructInoutMutated
		&& Actor.StringStructReturnPreserved
		&& StringReturned.Num() == 2
		&& Actor.CountStructStringValue(StructValue) == 2
		&& Actor.StructStringValuePreserved
		&& Actor.CountStructStringIn(StructIn) == 2
		&& Actor.StructStringInPreserved
		&& StructOut.Num() == 2
		&& Actor.StructStringInoutMutated
		&& Actor.StructStringReturnPreserved
		&& StructReturned.Num() == 2;
}

int Observe_StringStruct_EmptyOutBoundary(ACoverageStructMapParamMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueParameterAndReturnMatrix_03 setup: required Actor is null");
	}
	TMap<FString, FMapParamValue> OutItems;
	Actor.FillStringStructOut(OutItems);
	return OutItems.Num();
}
