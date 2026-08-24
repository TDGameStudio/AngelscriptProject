// Theme: Definitions.UStruct. WorldStory: TMap shapes Name/Struct keys to struct/string/name/object.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueShapeMatrix spawn + BeginPlay.
// Oracle: NameFoundScore 11, StructStructFoundScore 21 then overwrite 31, StructString StringValue,
// StructObject 77, StructRemoveWorked true. Extra: empty maps before BeginPlay. FixtureIsolated.

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

	bool opEquals(const FStructMapKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

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

	FStructMapKey MakeKey(int ID, FName Tag)
	{
		FStructMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	FStructMapValue MakeValue(int Score, FString Label)
	{
		FStructMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

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
}

bool Observe_MapShape_DefaultEmpty(ACoverageStructMapShapeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueShapeMatrix setup: required Actor is null");
	}
	return Actor.NameToStruct.Num() == 0
		&& Actor.StructToStruct.Num() == 0
		&& Actor.StructToObject.Num() == 0
		&& !Actor.NameFindWorked
		&& Actor.NameFoundScore == 0
		&& Actor.StructObjectFoundValue == 0;
}

bool Observe_MapShape_NominalBeginPlay(ACoverageStructMapShapeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueShapeMatrix setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.NameFindWorked && Actor.NameFoundScore == 11
		&& Actor.StructStructContains
		&& Actor.StructStructFindWorked
		&& Actor.StructStructFoundScore == 21
		&& Actor.StructStructOverwriteWorked
		&& Actor.StructStringFindWorked && Actor.StructStringFound == "StringValue"
		&& Actor.StructNameFindWorked && Actor.StructNameFound == n"NameValue"
		&& Actor.StructObjectFindWorked && Actor.StructObjectFoundValue == 77
		&& Actor.StructRemoveWorked
		&& Actor.StructToStruct.Num() == 1;
}

bool Observe_MapShape_MissingKeyBoundary(ACoverageStructMapShapeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueShapeMatrix setup: required Actor is null");
	}
	FStructMapValue Found;
	return !Actor.NameToStruct.Find(n"Missing", Found) && Found.Score == 0;
}
