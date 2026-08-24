// Theme: Definitions.UStruct. WorldStory: hashable struct map keys and set elements.
// C++: AngelscriptCoverageUStructTests.cpp::UStructHashableMapKeyAndSetElement spawn + BeginPlay.
// Oracle: MapContainsOriginal/MapFindOriginal/MapOverwriteWorked true, MapFoundValue 10,
// SetDedupWorked true, SetRemoveWorked true. Extra: empty map/set before BeginPlay.
// FixtureIsolated.

USTRUCT(BlueprintType)
struct FHashableStructKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FHashableStructKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 31) + Tag.GetHash();
	}
}

UCLASS()
class ACoverageStructHashableContainerActor : AActor
{
	UPROPERTY()
	TMap<FHashableStructKey, int> StructToIntMap;

	UPROPERTY()
	TSet<FHashableStructKey> StructSet;

	UPROPERTY()
	bool MapContainsOriginal = false;

	UPROPERTY()
	bool MapFindOriginal = false;

	UPROPERTY()
	int MapFoundValue = 0;

	UPROPERTY()
	bool MapOverwriteWorked = false;

	UPROPERTY()
	bool SetContainsOriginal = false;

	UPROPERTY()
	bool SetDedupWorked = false;

	UPROPERTY()
	bool SetRemoveWorked = false;

	FHashableStructKey MakeKey(int ID, FName Tag)
	{
		FHashableStructKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FHashableStructKey Alpha = MakeKey(1, n"Alpha");
		FHashableStructKey AlphaDuplicate = MakeKey(1, n"Alpha");
		FHashableStructKey Beta = MakeKey(2, n"Beta");

		StructToIntMap.Add(Alpha, 10);
		StructToIntMap.Add(Beta, 20);
		MapContainsOriginal = StructToIntMap.Contains(AlphaDuplicate);
		MapFindOriginal = StructToIntMap.Find(AlphaDuplicate, MapFoundValue);
		StructToIntMap.Add(AlphaDuplicate, 15);
		MapOverwriteWorked = StructToIntMap[Alpha] == 15;

		StructSet.Add(Alpha);
		StructSet.Add(AlphaDuplicate);
		StructSet.Add(Beta);
		SetContainsOriginal = StructSet.Contains(AlphaDuplicate);
		SetDedupWorked = StructSet.Num() == 2;
		SetRemoveWorked = StructSet.Remove(AlphaDuplicate) && !StructSet.Contains(Alpha);
	}
}

bool Observe_Hashable_DefaultEmpty(ACoverageStructHashableContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructHashableMapKeyAndSetElement setup: required Actor is null");
	}
	return Actor.StructToIntMap.Num() == 0
		&& Actor.StructSet.Num() == 0
		&& !Actor.MapContainsOriginal
		&& Actor.MapFoundValue == 0;
}

bool Observe_Hashable_NominalBeginPlay(ACoverageStructHashableContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructHashableMapKeyAndSetElement setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.StructToIntMap.Num() == 2
		&& Actor.MapContainsOriginal
		&& Actor.MapFindOriginal
		&& Actor.MapFoundValue == 10
		&& Actor.MapOverwriteWorked
		&& Actor.StructSet.Num() == 1
		&& Actor.SetContainsOriginal
		&& Actor.SetDedupWorked
		&& Actor.SetRemoveWorked;
}

bool Observe_Hashable_ZeroKeyBoundary(ACoverageStructHashableContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructHashableMapKeyAndSetElement setup: required Actor is null");
	}
	FHashableStructKey Zero = Actor.MakeKey(0, n"");
	return Zero.ID == 0 && Zero.Tag == n"" && Zero.Hash() == uint32(0);
}
