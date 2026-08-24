// Theme: Feature.Delegates. Positive block 5: object/string/name/object-value map storage.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 7469-7602.
// Isolation=none: wrap the raw UPROPERTY members with key/value/object types. Oracle:
// ObjectStructValueResult 0 / flags false / empty maps. Extra: empty TMap Num 0; null object.
// DefaultSafe. Keep ObjectStruct* / StructString* / StructName* / StructObject*.

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

	bool opEquals(const FDelegateKeyValueMapKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

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
}

int Observe_ObjectStructValueResult_DefaultZero(ACoverageStructMapKeyValueDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_05 setup: required Actor is null");
	}
	return Actor.ObjectStructValueResult + Actor.StructStringValueResult + Actor.StructNameValueResult + Actor.StructObjectValueResult;
}

int Observe_EmptyObjectMap_DefaultNum()
{
	TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> Items;
	return Items.Num();
}

bool Observe_ValueObject_NullBoundary()
{
	UCoverageStructDelegateMapValueObject Object = nullptr;
	return Object == nullptr;
}
