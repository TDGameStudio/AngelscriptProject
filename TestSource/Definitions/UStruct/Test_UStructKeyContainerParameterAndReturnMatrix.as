// Theme: Definitions.UStruct. WorldStory: TMap/TSet of hashable struct keys as parameters and returns.
// C++: AngelscriptCoverageUStructTests.cpp::UStructKeyContainerParameterAndReturnMatrix.
// Oracle: CountStructKeyMapValue Contains key 11; ReturnStructValueMap score 441; set out two keys.
// Extra: empty map/set counts 0. FixtureIsolated.

USTRUCT(BlueprintType)
struct FStructContainerKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FStructContainerKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 313) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FStructContainerValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructKeyContainerMatrixActor : AActor
{
	UPROPERTY()
	int StructKeyMapValueCount = 0;

	UPROPERTY()
	int StructKeyMapInCount = 0;

	UPROPERTY()
	TMap<FStructContainerKey, int> StructKeyMapInout;

	UPROPERTY()
	TMap<FStructContainerKey, int> StructKeyMapOut;

	UPROPERTY()
	TMap<FStructContainerKey, int> StructKeyMapReturn;

	UPROPERTY()
	bool StructKeyMapValueContains = false;

	UPROPERTY()
	bool StructKeyMapInContains = false;

	UPROPERTY()
	bool StructKeyMapInoutMutated = false;

	UPROPERTY()
	bool StructValueMapReturnContains = false;

	UPROPERTY()
	int StructValueMapReturnScore = 0;

	UPROPERTY()
	int StructSetValueCount = 0;

	UPROPERTY()
	int StructSetInCount = 0;

	UPROPERTY()
	TSet<FStructContainerKey> StructSetInout;

	UPROPERTY()
	TSet<FStructContainerKey> StructSetOut;

	UPROPERTY()
	TSet<FStructContainerKey> StructSetReturn;

	UPROPERTY()
	bool StructSetValueContains = false;

	UPROPERTY()
	bool StructSetInContains = false;

	UPROPERTY()
	bool StructSetInoutMutated = false;

