/**
 * @version v1
 * @summary A hashable USTRUCT used as a TMap key and TSet element. C++ reads the contains/find/overwrite/dedup/remove flags after BeginPlay.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A hashable USTRUCT used as a TMap key and TSet element. C++ reads the contains/find/overwrite/dedup/remove flags after BeginPlay.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FHashableStructKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers UStruct.UStructHashableMapKeyAndSetElement
	 * @Inputs another FHashableStructKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FHashableStructKey&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 31 plus Tag.GetHash().
	 *
	 * @Covers UStruct.UStructHashableMapKeyAndSetElement
	 * @Inputs none
	 * @Return uint32(ID * 31) + Tag.GetHash()
	 */
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

	/**
	 * Build a hashable key from an id and tag.
	 *
	 * @Covers UStruct.UStructHashableMapKeyAndSetElement
	 * @Inputs ID and Tag
	 * @Return a key holding those fields
	 * @Param ID the key id
	 * @Param Tag the key tag
	 */
	FHashableStructKey MakeKey(int ID, FName Tag)
	{
		FHashableStructKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	/**
	 * WorldStory: BeginPlay fills the map and set, overwrites, dedups, and removes.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructHashableMapKeyAndSetElement
	 * @Inputs none
	 * @Return MapContainsOriginal/MapFindOriginal/MapOverwriteWorked/SetDedupWorked/SetRemoveWorked true
	 */
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

	/**
	 * Observe empty hashable containers before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructHashableMapKeyAndSetElement
	 * @Inputs an actor that has not begun play
	 * @Return true when map and set are empty and flags are default
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool HashableDefaultEmpty()
	{
		if (StructToIntMap.Num() != 0)
		{
			return false;
		}
		if (StructSet.Num() != 0)
		{
			return false;
		}
		if (MapContainsOriginal)
		{
			return false;
		}
		return MapFoundValue == 0;
	}

	/**
	 * Observe hashable map/set oracles after BeginPlay.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructHashableMapKeyAndSetElement
	 * @Inputs BeginPlay on this actor
	 * @Return true when contains/find/overwrite/dedup/remove match
	 */
	UFUNCTION()
	bool HashableNominalBeginPlay()
	{
		BeginPlay();
		if (StructToIntMap.Num() != 2)
		{
			return false;
		}
		if (!MapContainsOriginal)
		{
			return false;
		}
		if (!MapFindOriginal)
		{
			return false;
		}
		if (MapFoundValue != 10)
		{
			return false;
		}
		if (!MapOverwriteWorked)
		{
			return false;
		}
		if (StructSet.Num() != 1)
		{
			return false;
		}
		if (!SetContainsOriginal)
		{
			return false;
		}
		if (!SetDedupWorked)
		{
			return false;
		}
		return SetRemoveWorked;
	}

	/**
	 * Observe a zero-id empty-tag key and its hash.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructHashableMapKeyAndSetElement
	 * @Inputs MakeKey(0, n"")
	 * @Return true when ID is 0, Tag is empty, and Hash is 0
	 * @Boundary zero key
	 */
	UFUNCTION()
	bool HashableZeroKeyBoundary()
	{
		FHashableStructKey Zero = MakeKey(0, n"");
		if (Zero.ID != 0)
		{
			return false;
		}
		if (Zero.Tag != n"")
		{
			return false;
		}
		return Zero.Hash() == uint32(0);
	}
}
/** @end */
