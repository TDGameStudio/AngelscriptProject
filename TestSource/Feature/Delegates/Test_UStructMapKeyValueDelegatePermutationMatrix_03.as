// Theme: Feature.Delegates. Positive block 3: remaining signals plus name/string result storage.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 7291-7433.
// Isolation=none: wrap the raw UPROPERTY members with the types they use. Oracle: defaults
// NameStructValueResult 0 / flags false / empty maps. Extra: empty TMap Num 0. DefaultSafe.

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

delegate int FFloatStructMapValueSignal(TMap<float, FDelegateKeyValueMapValue> Items);
delegate int FFloatStructMapInSignal(const TMap<float, FDelegateKeyValueMapValue>&in Items);
delegate void FFloatStructMapOutSignal(TMap<float, FDelegateKeyValueMapValue>&out Items);
delegate int FFloatStructMapInoutSignal(TMap<float, FDelegateKeyValueMapValue>&inout Items);
delegate TMap<float, FDelegateKeyValueMapValue> FFloatStructMapReturnSignal();
delegate int FObjectStructMapValueSignal(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> Items);
delegate int FObjectStructMapInSignal(const TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&in Items);
delegate void FObjectStructMapOutSignal(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&out Items);
delegate int FObjectStructMapInoutSignal(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&inout Items);
delegate TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> FObjectStructMapReturnSignal();
delegate int FStructStringMapValueSignal(TMap<FDelegateKeyValueMapKey, FString> Items);
delegate int FStructStringMapInSignal(const TMap<FDelegateKeyValueMapKey, FString>&in Items);
delegate void FStructStringMapOutSignal(TMap<FDelegateKeyValueMapKey, FString>&out Items);
delegate int FStructStringMapInoutSignal(TMap<FDelegateKeyValueMapKey, FString>&inout Items);
delegate TMap<FDelegateKeyValueMapKey, FString> FStructStringMapReturnSignal();
delegate int FStructNameMapValueSignal(TMap<FDelegateKeyValueMapKey, FName> Items);
delegate int FStructNameMapInSignal(const TMap<FDelegateKeyValueMapKey, FName>&in Items);
delegate void FStructNameMapOutSignal(TMap<FDelegateKeyValueMapKey, FName>&out Items);
delegate int FStructNameMapInoutSignal(TMap<FDelegateKeyValueMapKey, FName>&inout Items);
delegate TMap<FDelegateKeyValueMapKey, FName> FStructNameMapReturnSignal();
delegate int FStructObjectMapValueSignal(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> Items);
delegate int FStructObjectMapInSignal(const TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&in Items);
delegate void FStructObjectMapOutSignal(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&out Items);
delegate int FStructObjectMapInoutSignal(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&inout Items);
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
}

int Observe_NameStructValueResult_DefaultZero(ACoverageStructMapKeyValueDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_03 setup: required Actor is null");
	}
	return Actor.NameStructValueResult;
}

int Observe_NameStructOutResult_DefaultNum(ACoverageStructMapKeyValueDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_03 setup: required Actor is null");
	}
	return Actor.NameStructOutResult.Num();
}

bool Observe_NameStructValuePreserved_DefaultFalse(ACoverageStructMapKeyValueDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_03 setup: required Actor is null");
	}
	return !Actor.NameStructValuePreserved;
}