	FStructContainerKey MakeKey(int ID, FName Tag)
	{
		FStructContainerKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	FStructContainerValue MakeValue(int Score, FString Label)
	{
		FStructContainerValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructKeyMapValue(TMap<FStructContainerKey, int> Items)
	{
		StructKeyMapValueCount = Items.Num();
		StructKeyMapValueContains = Items.Contains(MakeKey(11, n"MapValueB"));
		return StructKeyMapValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructKeyMapIn(const TMap<FStructContainerKey, int>&in Items)
	{
		StructKeyMapInCount = Items.Num();
		StructKeyMapInContains = Items.Contains(MakeKey(13, n"MapInB"));
		return StructKeyMapInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillStructKeyMapOut(TMap<FStructContainerKey, int>&out Items)
	{
		Items.Add(MakeKey(14, n"MapOutA"), 114);
		Items.Add(MakeKey(15, n"MapOutB"), 115);
		StructKeyMapOut = Items;
	}

	UFUNCTION(BlueprintCallable)
	void MutateStructKeyMapInout(TMap<FStructContainerKey, int>&inout Items)
	{
		FStructContainerKey Existing = MakeKey(20, n"MapInoutA");
		Items.Remove(Existing);
		Items.Add(Existing, 220);
		Items.Add(MakeKey(21, n"MapInoutB"), 221);
		StructKeyMapInout = Items;
		int MutatedValue = 0;
		StructKeyMapInoutMutated = Items.Find(Existing, MutatedValue) && MutatedValue == 220;
	}

	UFUNCTION(BlueprintCallable)
	TMap<FStructContainerKey, int> ReturnStructKeyMap()
	{
		TMap<FStructContainerKey, int> Items;
		Items.Add(MakeKey(30, n"MapReturnA"), 330);
		Items.Add(MakeKey(31, n"MapReturnB"), 331);
		return Items;
	}

	UFUNCTION(BlueprintCallable)
	TMap<int, FStructContainerValue> ReturnStructValueMap()
	{
		TMap<int, FStructContainerValue> Items;
		Items.Add(40, MakeValue(440, "MapValueReturnA"));
		Items.Add(41, MakeValue(441, "MapValueReturnB"));

		FStructContainerValue Found;
		StructValueMapReturnContains = Items.Find(41, Found);
		StructValueMapReturnScore = Found.Score;
		return Items;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructSetValue(TSet<FStructContainerKey> Items)
	{
		StructSetValueCount = Items.Num();
		StructSetValueContains = Items.Contains(MakeKey(51, n"SetValueB"));
		return StructSetValueCount;
	}

	UFUNCTION(BlueprintCallable)
	int CountStructSetIn(const TSet<FStructContainerKey>&in Items)
	{
		StructSetInCount = Items.Num();
		StructSetInContains = Items.Contains(MakeKey(53, n"SetInB"));
		return StructSetInCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillStructSetOut(TSet<FStructContainerKey>&out Items)
	{
		Items.Add(MakeKey(54, n"SetOutA"));
		Items.Add(MakeKey(55, n"SetOutB"));
		StructSetOut = Items;
	}

	UFUNCTION(BlueprintCallable)
	void MutateStructSetInout(TSet<FStructContainerKey>&inout Items)
	{
		Items.Remove(MakeKey(60, n"SetInoutA"));
		Items.Add(MakeKey(61, n"SetInoutB"));
		StructSetInout = Items;
		StructSetInoutMutated = !Items.Contains(MakeKey(60, n"SetInoutA")) && Items.Contains(MakeKey(61, n"SetInoutB"));
	}

	UFUNCTION(BlueprintCallable)
	TSet<FStructContainerKey> ReturnStructSet()
	{
		TSet<FStructContainerKey> Items;
		Items.Add(MakeKey(70, n"SetReturnA"));
		Items.Add(MakeKey(71, n"SetReturnB"));
		return Items;
	}
}

bool Observe_KeyContainer_DefaultEmpty(ACoverageStructKeyContainerMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructKeyContainerParameterAndReturnMatrix setup: required Actor is null");
	}
	TMap<FStructContainerKey, int> EmptyMap;
	TSet<FStructContainerKey> EmptySet;
	return Actor.CountStructKeyMapValue(EmptyMap) == 0
		&& !Actor.StructKeyMapValueContains
		&& Actor.CountStructSetValue(EmptySet) == 0
		&& Actor.StructKeyMapOut.Num() == 0
		&& Actor.StructSetOut.Num() == 0;
}

bool Observe_KeyContainer_NominalMapAndSet(ACoverageStructKeyContainerMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructKeyContainerParameterAndReturnMatrix setup: required Actor is null");
	}
	TMap<FStructContainerKey, int> MapValue;
	MapValue.Add(Actor.MakeKey(10, n"MapValueA"), 110);
	MapValue.Add(Actor.MakeKey(11, n"MapValueB"), 111);
	TMap<FStructContainerKey, int> MapIn;
	MapIn.Add(Actor.MakeKey(12, n"MapInA"), 112);
	MapIn.Add(Actor.MakeKey(13, n"MapInB"), 113);
	TMap<FStructContainerKey, int> MapOut;
	Actor.FillStructKeyMapOut(MapOut);
	TMap<FStructContainerKey, int> MapInout;
	MapInout.Add(Actor.MakeKey(20, n"MapInoutA"), 120);
	Actor.MutateStructKeyMapInout(MapInout);
	TMap<int, FStructContainerValue> ValueReturn = Actor.ReturnStructValueMap();
	TSet<FStructContainerKey> SetValue;
	SetValue.Add(Actor.MakeKey(50, n"SetValueA"));
	SetValue.Add(Actor.MakeKey(51, n"SetValueB"));
	TSet<FStructContainerKey> SetInout;
	SetInout.Add(Actor.MakeKey(60, n"SetInoutA"));
	Actor.MutateStructSetInout(SetInout);
	return Actor.CountStructKeyMapValue(MapValue) == 2
		&& Actor.StructKeyMapValueContains
		&& Actor.CountStructKeyMapIn(MapIn) == 2
		&& Actor.StructKeyMapInContains
		&& MapOut.Num() == 2
		&& Actor.StructKeyMapInoutMutated
		&& Actor.StructValueMapReturnContains
		&& Actor.StructValueMapReturnScore == 441
		&& Actor.CountStructSetValue(SetValue) == 2
		&& Actor.StructSetValueContains
		&& Actor.StructSetInoutMutated
		&& ValueReturn.Num() == 2;
}

bool Observe_KeyContainer_ZeroKeyBoundary(ACoverageStructKeyContainerMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructKeyContainerParameterAndReturnMatrix setup: required Actor is null");
	}
	FStructContainerKey Zero = Actor.MakeKey(0, n"");
	TMap<FStructContainerKey, int> Items;
	Items.Add(Zero, 0);
	int Found = -1;
	return Items.Find(Actor.MakeKey(0, n""), Found) && Found == 0;
}
