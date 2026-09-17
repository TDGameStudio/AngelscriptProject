/**
 * @version v1
 * @summary Object/string/name/object-value map storage. ObjectStructValueResult 0, flags false, empty maps. Empty TMap Num 0. Null object boundary.
 * @topic Feature
 */
/**
 * @version root
 * @summary Object/string/name/object-value map storage. ObjectStructValueResult 0, flags false, empty maps. Empty TMap Num 0. Null object boundary.
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
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers Delegates.MapKeyValueObjectStringNameObjectValueStorage
	 * @Inputs another FDelegateKeyValueMapKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
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
	 * Hash as ID * 929 plus Tag.GetHash().
	 *
	 * @Covers Delegates.MapKeyValueObjectStringNameObjectValueStorage
	 * @Inputs none
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
	UPROPERTY()
	int ObjectStructValueResult = 0;

	UPROPERTY()
	int ObjectStructInResult = 0;

	UPROPERTY()
	int ObjectStructInoutResult = 0;

	UPROPERTY()
	TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> ObjectStructOutResult;

	UPROPERTY()
	TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> ObjectStructInoutResultItems;

	UPROPERTY()
	TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> ObjectStructReturnResult;

	UPROPERTY()
	bool ObjectStructValuePreserved = false;

	UPROPERTY()
	bool ObjectStructInPreserved = false;

	UPROPERTY()
	bool ObjectStructOutPreserved = false;

	UPROPERTY()
	bool ObjectStructInoutPreserved = false;

	UPROPERTY()
	bool ObjectStructReturnPreserved = false;

	UPROPERTY()
	int StructStringValueResult = 0;

	UPROPERTY()
	int StructStringInResult = 0;

	UPROPERTY()
	int StructStringInoutResult = 0;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FString> StructStringOutResult;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FString> StructStringInoutResultItems;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FString> StructStringReturnResult;

	UPROPERTY()
	bool StructStringValuePreserved = false;

	UPROPERTY()
	bool StructStringInPreserved = false;

	UPROPERTY()
	bool StructStringOutPreserved = false;

	UPROPERTY()
	bool StructStringInoutPreserved = false;

	UPROPERTY()
	bool StructStringReturnPreserved = false;

	UPROPERTY()
	int StructNameValueResult = 0;

	UPROPERTY()
	int StructNameInResult = 0;

	UPROPERTY()
	int StructNameInoutResult = 0;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FName> StructNameOutResult;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FName> StructNameInoutResultItems;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FName> StructNameReturnResult;

	UPROPERTY()
	bool StructNameValuePreserved = false;

	UPROPERTY()
	bool StructNameInPreserved = false;

	UPROPERTY()
	bool StructNameOutPreserved = false;

	UPROPERTY()
	bool StructNameInoutPreserved = false;

	UPROPERTY()
	bool StructNameReturnPreserved = false;

	UPROPERTY()
	int StructObjectValueResult = 0;

	UPROPERTY()
	int StructObjectInResult = 0;

	UPROPERTY()
	int StructObjectInoutResult = 0;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> StructObjectOutResult;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> StructObjectInoutResultItems;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> StructObjectReturnResult;

	UPROPERTY()
	bool StructObjectValuePreserved = false;

	UPROPERTY()
	bool StructObjectInPreserved = false;

	UPROPERTY()
	bool StructObjectOutPreserved = false;

	UPROPERTY()
	bool StructObjectInoutPreserved = false;

	UPROPERTY()
	bool StructObjectReturnPreserved = false;

	/**
	 * Observe default object/string/name/object value results.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default results
	 */
	UFUNCTION()
	int ObjectStructValueResultDefaultZero()
	{
		return ObjectStructValueResult + StructStringValueResult + StructNameValueResult + StructObjectValueResult;
	}

	/**
	 * Observe empty object-to-struct map Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty map
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int EmptyObjectMapDefaultNum()
	{
		TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> Items;
		return Items.Num();
	}

	/**
	 * Observe a null value object.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs nullptr
	 * @Return true when the object is null
	 * @Boundary null object
	 */
	UFUNCTION()
	bool ValueObjectNullBoundary()
	{
		UCoverageStructDelegateMapValueObject Object = nullptr;
		return Object == nullptr;
	}
}
/** @end */
