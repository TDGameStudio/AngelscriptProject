// Theme: Feature.Delegates. Positive block 9: struct-string and struct-name handlers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 7899-8008.
// Isolation=none: wrap HandleStructString* / HandleStructName* with key type and flags.
// Oracle: HandleStructStringValue preserves "StructStringValueB"; HandleStructNameValue
// preserves n"StructNameValueB". Extra: empty TMap Num 0; zero-key miss. DefaultSafe.

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

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	UPROPERTY()
	bool StructStringValuePreserved = false;
	UPROPERTY()
	bool StructStringInPreserved = false;
	UPROPERTY()
	bool StructStringInoutPreserved = false;
	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FString> StructStringInoutResultItems;
	UPROPERTY()
	bool StructNameValuePreserved = false;
	UPROPERTY()
	bool StructNameInPreserved = false;
	UPROPERTY()
	bool StructNameInoutPreserved = false;
	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FName> StructNameInoutResultItems;

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
		StructStringValuePreserved =
			Items.Find(MakeKey(301, n"StructStringValueB"), Found)
			&& Found == "StructStringValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleStructStringIn(const TMap<FDelegateKeyValueMapKey, FString>&in Items)
	{
		FString Found;
		StructStringInPreserved =
			Items.Find(MakeKey(311, n"StructStringInB"), Found)
			&& Found == "StructStringInB";
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
		StructStringInoutPreserved =
			Items.Find(Existing, Mutated)
			&& Mutated == "StructStringInoutMutated";
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

	UFUNCTION()
	int HandleStructNameValue(TMap<FDelegateKeyValueMapKey, FName> Items)
	{
		FName Found;
		StructNameValuePreserved =
			Items.Find(MakeKey(401, n"StructNameValueB"), Found)
			&& Found == n"StructNameValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleStructNameIn(const TMap<FDelegateKeyValueMapKey, FName>&in Items)
	{
		FName Found;
		StructNameInPreserved =
			Items.Find(MakeKey(411, n"StructNameInB"), Found)
			&& Found == n"StructNameInB";
		return Items.Num() + 50;
	}

	UFUNCTION()
	void HandleStructNameOut(TMap<FDelegateKeyValueMapKey, FName>&out Items)
	{
		Items.Add(MakeKey(420, n"StructNameOutA"), n"StructNameOutA");
		Items.Add(MakeKey(421, n"StructNameOutB"), n"StructNameOutB");
	}

	UFUNCTION()
	int HandleStructNameInout(TMap<FDelegateKeyValueMapKey, FName>&inout Items)
	{
		FDelegateKeyValueMapKey Existing = MakeKey(430, n"StructNameInoutA");
		FName Found;
		if (Items.Find(Existing, Found))
		{
			Items.Add(Existing, n"StructNameInoutMutated");
		}
		Items.Add(MakeKey(431, n"StructNameInoutB"), n"StructNameInoutAdded");
		StructNameInoutResultItems = Items;
		FName Mutated;
		StructNameInoutPreserved =
			Items.Find(Existing, Mutated)
			&& Mutated == n"StructNameInoutMutated";
		return Items.Num() + 60;
	}

	UFUNCTION()
	TMap<FDelegateKeyValueMapKey, FName> HandleStructNameReturn()
	{
		TMap<FDelegateKeyValueMapKey, FName> Items;
		Items.Add(MakeKey(440, n"StructNameReturnA"), n"StructNameReturnA");
		Items.Add(MakeKey(441, n"StructNameReturnB"), n"StructNameReturnB");
		return Items;
	}
}

int Observe_EmptyStringMap_DefaultNum()
{
	TMap<FDelegateKeyValueMapKey, FString> Items;
	return Items.Num();
}

int Observe_MakeKey_ZeroBoundary(ACoverageStructMapKeyValueDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_09 setup: required Actor is null");
	}
	FDelegateKeyValueMapKey Key = Actor.MakeKey(0, n"");
	return Key.ID;
}

bool Observe_ZeroKey_MissingBoundary()
{
	TMap<FDelegateKeyValueMapKey, FString> Items;
	FDelegateKeyValueMapKey Zero;
	FString Found;
	return !Items.Find(Zero, Found) && Found.Len() == 0;
}
