// Theme: Feature.Delegates. Positive block 3: struct-float map handlers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructExtendedMapDelegatePermutationMatrix lines 6829-6884.
// Isolation=none: wrap HandleStructFloat* with key/value types. Oracle: HandleStructFloatValue
// preserves 302.5f; inout mutates 331.5f -> 431.5f.
// Extra: empty TMap Num 0; 0.0f key miss. DefaultSafe.

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

UCLASS()
class ACoverageStructExtendedMapDelegateActor : AActor
{
	UPROPERTY()
	bool StructFloatValuePreserved = false;
	UPROPERTY()
	bool StructFloatInPreserved = false;
	UPROPERTY()
	bool StructFloatInoutPreserved = false;
	UPROPERTY()
	TMap<FDelegateExtendedMapKey, float> StructFloatInoutResultItems;

	FDelegateExtendedMapKey MakeKey(int ID, FName Tag)
	{
		FDelegateExtendedMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	UFUNCTION()
	int HandleStructFloatValue(TMap<FDelegateExtendedMapKey, float> Items)
	{
		float Found = 0.0f;
		StructFloatValuePreserved =
			Items.Find(MakeKey(301, n"StructFloatValueB"), Found)
			&& Found == 302.5f;
		return Items.Num();
	}

	UFUNCTION()
	int HandleStructFloatIn(const TMap<FDelegateExtendedMapKey, float>&in Items)
	{
		float Found = 0.0f;
		StructFloatInPreserved =
			Items.Find(MakeKey(311, n"StructFloatInB"), Found)
			&& Found == 312.5f;
		return Items.Num() + 30;
	}

	UFUNCTION()
	void HandleStructFloatOut(TMap<FDelegateExtendedMapKey, float>&out Items)
	{
		Items.Add(MakeKey(320, n"StructFloatOutA"), 321.5f);
		Items.Add(MakeKey(321, n"StructFloatOutB"), 322.5f);
	}

	UFUNCTION()
	int HandleStructFloatInout(TMap<FDelegateExtendedMapKey, float>&inout Items)
	{
		FDelegateExtendedMapKey Existing = MakeKey(330, n"StructFloatInoutA");
		float Found = 0.0f;
		if (Items.Find(Existing, Found))
		{
			Items.Add(Existing, Found + 100.0f);
		}
		Items.Add(MakeKey(331, n"StructFloatInoutB"), 332.5f);
		StructFloatInoutResultItems = Items;
		float Mutated = 0.0f;
		StructFloatInoutPreserved =
			Items.Find(Existing, Mutated)
			&& Mutated == 431.5f;
		return Items.Num() + int(Mutated);
	}

	UFUNCTION()
	TMap<FDelegateExtendedMapKey, float> HandleStructFloatReturn()
	{
		TMap<FDelegateExtendedMapKey, float> Items;
		Items.Add(MakeKey(340, n"StructFloatReturnA"), 341.5f);
		Items.Add(MakeKey(341, n"StructFloatReturnB"), 342.5f);
		return Items;
	}
}

int Observe_EmptyFloatMap_DefaultNum()
{
	TMap<FDelegateExtendedMapKey, float> Items;
	return Items.Num();
}

int Observe_MakeKey_ZeroBoundary(ACoverageStructExtendedMapDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructExtendedMapDelegatePermutationMatrix_03 setup: required Actor is null");
	}
	FDelegateExtendedMapKey Key = Actor.MakeKey(0, n"");
	return Key.ID;
}

bool Observe_ZeroKey_MissingBoundary()
{
	TMap<FDelegateExtendedMapKey, float> Items;
	FDelegateExtendedMapKey Zero;
	float Found = 0.0f;
	return !Items.Find(Zero, Found) && Found == 0.0f;
}
