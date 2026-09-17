/**
 * @version v1
 * @summary Actor storage for TMap key/value parameter shapes: Name/String to struct and struct to String/Name/Object. C++ reads the default counts and empty inout maps. Keep the UPROPERTY names on.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Actor storage for TMap key/value parameter shapes: Name/String to struct and struct to String/Name/Object. C++ reads the default counts and empty inout maps. Keep the UPROPERTY names on.
 * @topic Baseline
 */
UCLASS()
class UCoverageStructMapParamValueObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

USTRUCT(BlueprintType)
struct FMapParamKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers UStruct.MapKeyValueParameterMemberShapes
	 * @Inputs another FMapParamKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FMapParamKey&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 977 plus Tag.GetHash().
	 *
	 * @Covers UStruct.MapKeyValueParameterMemberShapes
	 * @Inputs none
	 * @Return uint32(ID * 977) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FMapParamValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructMapParamMatrixActor : AActor
{
	UPROPERTY()
	int NameStructValueCount = 0;

	UPROPERTY()
	int NameStructInCount = 0;

	UPROPERTY()
	TMap<FName, FMapParamValue> NameStructInout;

	UPROPERTY()
	bool NameStructValuePreserved = false;

	UPROPERTY()
	bool NameStructInPreserved = false;

	UPROPERTY()
	bool NameStructInoutSawOriginal = false;

	UPROPERTY()
	bool NameStructInoutMutated = false;

	UPROPERTY()
	bool NameStructReturnPreserved = false;

	UPROPERTY()
	int StringStructValueCount = 0;

	UPROPERTY()
	int StringStructInCount = 0;

	UPROPERTY()
	TMap<FString, FMapParamValue> StringStructInout;

	UPROPERTY()
	bool StringStructValuePreserved = false;

	UPROPERTY()
	bool StringStructInPreserved = false;

	UPROPERTY()
	bool StringStructInoutSawOriginal = false;

	UPROPERTY()
	bool StringStructInoutMutated = false;

	UPROPERTY()
	bool StringStructReturnPreserved = false;

	UPROPERTY()
	int StructStringValueCount = 0;

	UPROPERTY()
	int StructStringInCount = 0;

	UPROPERTY()
	TMap<FMapParamKey, FString> StructStringInout;

	UPROPERTY()
	bool StructStringValuePreserved = false;

	UPROPERTY()
	bool StructStringInPreserved = false;

	UPROPERTY()
	bool StructStringInoutSawOriginal = false;

	UPROPERTY()
	bool StructStringInoutMutated = false;

	UPROPERTY()
	bool StructStringReturnPreserved = false;

	UPROPERTY()
	int StructNameValueCount = 0;

	UPROPERTY()
	int StructNameInCount = 0;

	UPROPERTY()
	TMap<FMapParamKey, FName> StructNameInout;

	UPROPERTY()
	bool StructNameValuePreserved = false;

	UPROPERTY()
	bool StructNameInPreserved = false;

	UPROPERTY()
	bool StructNameInoutSawOriginal = false;

	UPROPERTY()
	bool StructNameInoutMutated = false;

	UPROPERTY()
	bool StructNameReturnPreserved = false;

	UPROPERTY()
	int StructObjectValueCount = 0;

	UPROPERTY()
	int StructObjectInCount = 0;

	UPROPERTY()
	TMap<FMapParamKey, UCoverageStructMapParamValueObject> StructObjectInout;

	UPROPERTY()
	bool StructObjectValuePreserved = false;

	UPROPERTY()
	bool StructObjectInPreserved = false;

	UPROPERTY()
	bool StructObjectInoutSawOriginal = false;

	UPROPERTY()
	bool StructObjectInoutMutated = false;

	UPROPERTY()
	bool StructObjectReturnPreserved = false;

	/**
	 * Observe default map-parameter storage before any call.
	 *
	 * @Kind Observe
	 * @Covers UStruct.MapKeyValueParameterMemberShapes
	 * @Inputs an actor that has not begun play
	 * @Return true when counts are 0, inout maps are empty, and flags are false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool MapParamStorageDefaultEmpty()
	{
		if (NameStructValueCount != 0)
		{
			return false;
		}
		if (StringStructValueCount != 0)
		{
			return false;
		}
		if (StructStringValueCount != 0)
		{
			return false;
		}
		if (StructNameValueCount != 0)
		{
			return false;
		}
		if (StructObjectValueCount != 0)
		{
			return false;
		}
		if (NameStructInout.Num() != 0)
		{
			return false;
		}
		if (StringStructInout.Num() != 0)
		{
			return false;
		}
		if (StructStringInout.Num() != 0)
		{
			return false;
		}
		if (StructNameInout.Num() != 0)
		{
			return false;
		}
		if (StructObjectInout.Num() != 0)
		{
			return false;
		}
		if (NameStructValuePreserved)
		{
			return false;
		}
		return !StructObjectReturnPreserved;
	}

	/**
	 * Observe zero-key hash versus a named key.
	 *
	 * @Kind Observe
	 * @Covers UStruct.MapKeyValueParameterMemberShapes
	 * @Inputs a zero key and a key with ID 1 Tag Tag
	 * @Return true when the zero hash is 0 and the named key differs
	 * @Boundary zero key hash
	 */
	UFUNCTION()
	bool MapParamStorageKeyHashBoundary()
	{
		FMapParamKey Zero;
		FMapParamKey Named;
		Named.ID = 1;
		Named.Tag = n"Tag";
		if (Zero.ID != 0)
		{
			return false;
		}
		if (Zero.Hash() != uint32(0))
		{
			return false;
		}
		if (Zero == Named)
		{
			return false;
		}
		return Named.Hash() != uint32(0);
	}

	/**
	 * Observe the default Value of a newly created map-value object.
	 *
	 * @Kind Observe
	 * @Covers UStruct.MapKeyValueParameterMemberShapes
	 * @Inputs NewObject of UCoverageStructMapParamValueObject
	 * @Return the object's Value
	 * @Boundary object default
	 */
	UFUNCTION()
	int MapParamStorageValueObjectDefault()
	{
		UCoverageStructMapParamValueObject Object = Cast<UCoverageStructMapParamValueObject>(NewObject(this, UCoverageStructMapParamValueObject::StaticClass()));
		return Object.Value;
	}
}
/** @end */
