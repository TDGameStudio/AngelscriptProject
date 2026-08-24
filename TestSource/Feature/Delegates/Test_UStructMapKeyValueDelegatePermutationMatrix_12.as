// Theme: Feature.Delegates. Positive block 12: BeginPlay struct-string map executes.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 8221-8253.
// Isolation=none: wrap the BeginPlay statements with struct-string signals, MakeKey, handlers.
// Oracle: StructStringValueResult 2; StructStringOutB preserved. Extra: empty TMap Num 0;
// zero-key miss. DefaultSafe. Keep StructStringValueSignal.

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

delegate int FStructStringMapValueSignal(TMap<FDelegateKeyValueMapKey, FString> Items);
delegate int FStructStringMapInSignal(const TMap<FDelegateKeyValueMapKey, FString>&in Items);
delegate void FStructStringMapOutSignal(TMap<FDelegateKeyValueMapKey, FString>&out Items);
delegate int FStructStringMapInoutSignal(TMap<FDelegateKeyValueMapKey, FString>&inout Items);
delegate TMap<FDelegateKeyValueMapKey, FString> FStructStringMapReturnSignal();

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	UPROPERTY()
	FStructStringMapValueSignal StructStringValueSignal;
	UPROPERTY()
	FStructStringMapInSignal StructStringInSignal;
	UPROPERTY()
	FStructStringMapOutSignal StructStringOutSignal;
	UPROPERTY()
	FStructStringMapInoutSignal StructStringInoutSignal;
	UPROPERTY()
	FStructStringMapReturnSignal StructStringReturnSignal;

	UPROPERTY()
	int StructStringValueResult = 0;
	UPROPERTY()
	int StructStringInResult = 0;
	UPROPERTY()
	int StructStringInoutResult = 0;
	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FString> StructStringOutResult;
	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FString> StructStringInoutResultItems;
	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FString> StructStringReturnResult;
	UPROPERTY()
	bool StructStringValuePreserved = false;
	UPROPERTY()
	bool StructStringInPreserved = false;
	UPROPERTY()
	bool StructStringOutPreserved = false;
	UPROPERTY()
	bool StructStringInoutPreserved = false;
	UPROPERTY()
	bool StructStringReturnPreserved = false;

	FDelegateKeyValueMapKey MakeKey(int ID, FName Tag)
	{
		FDelegateKeyValueMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	UFUNCTION()
	int HandleStructStringValue(TMap<FDelegateKeyValueMapKey, FString> Items)
	{
		FString Found;
		StructStringValuePreserved = Items.Find(MakeKey(301, n"StructStringValueB"), Found) && Found == "StructStringValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleStructStringIn(const TMap<FDelegateKeyValueMapKey, FString>&in Items)
	{
		FString Found;
		StructStringInPreserved = Items.Find(MakeKey(311, n"StructStringInB"), Found) && Found == "StructStringInB";
		return Items.Num() + 30;
	}

	UFUNCTION()
	void HandleStructStringOut(TMap<FDelegateKeyValueMapKey, FString>&out Items)
	{
		Items.Add(MakeKey(320, n"StructStringOutA"), "StructStringOutA");
		Items.Add(MakeKey(321, n"StructStringOutB"), "StructStringOutB");
	}

	UFUNCTION()
	int HandleStructStringInout(TMap<FDelegateKeyValueMapKey, FString>&inout Items)
	{
		FDelegateKeyValueMapKey Existing = MakeKey(330, n"StructStringInoutA");
		FString Found;
		if (Items.Find(Existing, Found))
		{
			Items.Add(Existing, "StructStringInoutMutated");
		}
		Items.Add(MakeKey(331, n"StructStringInoutB"), "StructStringInoutAdded");
		StructStringInoutResultItems = Items;
		FString Mutated;
		StructStringInoutPreserved = Items.Find(Existing, Mutated) && Mutated == "StructStringInoutMutated";
		return Items.Num() + 40;
	}

	UFUNCTION()
	TMap<FDelegateKeyValueMapKey, FString> HandleStructStringReturn()
	{
		TMap<FDelegateKeyValueMapKey, FString> Items;
		Items.Add(MakeKey(340, n"StructStringReturnA"), "StructStringReturnA");
		Items.Add(MakeKey(341, n"StructStringReturnB"), "StructStringReturnB");
		return Items;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StructStringValueSignal.BindUFunction(this, n"HandleStructStringValue");
		StructStringInSignal.BindUFunction(this, n"HandleStructStringIn");
		StructStringOutSignal.BindUFunction(this, n"HandleStructStringOut");
		StructStringInoutSignal.BindUFunction(this, n"HandleStructStringInout");
		StructStringReturnSignal.BindUFunction(this, n"HandleStructStringReturn");

		TMap<FDelegateKeyValueMapKey, FString> StructStringValueItems;
		StructStringValueItems.Add(MakeKey(300, n"StructStringValueA"), "StructStringValueA");
		StructStringValueItems.Add(MakeKey(301, n"StructStringValueB"), "StructStringValueB");
		StructStringValueResult = StructStringValueSignal.Execute(StructStringValueItems);

		TMap<FDelegateKeyValueMapKey, FString> StructStringInItems;
		StructStringInItems.Add(MakeKey(310, n"StructStringInA"), "StructStringInA");
		StructStringInItems.Add(MakeKey(311, n"StructStringInB"), "StructStringInB");
		StructStringInResult = StructStringInSignal.Execute(StructStringInItems);

		StructStringOutSignal.Execute(StructStringOutResult);
		FString StructStringOutFound;
		StructStringOutPreserved =
			StructStringOutResult.Find(MakeKey(321, n"StructStringOutB"), StructStringOutFound)
			&& StructStringOutFound == "StructStringOutB";

		StructStringInoutResultItems.Add(MakeKey(330, n"StructStringInoutA"), "StructStringInoutA");
		StructStringInoutResult = StructStringInoutSignal.Execute(StructStringInoutResultItems);

		StructStringReturnResult = StructStringReturnSignal.Execute();
		FString StructStringReturnFound;
		StructStringReturnPreserved =
			StructStringReturnResult.Find(MakeKey(341, n"StructStringReturnB"), StructStringReturnFound)
			&& StructStringReturnFound == "StructStringReturnB";
	}
}

int Observe_StructStringValueResult_DefaultZero(ACoverageStructMapKeyValueDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_12 setup: required Actor is null");
	}
	return Actor.StructStringValueResult;
}

int Observe_EmptyStringMap_DefaultNum()
{
	TMap<FDelegateKeyValueMapKey, FString> Items;
	return Items.Num();
}

bool Observe_ZeroKey_MissingBoundary()
{
	TMap<FDelegateKeyValueMapKey, FString> Items;
	FDelegateKeyValueMapKey Zero;
	FString Found;
	return !Items.Find(Zero, Found) && Found.Len() == 0;
}
