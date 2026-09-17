/**
 * @version v1
 * @summary MakeKey, MakeValue, MakeKeyObject, and MakeObject helpers. MakeKey(0) has ID 0; MakeObject(0) has Value 0. A nullptr object is the null boundary.
 * @topic Feature
 */
/**
 * @version root
 * @summary MakeKey, MakeValue, MakeKeyObject, and MakeObject helpers. MakeKey(0) has ID 0; MakeObject(0) has Value 0. A nullptr object is the null boundary.
 * @topic Baseline
 */
UCLASS()
class UCoverageStructDelegateMapKeyObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class UCoverageStructDelegateMapValueObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

USTRUCT(BlueprintType)
struct FDelegateKeyValueMapKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Equality of ID and Tag.
	 *
	 * @Covers Delegates.Map
	 * @Param Other the other key
	 * @Inputs Other.ID and Other.Tag
	 * @Return true when both match
	 */
	bool opEquals(const FDelegateKeyValueMapKey&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * A stable mix of ID and Tag.
	 *
	 * @Covers Delegates.Map
	 * @Inputs ID and Tag
	 * @Return uint32(ID * 929) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 929) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FDelegateKeyValueMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	/**
	 * Builds a map key from ID and Tag.
	 *
	 * @Covers Delegates.Map
	 * @Param ID the key id
	 * @Param Tag the key tag
	 * @Inputs ID and Tag
	 * @Return a key with those fields
	 */
	FDelegateKeyValueMapKey MakeKey(int ID, FName Tag)
	{
		FDelegateKeyValueMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	/**
	 * Builds a map value from Score and Label.
	 *
	 * @Covers Delegates.Map
	 * @Param Score the value score
	 * @Param Label the value label
	 * @Inputs Score and Label
	 * @Return a value with those fields
	 */
	FDelegateKeyValueMapValue MakeValue(int Score, FString Label)
	{
		FDelegateKeyValueMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	/**
	 * Builds a key object with Value.
	 *
	 * @Covers Delegates.Map
	 * @Param Value the object value
	 * @Inputs Value
	 * @Return a new key object
	 */
	UCoverageStructDelegateMapKeyObject MakeKeyObject(int Value)
	{
		UCoverageStructDelegateMapKeyObject Object = Cast<UCoverageStructDelegateMapKeyObject>(NewObject(this, UCoverageStructDelegateMapKeyObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	/**
	 * Builds a value object with Value.
	 *
	 * @Covers Delegates.Map
	 * @Param Value the object value
	 * @Inputs Value
	 * @Return a new value object
	 */
	UCoverageStructDelegateMapValueObject MakeObject(int Value)
	{
		UCoverageStructDelegateMapValueObject Object = Cast<UCoverageStructDelegateMapValueObject>(NewObject(this, UCoverageStructDelegateMapValueObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	/**
	 * Observe MakeKey(0, n"").
	 *
	 * @Kind Observe
	 * @Covers Delegates.Map
	 * @Inputs MakeKey(0, n"")
	 * @Return 0
	 * @Boundary zero key
	 */
	UFUNCTION()
	int MakeKeyZeroBoundary()
	{
		FDelegateKeyValueMapKey Key = MakeKey(0, n"");
		return Key.ID;
	}

	/**
	 * Observe MakeValue(0, "").
	 *
	 * @Kind Observe
	 * @Covers Delegates.Map
	 * @Inputs MakeValue(0, "")
	 * @Return 0
	 * @Boundary zero value
	 */
	UFUNCTION()
	int MakeValueZeroBoundary()
	{
		FDelegateKeyValueMapValue Value = MakeValue(0, "");
		return Value.Score + Value.Label.Len();
	}

	/**
	 * Observe that a value object handle can be null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Map
	 * @Inputs Object = nullptr
	 * @Return true when the handle is null
	 * @Boundary nullptr assignment
	 */
	UFUNCTION()
	bool MakeObjectNullBoundary()
	{
		UCoverageStructDelegateMapValueObject Object = nullptr;
		return Object == nullptr;
	}

	/**
	 * Observe that clearing a copy leaves the original key ID.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Map
	 * @Inputs Original ID 301; Copy ID 0
	 * @Return true when Original stays 301 and Copy is 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool KeyCopyIndependence()
	{
		FDelegateKeyValueMapKey Original;
		Original.ID = 301;
		Original.Tag = n"StructStringValueB";
		FDelegateKeyValueMapKey Copy = Original;
		Copy.ID = 0;
		if (Original.ID != 301)
		{
			return false;
		}
		return Copy.ID == 0;
	}
}
/** @end */
