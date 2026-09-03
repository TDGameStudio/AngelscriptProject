/**
 * USTRUCT members that are TArray/TMap/TSet of structs. C++ reads
 * KeyToScoreFindWorked, KeyToValueFoundScore, and KeySet flags after BeginPlay.
 * Keep Data and the find/remove UPROPERTY names.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructContainerMemberShapeMatrix
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructContainerMemberShapeMatrix
 * @Provenance Theme: Definitions.UStruct. WorldStory: USTRUCT members that are TArray/TMap/TSet of structs.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructContainerMemberShapeMatrix spawn + BeginPlay.
 * @Provenance Oracle: KeyToScoreFindWorked true Found 300, KeyToValueFoundScore 400, KeySetContainsWorked true,
 * @Provenance KeySetRemoveWorked true. Extra: empty Data containers before BeginPlay. FixtureIsolated.
 */

USTRUCT(BlueprintType)
struct FStructMemberContainerKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers UStruct.UStructContainerMemberShapeMatrix
	 * @Inputs another FStructMemberContainerKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FStructMemberContainerKey&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 719 plus Tag.GetHash().
	 *
	 * @Covers UStruct.UStructContainerMemberShapeMatrix
	 * @Inputs none
	 * @Return uint32(ID * 719) + Tag.GetHash()
	 */
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

	/**
	 * Build a container key from an id and tag.
	 *
	 * @Covers UStruct.UStructContainerMemberShapeMatrix
	 * @Inputs ID and Tag
	 * @Return a key holding those fields
	 * @Param ID the key id
	 * @Param Tag the key tag
	 */
	FStructMemberContainerKey MakeKey(int ID, FName Tag)
	{
		FStructMemberContainerKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	/**
	 * Build a container value from a score and label.
	 *
	 * @Covers UStruct.UStructContainerMemberShapeMatrix
	 * @Inputs Score and Label
	 * @Return a value holding those fields
	 * @Param Score the score
	 * @Param Label the label
	 */
	FStructMemberContainerValue MakeValue(int Score, FString Label)
	{
		FStructMemberContainerValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	/**
	 * WorldStory: BeginPlay fills array/map/set members, finds duplicates, and removes a set key.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructContainerMemberShapeMatrix
	 * @Inputs none
	 * @Return KeyToScoreFound 300, KeyToValueFoundScore 400, KeySetContainsWorked/KeySetRemoveWorked true
	 */
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

	/**
	 * Observe empty Data containers before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerMemberShapeMatrix
	 * @Inputs an actor that has not begun play
	 * @Return true when all Data containers are empty and find flags are default
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool ContainerMemberDefaultEmpty()
	{
		if (Data.Values.Num() != 0)
		{
			return false;
		}
		if (Data.IntToValue.Num() != 0)
		{
			return false;
		}
		if (Data.KeyToScore.Num() != 0)
		{
			return false;
		}
		if (Data.KeyToValue.Num() != 0)
		{
			return false;
		}
		if (Data.KeySet.Num() != 0)
		{
			return false;
		}
		if (KeyToScoreFindWorked)
		{
			return false;
		}
		return KeyToScoreFound == 0;
	}

	/**
	 * Observe container members after BeginPlay.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructContainerMemberShapeMatrix
	 * @Inputs BeginPlay on this actor
	 * @Return true when the array/map/set oracles match
	 */
	UFUNCTION()
	bool ContainerMemberNominalBeginPlay()
	{
		BeginPlay();
		if (Data.Values.Num() != 2)
		{
			return false;
		}
		if (Data.Values[0].Score != 10)
		{
			return false;
		}
		if (Data.IntToValue.Num() != 2)
		{
			return false;
		}
		if (!KeyToScoreFindWorked)
		{
			return false;
		}
		if (KeyToScoreFound != 300)
		{
			return false;
		}
		if (!KeyToValueFindWorked)
		{
			return false;
		}
		if (KeyToValueFoundScore != 400)
		{
			return false;
		}
		if (!KeySetContainsWorked)
		{
			return false;
		}
		if (!KeySetRemoveWorked)
		{
			return false;
		}
		return Data.KeySet.Num() == 1;
	}

	/**
	 * Observe a zero key and empty value.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructContainerMemberShapeMatrix
	 * @Inputs MakeKey(0, none) and MakeValue(0, empty)
	 * @Return true when ID/Score/Label/Hash are zero
	 * @Boundary zero key
	 */
	UFUNCTION()
	bool ContainerMemberZeroKeyBoundary()
	{
		FStructMemberContainerKey Zero = MakeKey(0, n"");
		FStructMemberContainerValue Empty = MakeValue(0, "");
		if (Zero.ID != 0)
		{
			return false;
		}
		if (Empty.Score != 0)
		{
			return false;
		}
		if (Empty.Label.Len() != 0)
		{
			return false;
		}
		return Zero.Hash() == uint32(0);
	}
}
