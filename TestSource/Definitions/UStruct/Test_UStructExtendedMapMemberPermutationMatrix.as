// Theme: Definitions.UStruct. WorldStory: USTRUCT TMap permutations of name/string/bool/float/object keys.
// C++: AngelscriptCoverageUStructTests.cpp::UStructExtendedMapMemberPermutationMatrix spawn + BeginPlay.
// Oracle: NameToValueFoundScore 102, String 202, Bool 302, Float 402, Object 422, KeyToString StringValue,
// KeyToBool true, KeyToFloat 72.5, KeyToObject 802. Extra: empty maps / false flags. FixtureIsolated.

UCLASS()
class UCoverageStructExtendedMemberMapObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

USTRUCT(BlueprintType)
struct FStructMemberExtendedKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FStructMemberExtendedKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 811) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FStructMemberExtendedValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

USTRUCT(BlueprintType)
struct FStructExtendedMapOwner
{
	UPROPERTY()
	TMap<FName, FStructMemberExtendedValue> NameToValue;

	UPROPERTY()
	TMap<FString, FStructMemberExtendedValue> StringToValue;

	UPROPERTY()
	TMap<bool, FStructMemberExtendedValue> BoolToValue;

	UPROPERTY()
	TMap<float, FStructMemberExtendedValue> FloatToValue;

	UPROPERTY()
	TMap<UCoverageStructExtendedMemberMapObject, FStructMemberExtendedValue> ObjectToValue;

	UPROPERTY()
	TMap<FStructMemberExtendedKey, FString> KeyToString;

	UPROPERTY()
	TMap<FStructMemberExtendedKey, FName> KeyToName;

	UPROPERTY()
	TMap<FStructMemberExtendedKey, bool> KeyToBool;

	UPROPERTY()
	TMap<FStructMemberExtendedKey, float> KeyToFloat;

	UPROPERTY()
	TMap<FStructMemberExtendedKey, UCoverageStructExtendedMemberMapObject> KeyToObject;
}

UCLASS()
class ACoverageStructExtendedMapMemberActor : AActor
{
	UPROPERTY()
	FStructExtendedMapOwner Data;

	UPROPERTY()
	bool NameToValueFindWorked = false;

	UPROPERTY()
	int NameToValueFoundScore = 0;

	UPROPERTY()
	bool StringToValueFindWorked = false;

	UPROPERTY()
	int StringToValueFoundScore = 0;

	UPROPERTY()
	bool BoolToValueFindWorked = false;

	UPROPERTY()
	int BoolToValueFoundScore = 0;

	UPROPERTY()
	bool FloatToValueFindWorked = false;

	UPROPERTY()
	int FloatToValueFoundScore = 0;

	UPROPERTY()
	bool ObjectToValueFindWorked = false;

	UPROPERTY()
	int ObjectToValueFoundScore = 0;

	UPROPERTY()
	bool KeyToStringFindWorked = false;

	UPROPERTY()
	FString KeyToStringFound;

	UPROPERTY()
	bool KeyToNameFindWorked = false;

	UPROPERTY()
	FName KeyToNameFound;

	UPROPERTY()
	bool KeyToBoolFindWorked = false;

	UPROPERTY()
	bool KeyToBoolFound = false;

	UPROPERTY()
	bool KeyToFloatFindWorked = false;

	UPROPERTY()
	float KeyToFloatFound = 0.0f;

	UPROPERTY()
	bool KeyToObjectFindWorked = false;

	UPROPERTY()
	int KeyToObjectFoundValue = 0;

