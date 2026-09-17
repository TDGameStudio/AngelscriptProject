/**
 * @version v1
 * @summary Name/string/float/object/struct map-delegate types. Default NameStructValueSignal unbound. Empty TMap Num 0.
 * @topic Feature
 */
/**
 * @version root
 * @summary Name/string/float/object/struct map-delegate types. Default NameStructValueSignal unbound. Empty TMap Num 0.
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
	 * @Covers Delegates.MapKeyValueNameStringFloatObjectStructDelegateTypes
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
	 * @Covers Delegates.MapKeyValueNameStringFloatObjectStructDelegateTypes
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

/**
 * Name-to-struct map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FNameStructMapValueSignal(TMap<FName, FDelegateKeyValueMapValue> Items);

/**
 * Name-to-struct map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FNameStructMapInSignal(const TMap<FName, FDelegateKeyValueMapValue>&in Items);

/**
 * Name-to-struct map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FNameStructMapOutSignal(TMap<FName, FDelegateKeyValueMapValue>&out Items);

/**
 * Name-to-struct map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FNameStructMapInoutSignal(TMap<FName, FDelegateKeyValueMapValue>&inout Items);

/**
 * Name-to-struct map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of values
 */
delegate TMap<FName, FDelegateKeyValueMapValue> FNameStructMapReturnSignal();

/**
 * String-to-struct map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStringStructMapValueSignal(TMap<FString, FDelegateKeyValueMapValue> Items);

/**
 * String-to-struct map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStringStructMapInSignal(const TMap<FString, FDelegateKeyValueMapValue>&in Items);

/**
 * String-to-struct map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStringStructMapOutSignal(TMap<FString, FDelegateKeyValueMapValue>&out Items);

/**
 * String-to-struct map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStringStructMapInoutSignal(TMap<FString, FDelegateKeyValueMapValue>&inout Items);

/**
 * String-to-struct map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of values
 */
delegate TMap<FString, FDelegateKeyValueMapValue> FStringStructMapReturnSignal();

/**
 * Float-to-struct map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FFloatStructMapValueSignal(TMap<float, FDelegateKeyValueMapValue> Items);

/**
 * Float-to-struct map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FFloatStructMapInSignal(const TMap<float, FDelegateKeyValueMapValue>&in Items);

/**
 * Float-to-struct map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FFloatStructMapOutSignal(TMap<float, FDelegateKeyValueMapValue>&out Items);

/**
 * Float-to-struct map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FFloatStructMapInoutSignal(TMap<float, FDelegateKeyValueMapValue>&inout Items);

/**
 * Float-to-struct map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of values
 */
delegate TMap<float, FDelegateKeyValueMapValue> FFloatStructMapReturnSignal();

/**
 * Object-to-struct map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FObjectStructMapValueSignal(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> Items);

/**
 * Object-to-struct map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FObjectStructMapInSignal(const TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&in Items);

/**
 * Object-to-struct map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FObjectStructMapOutSignal(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&out Items);

/**
 * Object-to-struct map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FObjectStructMapInoutSignal(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&inout Items);

/**
 * Object-to-struct map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of values
 */
delegate TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> FObjectStructMapReturnSignal();

/**
 * Struct-to-string map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructStringMapValueSignal(TMap<FDelegateKeyValueMapKey, FString> Items);

/**
 * Struct-to-string map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructStringMapInSignal(const TMap<FDelegateKeyValueMapKey, FString>&in Items);

/**
 * Struct-to-string map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructStringMapOutSignal(TMap<FDelegateKeyValueMapKey, FString>&out Items);

/**
 * Struct-to-string map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructStringMapInoutSignal(TMap<FDelegateKeyValueMapKey, FString>&inout Items);

/**
 * Struct-to-string map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of strings
 */
delegate TMap<FDelegateKeyValueMapKey, FString> FStructStringMapReturnSignal();

/**
 * Struct-to-name map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructNameMapValueSignal(TMap<FDelegateKeyValueMapKey, FName> Items);

/**
 * Struct-to-name map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructNameMapInSignal(const TMap<FDelegateKeyValueMapKey, FName>&in Items);

/**
 * Struct-to-name map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructNameMapOutSignal(TMap<FDelegateKeyValueMapKey, FName>&out Items);

/**
 * Struct-to-name map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructNameMapInoutSignal(TMap<FDelegateKeyValueMapKey, FName>&inout Items);

/**
 * Struct-to-name map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of names
 */
delegate TMap<FDelegateKeyValueMapKey, FName> FStructNameMapReturnSignal();

/**
 * Struct-to-object map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructObjectMapValueSignal(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> Items);

/**
 * Struct-to-object map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructObjectMapInSignal(const TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&in Items);

/**
 * Struct-to-object map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructObjectMapOutSignal(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&out Items);

/**
 * Struct-to-object map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructObjectMapInoutSignal(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&inout Items);

/**
 * Struct-to-object map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of objects
 */
delegate TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> FStructObjectMapReturnSignal();

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	UPROPERTY()
	FNameStructMapValueSignal NameStructValueSignal;

	UPROPERTY()
	FNameStructMapInSignal NameStructInSignal;

	UPROPERTY()
	FNameStructMapOutSignal NameStructOutSignal;

	UPROPERTY()
	FNameStructMapInoutSignal NameStructInoutSignal;

	UPROPERTY()
	FNameStructMapReturnSignal NameStructReturnSignal;

	UPROPERTY()
	FStringStructMapValueSignal StringStructValueSignal;

	UPROPERTY()
	FStringStructMapInSignal StringStructInSignal;

	UPROPERTY()
	FStringStructMapOutSignal StringStructOutSignal;

	UPROPERTY()
	FStringStructMapInoutSignal StringStructInoutSignal;

	UPROPERTY()
	FStringStructMapReturnSignal StringStructReturnSignal;

	/**
	 * Observe empty name-to-struct map Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty map
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int EmptyNameMapDefaultNum()
	{
		TMap<FName, FDelegateKeyValueMapValue> Items;
		return Items.Num();
	}

	/**
	 * Observe that NameStructValueSignal starts unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return true when NameStructValueSignal is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool NameSignalDefaultUnbound()
	{
		return !NameStructValueSignal.IsBound();
	}

	/**
	 * Observe a default map value Score.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a default value
	 * @Return 0
	 * @Boundary default score
	 */
	UFUNCTION()
	int ValueDefaultZero()
	{
		FDelegateKeyValueMapValue Value;
		return Value.Score;
	}
}
/** @end */
