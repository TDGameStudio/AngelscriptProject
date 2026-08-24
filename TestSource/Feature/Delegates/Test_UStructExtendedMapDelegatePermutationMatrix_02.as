// Theme: Feature.Delegates. Positive block 2: bool-struct and struct-bool handlers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructExtendedMapDelegatePermutationMatrix lines 6699-6828.
// Isolation=none: wrap MakeKey/MakeValue and handlers. Oracle: HandleBoolStructValue
// preserves Score 102 / "BoolValueFalse"; HandleStructBoolValue !Found for false value.
// Extra: empty map Num 0; false-key lookup. DefaultSafe.

USTRUCT(BlueprintType)
struct FDelegateExtendedMapKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FDelegateExtendedMapKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 887) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FDelegateExtendedMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructExtendedMapDelegateActor : AActor
{
	UPROPERTY()
	bool BoolStructValuePreserved = false;
	UPROPERTY()
	bool BoolStructInPreserved = false;
	UPROPERTY()
	bool BoolStructInoutPreserved = false;
	UPROPERTY()
	int BoolStructInoutResult = 0;
	UPROPERTY()
	TMap<bool, FDelegateExtendedMapValue> BoolStructInoutResultItems;
	UPROPERTY()
	bool StructBoolValuePreserved = false;
	UPROPERTY()
	bool StructBoolInPreserved = false;
	UPROPERTY()
	bool StructBoolInoutPreserved = false;
	UPROPERTY()
	TMap<FDelegateExtendedMapKey, bool> StructBoolInoutResultItems;

	FDelegateExtendedMapKey MakeKey(int ID, FName Tag)
	{
		FDelegateExtendedMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	FDelegateExtendedMapValue MakeValue(int Score, FString Label)
	{
		FDelegateExtendedMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	UFUNCTION()
	int HandleBoolStructValue(TMap<bool, FDelegateExtendedMapValue> Items)
	{
		FDelegateExtendedMapValue Found;
		BoolStructValuePreserved =
			Items.Find(false, Found)
			&& Found.Score == 102
			&& Found.Label == "BoolValueFalse";
		return Items.Num();
	}

	UFUNCTION()
	int HandleBoolStructIn(const TMap<bool, FDelegateExtendedMapValue>&in Items)
	{
		FDelegateExtendedMapValue Found;
		BoolStructInPreserved =
			Items.Find(true, Found)
			&& Found.Score == 111
			&& Found.Label == "BoolInTrue";
		return Items.Num() + 10;
	}

	UFUNCTION()
	void HandleBoolStructOut(TMap<bool, FDelegateExtendedMapValue>&out Items)
	{
		Items.Add(true, MakeValue(121, "BoolOutTrue"));
		Items.Add(false, MakeValue(122, "BoolOutFalse"));
	}

	UFUNCTION()
	int HandleBoolStructInout(TMap<bool, FDelegateExtendedMapValue>&inout Items)
	{
		FDelegateExtendedMapValue Found;
		if (Items.Find(true, Found))
		{
			Found.Score += 100;
			Found.Label = "BoolInoutMutated";
			Items.Add(true, Found);
		}
		Items.Add(false, MakeValue(132, "BoolInoutAdded"));
		BoolStructInoutResultItems = Items;
		FDelegateExtendedMapValue Mutated;
		BoolStructInoutPreserved =
			Items.Find(true, Mutated)
			&& Mutated.Score == 231
			&& Mutated.Label == "BoolInoutMutated";
		return Items.Num() + Mutated.Score;
	}

	UFUNCTION()
	TMap<bool, FDelegateExtendedMapValue> HandleBoolStructReturn()
	{
		TMap<bool, FDelegateExtendedMapValue> Items;
		Items.Add(true, MakeValue(141, "BoolReturnTrue"));
		Items.Add(false, MakeValue(142, "BoolReturnFalse"));
		return Items;
	}

	UFUNCTION()
	int HandleStructBoolValue(TMap<FDelegateExtendedMapKey, bool> Items)
	{
		bool Found = true;
		StructBoolValuePreserved =
			Items.Find(MakeKey(201, n"StructBoolValueB"), Found)
			&& !Found;
		return Items.Num();
	}

	UFUNCTION()
	int HandleStructBoolIn(const TMap<FDelegateExtendedMapKey, bool>&in Items)
	{
		bool Found = false;
		StructBoolInPreserved =
			Items.Find(MakeKey(211, n"StructBoolInB"), Found)
			&& Found;
		return Items.Num() + 20;
	}

	UFUNCTION()
	void HandleStructBoolOut(TMap<FDelegateExtendedMapKey, bool>&out Items)
	{
		Items.Add(MakeKey(220, n"StructBoolOutA"), true);
		Items.Add(MakeKey(221, n"StructBoolOutB"), false);
	}

	UFUNCTION()
	int HandleStructBoolInout(TMap<FDelegateExtendedMapKey, bool>&inout Items)
	{
		FDelegateExtendedMapKey Existing = MakeKey(230, n"StructBoolInoutA");
		bool Found = false;
		if (Items.Find(Existing, Found))
		{
			Items.Add(Existing, !Found);
		}
		Items.Add(MakeKey(231, n"StructBoolInoutB"), true);
		StructBoolInoutResultItems = Items;
		bool Mutated = false;
		StructBoolInoutPreserved =
			Items.Find(Existing, Mutated)
			&& !Mutated;
		return Items.Num() + (Mutated ? 40 : 50);
	}

	UFUNCTION()
	TMap<FDelegateExtendedMapKey, bool> HandleStructBoolReturn()
	{
		TMap<FDelegateExtendedMapKey, bool> Items;
		Items.Add(MakeKey(240, n"StructBoolReturnA"), true);
		Items.Add(MakeKey(241, n"StructBoolReturnB"), false);
		return Items;
	}
}

int Observe_EmptyBoolMap_DefaultNum()
{
	TMap<bool, FDelegateExtendedMapValue> Items;
	return Items.Num();
}

int Observe_MakeValue_ZeroBoundary(ACoverageStructExtendedMapDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructExtendedMapDelegatePermutationMatrix_02 setup: required Actor is null");
	}
	FDelegateExtendedMapValue Value = Actor.MakeValue(0, "");
	return Value.Score + Value.Label.Len();
}

bool Observe_FalseKey_MissingBoundary()
{
	TMap<bool, FDelegateExtendedMapValue> Items;
	FDelegateExtendedMapValue Found;
	return !Items.Find(false, Found) && Found.Score == 0;
}
