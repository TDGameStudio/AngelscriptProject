// Theme: Feature.Delegates. WorldStory block 2: name/string/float/object/struct map-delegate types.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 7214-7290.
// Isolation=none: wrap delegates and the actor signal members with key/value types.
// Oracle: default NameStructValueSignal unbound. Extra: empty TMap Num 0. FixtureIsolated.

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

delegate int FNameStructMapValueSignal(TMap<FName, FDelegateKeyValueMapValue> Items);
delegate int FNameStructMapInSignal(const TMap<FName, FDelegateKeyValueMapValue>&in Items);
delegate void FNameStructMapOutSignal(TMap<FName, FDelegateKeyValueMapValue>&out Items);
delegate int FNameStructMapInoutSignal(TMap<FName, FDelegateKeyValueMapValue>&inout Items);
delegate TMap<FName, FDelegateKeyValueMapValue> FNameStructMapReturnSignal();

delegate int FStringStructMapValueSignal(TMap<FString, FDelegateKeyValueMapValue> Items);
delegate int FStringStructMapInSignal(const TMap<FString, FDelegateKeyValueMapValue>&in Items);
delegate void FStringStructMapOutSignal(TMap<FString, FDelegateKeyValueMapValue>&out Items);
delegate int FStringStructMapInoutSignal(TMap<FString, FDelegateKeyValueMapValue>&inout Items);
delegate TMap<FString, FDelegateKeyValueMapValue> FStringStructMapReturnSignal();

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
}

int Observe_EmptyNameMap_DefaultNum()
{
	TMap<FName, FDelegateKeyValueMapValue> Items;
	return Items.Num();
}

bool Observe_NameSignal_DefaultUnbound(ACoverageStructMapKeyValueDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_02 setup: required Actor is null");
	}
	return !Actor.NameStructValueSignal.IsBound();
}

int Observe_Value_DefaultZero()
{
	FDelegateKeyValueMapValue Value;
	return Value.Score;
}
