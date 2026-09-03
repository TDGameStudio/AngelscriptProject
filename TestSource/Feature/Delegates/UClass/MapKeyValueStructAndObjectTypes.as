/**
 * Map-key UObject and hashable key/value structs. Defaults are key ID 0, value
 * Score 0, and object Value 0. Copies of Score are independent.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.MapKeyValueStructAndObjectTypes
 * @Harness UClass
 * @Tag Feature.Delegates.MapKeyValueStructAndObjectTypes
 * @Provenance Theme: Feature.Delegates. Positive block 1: map-key UObject and hashable key/value structs.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 7169-7213.
 * @Provenance Isolation=none: complete program. Oracle: default key ID 0 / value Score 0 / object Value 0.
 * @Provenance Extra: empty vs assigned Score; copy independence. DefaultSafe.
 */

UCLASS()
class UCoverageStructDelegateMapKeyObject : UObject
{
	UPROPERTY()
	int Value = 0;

	/**
	 * Observe the default object Value.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Map
	 * @Inputs this
	 * @Return 0
	 * @Boundary default zero
	 */
	UFUNCTION()
	int KeyObjectDefaultZero()
	{
		return Value;
	}

	/**
	 * Observe that assigning nullptr yields a null handle.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Map
	 * @Inputs Object = nullptr
	 * @Return true when the handle is null
	 * @Boundary nullptr assignment
	 */
	UFUNCTION()
	bool KeyObjectNullBoundary()
	{
		UCoverageStructDelegateMapKeyObject Object = nullptr;
		return Object == nullptr;
	}
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
	 * Observe that a default key has ID 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Map
	 * @Inputs a default FDelegateKeyValueMapKey
	 * @Return 0
	 * @Boundary default ID
	 */
	UFUNCTION()
	int KeyDefaultZero()
	{
		FDelegateKeyValueMapKey Key;
		return Key.ID;
	}

	/**
	 * Observe that a default value sums Score and Label length to 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Map
	 * @Inputs a default FDelegateKeyValueMapValue
	 * @Return 0
	 * @Boundary default Score
	 */
	UFUNCTION()
	int ValueDefaultZero()
	{
		FDelegateKeyValueMapValue Value;
		return Value.Score + Value.Label.Len();
	}

	/**
	 * Observe that clearing a copy leaves the original Score.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Map
	 * @Inputs Original Score 102; Copy Score 0
	 * @Return true when Original stays 102 and Copy is 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ValueCopyIndependence()
	{
		FDelegateKeyValueMapValue Original;
		Original.Score = 102;
		Original.Label = "NameValueB";
		FDelegateKeyValueMapValue Copy = Original;
		Copy.Score = 0;
		Copy.Label = "";
		if (Original.Score != 102)
		{
			return false;
		}
		return Copy.Score == 0;
	}
}
