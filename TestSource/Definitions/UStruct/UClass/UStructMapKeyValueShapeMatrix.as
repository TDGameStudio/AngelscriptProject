/**
 * TMap shapes from Name/Struct keys to struct/string/name/object values. C++
 * reads NameFoundScore 11, overwrite 31, StructString StringValue, StructObject
 * 77, and StructRemoveWorked after BeginPlay.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructMapKeyValueShapeMatrix
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructMapKeyValueShapeMatrix
 * @Provenance Theme: Definitions.UStruct. WorldStory: TMap shapes Name/Struct keys to struct/string/name/object.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueShapeMatrix spawn + BeginPlay.
 * @Provenance Oracle: NameFoundScore 11, StructStructFoundScore 21 then overwrite 31, StructString StringValue,
 * @Provenance StructObject 77, StructRemoveWorked true. Extra: empty maps before BeginPlay. FixtureIsolated.
 */

UCLASS()
class UCoverageStructMapValueObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

USTRUCT(BlueprintType)
struct FStructMapKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers UStruct.UStructMapKeyValueShapeMatrix
	 * @Inputs another FStructMapKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FStructMapKey&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 101 plus Tag.GetHash().
	 *
	 * @Covers UStruct.UStructMapKeyValueShapeMatrix
	 * @Inputs none
	 * @Return uint32(ID * 101) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 101) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FStructMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructMapShapeActor : AActor
{
	UPROPERTY()
	TMap<FName, FStructMapValue> NameToStruct;

	UPROPERTY()
	TMap<FStructMapKey, FStructMapValue> StructToStruct;

	UPROPERTY()
	TMap<FStructMapKey, FString> StructToString;

	UPROPERTY()
	TMap<FStructMapKey, FName> StructToName;

	UPROPERTY()
	TMap<FStructMapKey, UCoverageStructMapValueObject> StructToObject;

	UPROPERTY()
	bool NameFindWorked = false;

	UPROPERTY()
	int NameFoundScore = 0;

	UPROPERTY()
	bool StructStructContains = false;

	UPROPERTY()
	bool StructStructFindWorked = false;

	UPROPERTY()
	int StructStructFoundScore = 0;

	UPROPERTY()
	bool StructStructOverwriteWorked = false;

	UPROPERTY()
	bool StructStringFindWorked = false;

	UPROPERTY()
	FString StructStringFound;

	UPROPERTY()
	bool StructNameFindWorked = false;

	UPROPERTY()
	FName StructNameFound;

	UPROPERTY()
	bool StructObjectFindWorked = false;

	UPROPERTY()
	int StructObjectFoundValue = 0;

	UPROPERTY()
	bool StructRemoveWorked = false;

	/**
	 * Build a map key from an id and tag.
	 *
	 * @Covers UStruct.UStructMapKeyValueShapeMatrix
	 * @Inputs ID and Tag
	 * @Return a key holding those fields
	 * @Param ID the key id
	 * @Param Tag the key tag
	 */
	FStructMapKey MakeKey(int ID, FName Tag)
	{
		FStructMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	/**
	 * Build a map value from a score and label.
	 *
	 * @Covers UStruct.UStructMapKeyValueShapeMatrix
	 * @Inputs Score and Label
	 * @Return a value holding those fields
	 * @Param Score the score
	 * @Param Label the label
	 */
	FStructMapValue MakeValue(int Score, FString Label)
	{
		FStructMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	/**
	 * WorldStory: BeginPlay fills every map shape and records find/overwrite/remove.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructMapKeyValueShapeMatrix
	 * @Inputs none
	 * @Return NameFoundScore 11, overwrite 31, StructObject 77, StructRemoveWorked true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FStructMapKey Alpha = MakeKey(1, n"Alpha");
		FStructMapKey AlphaDuplicate = MakeKey(1, n"Alpha");
		FStructMapKey Beta = MakeKey(2, n"Beta");

		NameToStruct.Add(n"Primary", MakeValue(11, "NamePrimary"));
		FStructMapValue NameValue;
		NameFindWorked = NameToStruct.Find(n"Primary", NameValue);
		NameFoundScore = NameValue.Score;

		StructToStruct.Add(Alpha, MakeValue(21, "AlphaValue"));
		StructToStruct.Add(Beta, MakeValue(22, "BetaValue"));
		StructStructContains = StructToStruct.Contains(AlphaDuplicate);

		FStructMapValue StructValue;
		StructStructFindWorked = StructToStruct.Find(AlphaDuplicate, StructValue);
		StructStructFoundScore = StructValue.Score;
		StructToStruct.Add(AlphaDuplicate, MakeValue(31, "AlphaOverwrite"));
		StructStructOverwriteWorked = StructToStruct[Alpha].Score == 31;

		StructToString.Add(Alpha, "StringValue");
		StructStringFindWorked = StructToString.Find(AlphaDuplicate, StructStringFound);

		StructToName.Add(Alpha, n"NameValue");
		StructNameFindWorked = StructToName.Find(AlphaDuplicate, StructNameFound);

		UCoverageStructMapValueObject Obj = Cast<UCoverageStructMapValueObject>(NewObject(this, UCoverageStructMapValueObject::StaticClass()));
		Obj.Value = 77;
		StructToObject.Add(Alpha, Obj);
		UCoverageStructMapValueObject FoundObj = nullptr;
		StructObjectFindWorked = StructToObject.Find(AlphaDuplicate, FoundObj);
		StructObjectFoundValue = FoundObj != nullptr ? FoundObj.Value : -1;

		StructRemoveWorked = StructToStruct.Remove(Beta) && !StructToStruct.Contains(Beta);
	}

	/**
	 * Observe empty map shapes before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructMapKeyValueShapeMatrix
	 * @Inputs an actor that has not begun play
	 * @Return true when maps are empty and flags are default
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool MapShapeDefaultEmpty()
	{
		if (NameToStruct.Num() != 0)
		{
			return false;
		}
		if (StructToStruct.Num() != 0)
		{
			return false;
		}
		if (StructToObject.Num() != 0)
		{
			return false;
		}
		if (NameFindWorked)
		{
			return false;
		}
		if (NameFoundScore != 0)
		{
			return false;
		}
		return StructObjectFoundValue == 0;
	}

	/**
	 * Observe map-shape oracles after BeginPlay.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructMapKeyValueShapeMatrix
	 * @Inputs BeginPlay on this actor
	 * @Return true when finds, overwrite 31, object 77, and remove match
	 */
	UFUNCTION()
	bool MapShapeNominalBeginPlay()
	{
		BeginPlay();
		if (!NameFindWorked)
		{
			return false;
		}
		if (NameFoundScore != 11)
		{
			return false;
		}
		if (!StructStructContains)
		{
			return false;
		}
		if (!StructStructFindWorked)
		{
			return false;
		}
		if (StructStructFoundScore != 21)
		{
			return false;
		}
		if (!StructStructOverwriteWorked)
		{
			return false;
		}
		if (!StructStringFindWorked)
		{
			return false;
		}
		if (StructStringFound != "StringValue")
		{
			return false;
		}
		if (!StructNameFindWorked)
		{
			return false;
		}
		if (StructNameFound != n"NameValue")
		{
			return false;
		}
		if (!StructObjectFindWorked)
		{
			return false;
		}
		if (StructObjectFoundValue != 77)
		{
			return false;
		}
		if (!StructRemoveWorked)
		{
			return false;
		}
		return StructToStruct.Num() == 1;
	}

	/**
	 * Observe Find of a missing name key.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructMapKeyValueShapeMatrix
	 * @Inputs Find n"Missing" on NameToStruct
	 * @Return true when Find fails and Found.Score stays 0
	 * @Boundary missing key
	 */
	UFUNCTION()
	bool MapShapeMissingKeyBoundary()
	{
		FStructMapValue Found;
		if (NameToStruct.Find(n"Missing", Found))
		{
			return false;
		}
		return Found.Score == 0;
	}
}