	FStructMemberExtendedKey MakeKey(int ID, FName Tag)
	{
		FStructMemberExtendedKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	FStructMemberExtendedValue MakeValue(int Score, FString Label)
	{
		FStructMemberExtendedValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	UCoverageStructExtendedMemberMapObject MakeObject(int Value)
	{
		UCoverageStructExtendedMemberMapObject Object = Cast<UCoverageStructExtendedMemberMapObject>(NewObject(this, UCoverageStructExtendedMemberMapObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Data.NameToValue.Add(n"NameA", MakeValue(101, "NameA"));
		Data.NameToValue.Add(n"NameB", MakeValue(102, "NameB"));
		FStructMemberExtendedValue FoundValue;
		NameToValueFindWorked = Data.NameToValue.Find(n"NameB", FoundValue);
		NameToValueFoundScore = FoundValue.Score;

		Data.StringToValue.Add("StringA", MakeValue(201, "StringA"));
		Data.StringToValue.Add("StringB", MakeValue(202, "StringB"));
		StringToValueFindWorked = Data.StringToValue.Find("StringB", FoundValue);
		StringToValueFoundScore = FoundValue.Score;

		Data.BoolToValue.Add(true, MakeValue(301, "BoolTrue"));
		Data.BoolToValue.Add(false, MakeValue(302, "BoolFalse"));
		BoolToValueFindWorked = Data.BoolToValue.Find(false, FoundValue);
		BoolToValueFoundScore = FoundValue.Score;

		Data.FloatToValue.Add(401.5f, MakeValue(401, "FloatA"));
		Data.FloatToValue.Add(402.5f, MakeValue(402, "FloatB"));
		FloatToValueFindWorked = Data.FloatToValue.Find(402.5f, FoundValue);
		FloatToValueFoundScore = FoundValue.Score;

		UCoverageStructExtendedMemberMapObject ObjectA = MakeObject(410);
		UCoverageStructExtendedMemberMapObject ObjectB = MakeObject(420);
		Data.ObjectToValue.Add(ObjectA, MakeValue(411, "ObjectA"));
		Data.ObjectToValue.Add(ObjectB, MakeValue(422, "ObjectB"));
		ObjectToValueFindWorked = Data.ObjectToValue.Find(ObjectB, FoundValue);
		ObjectToValueFoundScore = FoundValue.Score;

		FStructMemberExtendedKey Alpha = MakeKey(401, n"Alpha");
		FStructMemberExtendedKey AlphaDuplicate = MakeKey(401, n"Alpha");
		FStructMemberExtendedKey Beta = MakeKey(402, n"Beta");

		Data.KeyToString.Add(Alpha, "StringValue");
		Data.KeyToString.Add(Beta, "StringOther");
		KeyToStringFindWorked = Data.KeyToString.Find(AlphaDuplicate, KeyToStringFound);

		Data.KeyToName.Add(Alpha, n"NameValue");
		Data.KeyToName.Add(Beta, n"NameOther");
		KeyToNameFindWorked = Data.KeyToName.Find(AlphaDuplicate, KeyToNameFound);

		Data.KeyToBool.Add(Alpha, true);
		Data.KeyToBool.Add(Beta, false);
		KeyToBoolFindWorked = Data.KeyToBool.Find(AlphaDuplicate, KeyToBoolFound);

		Data.KeyToFloat.Add(Alpha, 72.5f);
		Data.KeyToFloat.Add(Beta, 73.5f);
		KeyToFloatFindWorked = Data.KeyToFloat.Find(AlphaDuplicate, KeyToFloatFound);

		Data.KeyToObject.Add(Alpha, MakeObject(801));
		Data.KeyToObject.Add(Beta, MakeObject(802));
		UCoverageStructExtendedMemberMapObject FoundObject = nullptr;
		KeyToObjectFindWorked = Data.KeyToObject.Find(Beta, FoundObject);
		KeyToObjectFoundValue = FoundObject != nullptr ? FoundObject.Value : -1;
	}
}

bool Observe_ExtendedMap_DefaultEmpty(ACoverageStructExtendedMapMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructExtendedMapMemberPermutationMatrix setup: required Actor is null");
	}
	return Actor.Data.NameToValue.Num() == 0
		&& Actor.Data.BoolToValue.Num() == 0
		&& Actor.Data.KeyToObject.Num() == 0
		&& !Actor.NameToValueFindWorked
		&& Actor.NameToValueFoundScore == 0
		&& Actor.KeyToFloatFound == 0.0f;
}

bool Observe_ExtendedMap_NominalBeginPlay(ACoverageStructExtendedMapMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructExtendedMapMemberPermutationMatrix setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.NameToValueFindWorked && Actor.NameToValueFoundScore == 102
		&& Actor.StringToValueFindWorked && Actor.StringToValueFoundScore == 202
		&& Actor.BoolToValueFindWorked && Actor.BoolToValueFoundScore == 302
		&& Actor.FloatToValueFindWorked && Actor.FloatToValueFoundScore == 402
		&& Actor.ObjectToValueFindWorked && Actor.ObjectToValueFoundScore == 422
		&& Actor.KeyToStringFindWorked && Actor.KeyToStringFound == "StringValue"
		&& Actor.KeyToNameFindWorked && Actor.KeyToNameFound == n"NameValue"
		&& Actor.KeyToBoolFindWorked && Actor.KeyToBoolFound
		&& Actor.KeyToFloatFindWorked && Actor.KeyToFloatFound == 72.5f
		&& Actor.KeyToObjectFindWorked && Actor.KeyToObjectFoundValue == 802;
}

bool Observe_ExtendedMap_FalseKeyBoundary(ACoverageStructExtendedMapMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructExtendedMapMemberPermutationMatrix setup: required Actor is null");
	}
	Actor.BeginPlay();
	FStructMemberExtendedValue Found;
	return Actor.Data.BoolToValue.Find(false, Found) && Found.Score == 302 && Found.Label == "BoolFalse";
}
