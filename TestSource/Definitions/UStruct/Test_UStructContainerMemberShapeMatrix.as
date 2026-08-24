// Theme: Definitions.UStruct. WorldStory: USTRUCT members that are TArray/TMap/TSet of structs.
// C++: AngelscriptCoverageUStructTests.cpp::UStructContainerMemberShapeMatrix spawn + BeginPlay.
// Oracle: KeyToScoreFindWorked true Found 300, KeyToValueFoundScore 400, KeySetContainsWorked true,
// KeySetRemoveWorked true. Extra: empty Data containers before BeginPlay. FixtureIsolated.

USTRUCT(BlueprintType)
struct FStructMemberContainerKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FStructMemberContainerKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 719) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FStructMemberContainerValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

USTRUCT(BlueprintType)
struct FStructContainerOwner
{
	UPROPERTY()
	TArray<FStructMemberContainerValue> Values;

	UPROPERTY()
	TMap<int, FStructMemberContainerValue> IntToValue;

	UPROPERTY()
	TMap<FStructMemberContainerKey, int> KeyToScore;

	UPROPERTY()
	TMap<FStructMemberContainerKey, FStructMemberContainerValue> KeyToValue;

	UPROPERTY()
	TSet<FStructMemberContainerKey> KeySet;
}

UCLASS()
class ACoverageStructContainerMemberActor : AActor
{
	UPROPERTY()
	FStructContainerOwner Data;

	UPROPERTY()
	bool KeyToScoreFindWorked = false;

	UPROPERTY()
	int KeyToScoreFound = 0;

	UPROPERTY()
	bool KeyToValueFindWorked = false;

	UPROPERTY()
	int KeyToValueFoundScore = 0;

	UPROPERTY()
	bool KeySetContainsWorked = false;

	UPROPERTY()
	bool KeySetRemoveWorked = false;

	FStructMemberContainerKey MakeKey(int ID, FName Tag)
	{
		FStructMemberContainerKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	FStructMemberContainerValue MakeValue(int Score, FString Label)
	{
		FStructMemberContainerValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Data.Values.Add(MakeValue(10, "ArrayA"));
		Data.Values.Add(MakeValue(11, "ArrayB"));

		Data.IntToValue.Add(20, MakeValue(20, "MapValueA"));
		Data.IntToValue.Add(21, MakeValue(21, "MapValueB"));

		FStructMemberContainerKey Alpha = MakeKey(30, n"Alpha");
		FStructMemberContainerKey AlphaDuplicate = MakeKey(30, n"Alpha");
		FStructMemberContainerKey Beta = MakeKey(31, n"Beta");

		Data.KeyToScore.Add(Alpha, 300);
		Data.KeyToScore.Add(Beta, 310);
		KeyToScoreFindWorked = Data.KeyToScore.Find(AlphaDuplicate, KeyToScoreFound);

		Data.KeyToValue.Add(Alpha, MakeValue(400, "StructMapA"));
		Data.KeyToValue.Add(Beta, MakeValue(410, "StructMapB"));
		FStructMemberContainerValue FoundValue;
		KeyToValueFindWorked = Data.KeyToValue.Find(AlphaDuplicate, FoundValue);
		KeyToValueFoundScore = FoundValue.Score;

		Data.KeySet.Add(Alpha);
		Data.KeySet.Add(AlphaDuplicate);
		Data.KeySet.Add(Beta);
		KeySetContainsWorked = Data.KeySet.Contains(AlphaDuplicate) && Data.KeySet.Num() == 2;
		KeySetRemoveWorked = Data.KeySet.Remove(AlphaDuplicate) && !Data.KeySet.Contains(Alpha) && Data.KeySet.Contains(Beta);
	}
}

bool Observe_ContainerMember_DefaultEmpty(ACoverageStructContainerMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructContainerMemberShapeMatrix setup: required Actor is null");
	}
	return Actor.Data.Values.Num() == 0
		&& Actor.Data.IntToValue.Num() == 0
		&& Actor.Data.KeyToScore.Num() == 0
		&& Actor.Data.KeyToValue.Num() == 0
		&& Actor.Data.KeySet.Num() == 0
		&& !Actor.KeyToScoreFindWorked
		&& Actor.KeyToScoreFound == 0;
}

bool Observe_ContainerMember_NominalBeginPlay(ACoverageStructContainerMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructContainerMemberShapeMatrix setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.Data.Values.Num() == 2
		&& Actor.Data.Values[0].Score == 10
		&& Actor.Data.IntToValue.Num() == 2
		&& Actor.KeyToScoreFindWorked
		&& Actor.KeyToScoreFound == 300
		&& Actor.KeyToValueFindWorked
		&& Actor.KeyToValueFoundScore == 400
		&& Actor.KeySetContainsWorked
		&& Actor.KeySetRemoveWorked
		&& Actor.Data.KeySet.Num() == 1;
}

bool Observe_ContainerMember_ZeroKeyBoundary(ACoverageStructContainerMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructContainerMemberShapeMatrix setup: required Actor is null");
	}
	FStructMemberContainerKey Zero = Actor.MakeKey(0, n"");
	FStructMemberContainerValue Empty = Actor.MakeValue(0, "");
	return Zero.ID == 0 && Empty.Score == 0 && Empty.Label.Len() == 0 && Zero.Hash() == uint32(0);
}
