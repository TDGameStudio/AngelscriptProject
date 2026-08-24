// Theme: Feature.Delegates. Positive block 1: map-key UObject and hashable key/value structs.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 7169-7213.
// Isolation=none: complete program. Oracle: default key ID 0 / value Score 0 / object Value 0.
// Extra: empty vs assigned Score; copy independence. DefaultSafe.

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

int Observe_Key_DefaultZero()
{
	FDelegateKeyValueMapKey Key;
	return Key.ID;
}

int Observe_Value_DefaultZero()
{
	FDelegateKeyValueMapValue Value;
	return Value.Score + Value.Label.Len();
}

int Observe_KeyObject_DefaultZero(UCoverageStructDelegateMapKeyObject Object)
{
	if (Object is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_01 setup: required Object is null");
	}
	return Object.Value;
}

bool Observe_Value_CopyIndependence()
{
	FDelegateKeyValueMapValue Original;
	Original.Score = 102;
	Original.Label = "NameValueB";
	FDelegateKeyValueMapValue Copy = Original;
	Copy.Score = 0;
	Copy.Label = "";
	return Original.Score == 102 && Copy.Score == 0;
}

bool Observe_KeyObject_NullBoundary()
{
	UCoverageStructDelegateMapKeyObject Object = nullptr;
	return Object == nullptr;
}
