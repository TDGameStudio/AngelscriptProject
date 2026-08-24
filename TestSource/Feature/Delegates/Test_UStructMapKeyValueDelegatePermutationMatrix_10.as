// Theme: Feature.Delegates. WorldStory block 10: struct-object handlers plus name/string BeginPlay.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 8009-8136.
// Isolation=none: wrap HandleStructObject* and the BeginPlay fragment with key/value/object
// types, signals, MakeKey/MakeValue/MakeObject, and name/string handlers.
// Oracle: HandleStructObjectValue Found.Value 502; NameStructValueResult 2; NameOutB Score 122.
// Extra: empty maps Num 0; null object miss. FixtureIsolated. Keep BeginPlay.

UCLASS()
class UCoverageStructDelegateMapValueObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

USTRUCT(BlueprintType)
struct FDelegateKeyValueMapKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FDelegateKeyValueMapKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 929) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FDelegateKeyValueMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

delegate int FNameStructMapValueSignal(TMap<FName, FDelegateKeyValueMapValue> Items);
delegate int FNameStructMapInSignal(const TMap<FName, FDelegateKeyValueMapValue>&in Items);
delegate void FNameStructMapOutSignal(TMap<FName, FDelegateKeyValueMapValue>&out Items);
delegate int FNameStructMapInoutSignal(TMap<FName, FDelegateKeyValueMapValue>&inout Items);
delegate TMap<FName, FDelegateKeyValueMapValue> FNameStructMapReturnSignal();
delegate int FStringStructMapValueSignal(TMap<FString, FDelegateKeyValueMapValue> Items);
delegate int FStringStructMapInSignal(const TMap<FString, FDelegateKeyValueMapValue>&in Items);
delegate void FStringStructMapOutSignal(TMap<FString, FDelegateKeyValueMapValue>&out Items);
delegate int FStringStructMapInoutSignal(TMap<FString, FDelegateKeyValueMapValue>&inout Items);
delegate TMap<FString, FDelegateKeyValueMapValue> FStringStructMapReturnSignal();

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	UPROPERTY()
	FNameStructMapValueSignal NameStructValueSignal;
	UPROPERTY()
	FNameStructMapInSignal NameStructInSignal;
	UPROPERTY()
	FNameStructMapOutSignal NameStructOutSignal;
	UPROPERTY()
	FNameStructMapInoutSignal NameStructInoutSignal;
	UPROPERTY()
	FNameStructMapReturnSignal NameStructReturnSignal;
	UPROPERTY()
	FStringStructMapValueSignal StringStructValueSignal;
	UPROPERTY()
	FStringStructMapInSignal StringStructInSignal;
	UPROPERTY()
	FStringStructMapOutSignal StringStructOutSignal;
	UPROPERTY()
	FStringStructMapInoutSignal StringStructInoutSignal;
	UPROPERTY()
	FStringStructMapReturnSignal StringStructReturnSignal;

	UPROPERTY()
	bool StructObjectValuePreserved = false;
	UPROPERTY()
	bool StructObjectInPreserved = false;
	UPROPERTY()
	bool StructObjectInoutPreserved = false;
	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> StructObjectInoutResultItems;
	UPROPERTY()
	int NameStructValueResult = 0;
	UPROPERTY()
	int NameStructInResult = 0;
	UPROPERTY()
	int NameStructInoutResult = 0;
	UPROPERTY()
	TMap<FName, FDelegateKeyValueMapValue> NameStructOutResult;
	UPROPERTY()
	TMap<FName, FDelegateKeyValueMapValue> NameStructInoutResultItems;
	UPROPERTY()
	TMap<FName, FDelegateKeyValueMapValue> NameStructReturnResult;
	UPROPERTY()
	bool NameStructValuePreserved = false;
	UPROPERTY()
	bool NameStructInPreserved = false;
	UPROPERTY()
	bool NameStructOutPreserved = false;
	UPROPERTY()
	bool NameStructInoutPreserved = false;
	UPROPERTY()
	bool NameStructReturnPreserved = false;
	UPROPERTY()
	int StringStructValueResult = 0;
	UPROPERTY()
	int StringStructInResult = 0;
	UPROPERTY()
	int StringStructInoutResult = 0;
	UPROPERTY()
	TMap<FString, FDelegateKeyValueMapValue> StringStructOutResult;
	UPROPERTY()
	TMap<FString, FDelegateKeyValueMapValue> StringStructInoutResultItems;
	UPROPERTY()
	TMap<FString, FDelegateKeyValueMapValue> StringStructReturnResult;
	UPROPERTY()
	bool StringStructValuePreserved = false;
	UPROPERTY()
	bool StringStructInPreserved = false;
	UPROPERTY()
	bool StringStructOutPreserved = false;
	UPROPERTY()
	bool StringStructInoutPreserved = false;
	UPROPERTY()
	bool StringStructReturnPreserved = false;

	FDelegateKeyValueMapKey MakeKey(int ID, FName Tag)
	{
		FDelegateKeyValueMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	FDelegateKeyValueMapValue MakeValue(int Score, FString Label)
	{
		FDelegateKeyValueMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	UCoverageStructDelegateMapValueObject MakeObject(int Value)
	{
		UCoverageStructDelegateMapValueObject Object = Cast<UCoverageStructDelegateMapValueObject>(NewObject(this, UCoverageStructDelegateMapValueObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	UFUNCTION()
	int HandleStructObjectValue(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> Items)
	{
		UCoverageStructDelegateMapValueObject Found = nullptr;
		StructObjectValuePreserved =
			Items.Find(MakeKey(501, n"StructObjectValueB"), Found)
			&& Found != nullptr
			&& Found.Value == 502;
		return Items.Num();
	}

	UFUNCTION()
	int HandleStructObjectIn(const TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&in Items)
	{
		UCoverageStructDelegateMapValueObject Found = nullptr;
		StructObjectInPreserved =
			Items.Find(MakeKey(511, n"StructObjectInB"), Found)
			&& Found != nullptr
			&& Found.Value == 512;
		return Items.Num() + 70;
	}

	UFUNCTION()
	void HandleStructObjectOut(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&out Items)
	{
		Items.Add(MakeKey(520, n"StructObjectOutA"), MakeObject(521));
		Items.Add(MakeKey(521, n"StructObjectOutB"), MakeObject(522));
	}

	UFUNCTION()
	int HandleStructObjectInout(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&inout Items)
	{
		FDelegateKeyValueMapKey Existing = MakeKey(530, n"StructObjectInoutA");
		UCoverageStructDelegateMapValueObject Found = nullptr;
		if (Items.Find(Existing, Found) && Found != nullptr)
		{
			Items.Add(Existing, MakeObject(Found.Value + 100));
		}
		Items.Add(MakeKey(531, n"StructObjectInoutB"), MakeObject(532));
		StructObjectInoutResultItems = Items;
		UCoverageStructDelegateMapValueObject Mutated = nullptr;
		StructObjectInoutPreserved =
			Items.Find(Existing, Mutated)
			&& Mutated != nullptr
			&& Mutated.Value == 631;
		return Items.Num() + 80;
	}

	UFUNCTION()
	TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> HandleStructObjectReturn()
	{
		TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> Items;
		Items.Add(MakeKey(540, n"StructObjectReturnA"), MakeObject(541));
		Items.Add(MakeKey(541, n"StructObjectReturnB"), MakeObject(542));
		return Items;
	}

	UFUNCTION()
	int HandleNameStructValue(TMap<FName, FDelegateKeyValueMapValue> Items)
	{
		FDelegateKeyValueMapValue Found;
		NameStructValuePreserved = Items.Find(n"NameValueB", Found) && Found.Score == 102 && Found.Label == "NameValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleNameStructIn(const TMap<FName, FDelegateKeyValueMapValue>&in Items)
	{
		FDelegateKeyValueMapValue Found;
		NameStructInPreserved = Items.Find(n"NameInB", Found) && Found.Score == 112 && Found.Label == "NameInB";
		return Items.Num() + 10;
	}

	UFUNCTION()
	void HandleNameStructOut(TMap<FName, FDelegateKeyValueMapValue>&out Items)
	{
		Items.Add(n"NameOutA", MakeValue(121, "NameOutA"));
		Items.Add(n"NameOutB", MakeValue(122, "NameOutB"));
	}

	UFUNCTION()
	int HandleNameStructInout(TMap<FName, FDelegateKeyValueMapValue>&inout Items)
	{
		FDelegateKeyValueMapValue Found;
		if (Items.Find(n"NameInoutA", Found))
		{
			Found.Score += 100;
			Found.Label = "NameInoutMutated";
			Items.Add(n"NameInoutA", Found);
		}
		Items.Add(n"NameInoutB", MakeValue(132, "NameInoutAdded"));
		NameStructInoutResultItems = Items;
		FDelegateKeyValueMapValue Mutated;
		NameStructInoutPreserved = Items.Find(n"NameInoutA", Mutated) && Mutated.Score == 231 && Mutated.Label == "NameInoutMutated";
		return Items.Num() + Mutated.Score;
	}

	UFUNCTION()
	TMap<FName, FDelegateKeyValueMapValue> HandleNameStructReturn()
	{
		TMap<FName, FDelegateKeyValueMapValue> Items;
		Items.Add(n"NameReturnA", MakeValue(141, "NameReturnA"));
		Items.Add(n"NameReturnB", MakeValue(142, "NameReturnB"));
		return Items;
	}

	UFUNCTION()
	int HandleStringStructValue(TMap<FString, FDelegateKeyValueMapValue> Items)
	{
		FDelegateKeyValueMapValue Found;
		StringStructValuePreserved = Items.Find("StringValueB", Found) && Found.Score == 202 && Found.Label == "StringValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleStringStructIn(const TMap<FString, FDelegateKeyValueMapValue>&in Items)
	{
		FDelegateKeyValueMapValue Found;
		StringStructInPreserved = Items.Find("StringInB", Found) && Found.Score == 212 && Found.Label == "StringInB";
		return Items.Num() + 20;
	}

	UFUNCTION()
	void HandleStringStructOut(TMap<FString, FDelegateKeyValueMapValue>&out Items)
	{
		Items.Add("StringOutA", MakeValue(221, "StringOutA"));
		Items.Add("StringOutB", MakeValue(222, "StringOutB"));
	}

	UFUNCTION()
	int HandleStringStructInout(TMap<FString, FDelegateKeyValueMapValue>&inout Items)
	{
		FDelegateKeyValueMapValue Found;
		if (Items.Find("StringInoutA", Found))
		{
			Found.Score += 100;
			Found.Label = "StringInoutMutated";
			Items.Add("StringInoutA", Found);
		}
		Items.Add("StringInoutB", MakeValue(232, "StringInoutAdded"));
		StringStructInoutResultItems = Items;
		FDelegateKeyValueMapValue Mutated;
		StringStructInoutPreserved = Items.Find("StringInoutA", Mutated) && Mutated.Score == 331 && Mutated.Label == "StringInoutMutated";
		return Items.Num() + Mutated.Score;
	}

	UFUNCTION()
	TMap<FString, FDelegateKeyValueMapValue> HandleStringStructReturn()
	{
		TMap<FString, FDelegateKeyValueMapValue> Items;
		Items.Add("StringReturnA", MakeValue(241, "StringReturnA"));
		Items.Add("StringReturnB", MakeValue(242, "StringReturnB"));
		return Items;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		NameStructValueSignal.BindUFunction(this, n"HandleNameStructValue");
		NameStructInSignal.BindUFunction(this, n"HandleNameStructIn");
		NameStructOutSignal.BindUFunction(this, n"HandleNameStructOut");
		NameStructInoutSignal.BindUFunction(this, n"HandleNameStructInout");
		NameStructReturnSignal.BindUFunction(this, n"HandleNameStructReturn");

		TMap<FName, FDelegateKeyValueMapValue> NameStructValueItems;
		NameStructValueItems.Add(n"NameValueA", MakeValue(101, "NameValueA"));
		NameStructValueItems.Add(n"NameValueB", MakeValue(102, "NameValueB"));
		NameStructValueResult = NameStructValueSignal.Execute(NameStructValueItems);

		TMap<FName, FDelegateKeyValueMapValue> NameStructInItems;
		NameStructInItems.Add(n"NameInA", MakeValue(111, "NameInA"));
		NameStructInItems.Add(n"NameInB", MakeValue(112, "NameInB"));
		NameStructInResult = NameStructInSignal.Execute(NameStructInItems);

		NameStructOutSignal.Execute(NameStructOutResult);
		FDelegateKeyValueMapValue NameStructOutFound;
		NameStructOutPreserved =
			NameStructOutResult.Find(n"NameOutB", NameStructOutFound)
			&& NameStructOutFound.Score == 122
			&& NameStructOutFound.Label == "NameOutB";

		NameStructInoutResultItems.Add(n"NameInoutA", MakeValue(131, "NameInoutA"));
		NameStructInoutResult = NameStructInoutSignal.Execute(NameStructInoutResultItems);

		NameStructReturnResult = NameStructReturnSignal.Execute();
		FDelegateKeyValueMapValue NameStructReturnFound;
		NameStructReturnPreserved =
			NameStructReturnResult.Find(n"NameReturnB", NameStructReturnFound)
			&& NameStructReturnFound.Score == 142
			&& NameStructReturnFound.Label == "NameReturnB";

		StringStructValueSignal.BindUFunction(this, n"HandleStringStructValue");
		StringStructInSignal.BindUFunction(this, n"HandleStringStructIn");
		StringStructOutSignal.BindUFunction(this, n"HandleStringStructOut");
		StringStructInoutSignal.BindUFunction(this, n"HandleStringStructInout");
		StringStructReturnSignal.BindUFunction(this, n"HandleStringStructReturn");

		TMap<FString, FDelegateKeyValueMapValue> StringStructValueItems;
		StringStructValueItems.Add("StringValueA", MakeValue(201, "StringValueA"));
		StringStructValueItems.Add("StringValueB", MakeValue(202, "StringValueB"));
		StringStructValueResult = StringStructValueSignal.Execute(StringStructValueItems);

		TMap<FString, FDelegateKeyValueMapValue> StringStructInItems;
		StringStructInItems.Add("StringInA", MakeValue(211, "StringInA"));
		StringStructInItems.Add("StringInB", MakeValue(212, "StringInB"));
		StringStructInResult = StringStructInSignal.Execute(StringStructInItems);

		StringStructOutSignal.Execute(StringStructOutResult);
		FDelegateKeyValueMapValue StringStructOutFound;
		StringStructOutPreserved =
			StringStructOutResult.Find("StringOutB", StringStructOutFound)
			&& StringStructOutFound.Score == 222
			&& StringStructOutFound.Label == "StringOutB";

		StringStructInoutResultItems.Add("StringInoutA", MakeValue(231, "StringInoutA"));
		StringStructInoutResult = StringStructInoutSignal.Execute(StringStructInoutResultItems);

		StringStructReturnResult = StringStructReturnSignal.Execute();
		FDelegateKeyValueMapValue StringStructReturnFound;
		StringStructReturnPreserved =
			StringStructReturnResult.Find("StringReturnB", StringStructReturnFound)
			&& StringStructReturnFound.Score == 242
			&& StringStructReturnFound.Label == "StringReturnB";
	}
}

int Observe_NameStructValueResult_DefaultZero(ACoverageStructMapKeyValueDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_10 setup: required Actor is null");
	}
	return Actor.NameStructValueResult;
}

int Observe_EmptyNameMap_DefaultNum()
{
	TMap<FName, FDelegateKeyValueMapValue> Items;
	return Items.Num();
}

bool Observe_ValueObject_NullBoundary()
{
	UCoverageStructDelegateMapValueObject Object = nullptr;
	return Object == nullptr;
}
