/**
 * Remaining signals plus name/string result storage. Defaults
 * NameStructValueResult 0, flags false, empty maps. Empty TMap Num 0.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.MapKeyValueRemainingSignalsAndNameStringResults
 * @Harness UClass
 * @Tag Feature.Delegates.MapKeyValueRemainingSignalsAndNameStringResults
 * @Provenance Theme: Feature.Delegates. Positive block 3: remaining signals plus name/string result storage.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 7291-7433.
 * @Provenance Isolation=none: wrap the raw UPROPERTY members with the types they use. Oracle: defaults
 * @Provenance NameStructValueResult 0 / flags false / empty maps. Extra: empty TMap Num 0. DefaultSafe.
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
	 * @Covers Delegates.MapKeyValueRemainingSignalsAndNameStringResults
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
	 * @Covers Delegates.MapKeyValueRemainingSignalsAndNameStringResults
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
	FFloatStructMapValueSignal FloatStructValueSignal;

	UPROPERTY()
	FFloatStructMapInSignal FloatStructInSignal;

	UPROPERTY()
	FFloatStructMapOutSignal FloatStructOutSignal;

	UPROPERTY()
	FFloatStructMapInoutSignal FloatStructInoutSignal;

	UPROPERTY()
	FFloatStructMapReturnSignal FloatStructReturnSignal;

	UPROPERTY()
	FObjectStructMapValueSignal ObjectStructValueSignal;

	UPROPERTY()
	FObjectStructMapInSignal ObjectStructInSignal;

	UPROPERTY()
	FObjectStructMapOutSignal ObjectStructOutSignal;

	UPROPERTY()
	FObjectStructMapInoutSignal ObjectStructInoutSignal;

	UPROPERTY()
	FObjectStructMapReturnSignal ObjectStructReturnSignal;

	UPROPERTY()
	FStructStringMapValueSignal StructStringValueSignal;

	UPROPERTY()
	FStructStringMapInSignal StructStringInSignal;

	UPROPERTY()
	FStructStringMapOutSignal StructStringOutSignal;

	UPROPERTY()
	FStructStringMapInoutSignal StructStringInoutSignal;

	UPROPERTY()
	FStructStringMapReturnSignal StructStringReturnSignal;

	UPROPERTY()
	FStructNameMapValueSignal StructNameValueSignal;

	UPROPERTY()
	FStructNameMapInSignal StructNameInSignal;

	UPROPERTY()
	FStructNameMapOutSignal StructNameOutSignal;

	UPROPERTY()
	FStructNameMapInoutSignal StructNameInoutSignal;

	UPROPERTY()
	FStructNameMapReturnSignal StructNameReturnSignal;

	UPROPERTY()
	FStructObjectMapValueSignal StructObjectValueSignal;

	UPROPERTY()
	FStructObjectMapInSignal StructObjectInSignal;

	UPROPERTY()
	FStructObjectMapOutSignal StructObjectOutSignal;

	UPROPERTY()
	FStructObjectMapInoutSignal StructObjectInoutSignal;

	UPROPERTY()
	FStructObjectMapReturnSignal StructObjectReturnSignal;

	UPROPERTY()
	int NameStructValueResult = 0;

	UPROPERTY()
	int NameStructInResult = 0;

	UPROPERTY()
	int NameStructInoutResult = 0;

	UPROPERTY()
	TMap<FName, FDelegateKeyValueMapValue> NameStructOutResult;

	UPROPERTY()
	TMap<FName, FDelegateKeyValueMapValue> NameStructInoutResultItems;

	UPROPERTY()
	TMap<FName, FDelegateKeyValueMapValue> NameStructReturnResult;

	UPROPERTY()
	bool NameStructValuePreserved = false;

	UPROPERTY()
	bool NameStructInPreserved = false;

	UPROPERTY()
	bool NameStructOutPreserved = false;

	UPROPERTY()
	bool NameStructInoutPreserved = false;

	UPROPERTY()
	bool NameStructReturnPreserved = false;

	UPROPERTY()
	int StringStructValueResult = 0;

	UPROPERTY()
	int StringStructInResult = 0;

	UPROPERTY()
	int StringStructInoutResult = 0;

	UPROPERTY()
	TMap<FString, FDelegateKeyValueMapValue> StringStructOutResult;

	UPROPERTY()
	TMap<FString, FDelegateKeyValueMapValue> StringStructInoutResultItems;

	UPROPERTY()
	TMap<FString, FDelegateKeyValueMapValue> StringStructReturnResult;

	UPROPERTY()
	bool StringStructValuePreserved = false;

	UPROPERTY()
	bool StringStructInPreserved = false;

	UPROPERTY()
	bool StringStructOutPreserved = false;

	UPROPERTY()
	bool StringStructInoutPreserved = false;

	UPROPERTY()
	bool StringStructReturnPreserved = false;

	/**
	 * Observe the default NameStructValueResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default NameStructValueResult
	 */
	UFUNCTION()
	int NameStructValueResultDefaultZero()
	{
		return NameStructValueResult;
	}

	/**
	 * Observe the default NameStructOutResult Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default NameStructOutResult
	 */
	UFUNCTION()
	int NameStructOutResultDefaultNum()
	{
		return NameStructOutResult.Num();
	}

	/**
	 * Observe the default NameStructValuePreserved.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return true when NameStructValuePreserved is false
	 * @Boundary default preserved flag
	 */
	UFUNCTION()
	bool NameStructValuePreservedDefaultFalse()
	{
		return !NameStructValuePreserved;
	}
}
