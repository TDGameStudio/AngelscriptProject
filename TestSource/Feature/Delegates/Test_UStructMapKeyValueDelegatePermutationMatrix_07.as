// Theme: Feature.Delegates. Positive block 7: name-struct and string-struct handlers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 7635-7752.
// Isolation=none: wrap HandleNameStruct* / HandleStringStruct* with value type and flags.
// Oracle: HandleNameStructValue preserves Score 102; inout mutates 131->231.
// Extra: empty TMap Num 0; missing name Find false. DefaultSafe.

USTRUCT(BlueprintType)
struct FDelegateKeyValueMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	UPROPERTY()
	bool NameStructValuePreserved = false;
	UPROPERTY()
	bool NameStructInPreserved = false;
	UPROPERTY()
	bool NameStructInoutPreserved = false;
	UPROPERTY()
	TMap<FName, FDelegateKeyValueMapValue> NameStructInoutResultItems;
	UPROPERTY()
	bool StringStructValuePreserved = false;
	UPROPERTY()
	bool StringStructInPreserved = false;
	UPROPERTY()
	bool StringStructInoutPreserved = false;
	UPROPERTY()
	TMap<FString, FDelegateKeyValueMapValue> StringStructInoutResultItems;

	FDelegateKeyValueMapValue MakeValue(int Score, FString Label)
	{
		FDelegateKeyValueMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	UFUNCTION()
	int HandleNameStructValue(TMap<FName, FDelegateKeyValueMapValue> Items)
	{
		FDelegateKeyValueMapValue Found;
		NameStructValuePreserved =
			Items.Find(n"NameValueB", Found)
			&& Found.Score == 102
			&& Found.Label == "NameValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleNameStructIn(const TMap<FName, FDelegateKeyValueMapValue>&in Items)
	{
		FDelegateKeyValueMapValue Found;
		NameStructInPreserved =
			Items.Find(n"NameInB", Found)
			&& Found.Score == 112
			&& Found.Label == "NameInB";
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
		NameStructInoutPreserved =
			Items.Find(n"NameInoutA", Mutated)
			&& Mutated.Score == 231
			&& Mutated.Label == "NameInoutMutated";
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
		StringStructValuePreserved =
			Items.Find("StringValueB", Found)
			&& Found.Score == 202
			&& Found.Label == "StringValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleStringStructIn(const TMap<FString, FDelegateKeyValueMapValue>&in Items)
	{
		FDelegateKeyValueMapValue Found;
		StringStructInPreserved =
			Items.Find("StringInB", Found)
			&& Found.Score == 212
			&& Found.Label == "StringInB";
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
		StringStructInoutPreserved =
			Items.Find("StringInoutA", Mutated)
			&& Mutated.Score == 331
			&& Mutated.Label == "StringInoutMutated";
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
}

int Observe_EmptyNameMap_DefaultNum()
{
	TMap<FName, FDelegateKeyValueMapValue> Items;
	return Items.Num();
}

int Observe_MakeValue_ZeroBoundary(ACoverageStructMapKeyValueDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_07 setup: required Actor is null");
	}
	FDelegateKeyValueMapValue Value = Actor.MakeValue(0, "");
	return Value.Score;
}

bool Observe_MissingName_FindBoundary()
{
	TMap<FName, FDelegateKeyValueMapValue> Items;
	FDelegateKeyValueMapValue Found;
	return !Items.Find(n"NameValueB", Found) && Found.Score == 0;
}
