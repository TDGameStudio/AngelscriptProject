/**
 * @version v1
 * @summary USTRUCT TMap permutations of name/string/bool/float/object keys. NameToValueFoundScore 102, String 202, Bool 302, Float 402, Object 422, KeyToString StringValue, KeyToBool true, KeyToFloat 72.5, KeyToObject 802. Empty.
 * @topic Definitions
 */
/**
 * @version root
 * @summary USTRUCT TMap permutations of name/string/bool/float/object keys. NameToValueFoundScore 102, String 202, Bool 302, Float 402, Object 422, KeyToString StringValue, KeyToBool true, KeyToFloat 72.5, KeyToObject 802. Empty.
 * @topic Baseline
 */
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

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers UStruct.UStructExtendedMapMemberPermutationMatrix
	 * @Inputs another FStructMemberExtendedKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FStructMemberExtendedKey&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 811 plus Tag.GetHash().
	 *
	 * @Covers UStruct.UStructExtendedMapMemberPermutationMatrix
	 * @Inputs none
	 * @Return uint32(ID * 811) + Tag.GetHash()
	 */
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

	/**
	 * Build an extended key from an id and tag.
	 *
	 * @Covers UStruct.UStructExtendedMapMemberPermutationMatrix
	 * @Inputs ID and Tag
	 * @Return a key holding those fields
	 * @Param ID the key id
	 * @Param Tag the key tag
	 */
	FStructMemberExtendedKey MakeKey(int ID, FName Tag)
	{
		FStructMemberExtendedKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	/**
	 * Build an extended value from a score and label.
	 *
	 * @Covers UStruct.UStructExtendedMapMemberPermutationMatrix
	 * @Inputs Score and Label
	 * @Return a value holding those fields
	 * @Param Score the score
	 * @Param Label the label
	 */
	FStructMemberExtendedValue MakeValue(int Score, FString Label)
	{
		FStructMemberExtendedValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	/**
	 * Build a UObject map key with Value.
	 *
	 * @Covers UStruct.UStructExtendedMapMemberPermutationMatrix
	 * @Inputs Value
	 * @Return a new UCoverageStructExtendedMemberMapObject
	 * @Param Value the object Value
	 */
	UCoverageStructExtendedMemberMapObject MakeObject(int Value)
	{
		UCoverageStructExtendedMemberMapObject Object = Cast<UCoverageStructExtendedMemberMapObject>(NewObject(this, UCoverageStructExtendedMemberMapObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	/**
	 * WorldStory: BeginPlay fills name/string/bool/float/object and struct-key maps.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructExtendedMapMemberPermutationMatrix
	 * @Inputs none
	 * @Return NameToValueFoundScore 102 through KeyToObjectFoundValue 802
	 */
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

	/**
	 * Observe empty maps and default flags before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructExtendedMapMemberPermutationMatrix
	 * @Inputs an actor that has not begun play
	 * @Return true when NameToValue/BoolToValue/KeyToObject are empty and flags are default
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool ExtendedMapDefaultEmpty()
	{
		if (Data.NameToValue.Num() != 0)
		{
			return false;
		}
		if (Data.BoolToValue.Num() != 0)
		{
			return false;
		}
		if (Data.KeyToObject.Num() != 0)
		{
			return false;
		}
		if (NameToValueFindWorked)
		{
			return false;
		}
		if (NameToValueFoundScore != 0)
		{
			return false;
		}
		return KeyToFloatFound == 0.0f;
	}

	/**
	 * Observe BeginPlay find scores across the extended map permutations.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructExtendedMapMemberPermutationMatrix
	 * @Inputs BeginPlay
	 * @Return true when Name 102, String 202, Bool 302, Float 402, Object 422, KeyToString StringValue, KeyToObject 802
	 */
	UFUNCTION()
	bool ExtendedMapNominalBeginPlay()
	{
		BeginPlay();
		if (!NameToValueFindWorked)
		{
			return false;
		}
		if (NameToValueFoundScore != 102)
		{
			return false;
		}
		if (!StringToValueFindWorked)
		{
			return false;
		}
		if (StringToValueFoundScore != 202)
		{
			return false;
		}
		if (!BoolToValueFindWorked)
		{
			return false;
		}
		if (BoolToValueFoundScore != 302)
		{
			return false;
		}
		if (!FloatToValueFindWorked)
		{
			return false;
		}
		if (FloatToValueFoundScore != 402)
		{
			return false;
		}
		if (!ObjectToValueFindWorked)
		{
			return false;
		}
		if (ObjectToValueFoundScore != 422)
		{
			return false;
		}
		if (!KeyToStringFindWorked)
		{
			return false;
		}
		if (KeyToStringFound != "StringValue")
		{
			return false;
		}
		if (!KeyToNameFindWorked)
		{
			return false;
		}
		if (KeyToNameFound != n"NameValue")
		{
			return false;
		}
		if (!KeyToBoolFindWorked)
		{
			return false;
		}
		if (!KeyToBoolFound)
		{
			return false;
		}
		if (!KeyToFloatFindWorked)
		{
			return false;
		}
		if (KeyToFloatFound != 72.5f)
		{
			return false;
		}
		if (!KeyToObjectFindWorked)
		{
			return false;
		}
		return KeyToObjectFoundValue == 802;
	}

	/**
	 * Observe the false bool key after BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructExtendedMapMemberPermutationMatrix
	 * @Inputs BeginPlay then Find(false)
	 * @Return true when Score 302 Label BoolFalse
	 * @Boundary false key
	 */
	UFUNCTION()
	bool ExtendedMapFalseKeyBoundary()
	{
		BeginPlay();
		FStructMemberExtendedValue Found;
		if (!Data.BoolToValue.Find(false, Found))
		{
			return false;
		}
		if (Found.Score != 302)
		{
			return false;
		}
		return Found.Label == "BoolFalse";
	}
}
/** @end */
