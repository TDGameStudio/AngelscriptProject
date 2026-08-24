// Theme: Feature.Delegates. Positive block 6: MakeKey / MakeValue / MakeKeyObject / MakeObject.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 7603-7634.
// Isolation=none: wrap helpers with key/value/object types. Oracle: MakeKey(0) ID 0;
// MakeObject(0) Value 0. Extra: nullptr object boundary. DefaultSafe.

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
	FDelegateKeyValueMapKey MakeKey(int ID, FName Tag)
	{
		FDelegateKeyValueMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	FDelegateKeyValueMapValue MakeValue(int Score, FString Label)
	{
		FDelegateKeyValueMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	UCoverageStructDelegateMapKeyObject MakeKeyObject(int Value)
	{
		UCoverageStructDelegateMapKeyObject Object = Cast<UCoverageStructDelegateMapKeyObject>(NewObject(this, UCoverageStructDelegateMapKeyObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	UCoverageStructDelegateMapValueObject MakeObject(int Value)
	{
		UCoverageStructDelegateMapValueObject Object = Cast<UCoverageStructDelegateMapValueObject>(NewObject(this, UCoverageStructDelegateMapValueObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}
}

int Observe_MakeKey_ZeroBoundary(ACoverageStructMapKeyValueDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_06 setup: required Actor is null");
	}
	FDelegateKeyValueMapKey Key = Actor.MakeKey(0, n"");
	return Key.ID;
}

int Observe_MakeValue_ZeroBoundary(ACoverageStructMapKeyValueDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_06 setup: required Actor is null");
	}
	FDelegateKeyValueMapValue Value = Actor.MakeValue(0, "");
	return Value.Score + Value.Label.Len();
}

bool Observe_MakeObject_NullBoundary()
{
	UCoverageStructDelegateMapValueObject Object = nullptr;
	return Object == nullptr;
}

bool Observe_Key_CopyIndependence()
{
	FDelegateKeyValueMapKey Original;
	Original.ID = 301;
	Original.Tag = n"StructStringValueB";
	FDelegateKeyValueMapKey Copy = Original;
	Copy.ID = 0;
	return Original.ID == 301 && Copy.ID == 0;
}
