// Theme: Definitions.UStruct. WorldStory block 1: map key/value parameter actor storage.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueParameterAndReturnMatrix lines 12151-12311.
// Isolation=none: this file is a complete program. Oracle: default counts 0 and flags false.
// Extra: empty inout maps. FixtureIsolated.

UCLASS()
class UCoverageStructMapParamValueObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

USTRUCT(BlueprintType)
struct FMapParamKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FMapParamKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FMapParamValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructMapParamMatrixActor : AActor
{
	UPROPERTY()
	int NameStructValueCount = 0;

	UPROPERTY()
	int NameStructInCount = 0;

	UPROPERTY()
	TMap<FName, FMapParamValue> NameStructInout;

	UPROPERTY()
	bool NameStructValuePreserved = false;

	UPROPERTY()
	bool NameStructInPreserved = false;

	UPROPERTY()
	bool NameStructInoutSawOriginal = false;

	UPROPERTY()
	bool NameStructInoutMutated = false;

	UPROPERTY()
	bool NameStructReturnPreserved = false;

	UPROPERTY()
	int StringStructValueCount = 0;

	UPROPERTY()
	int StringStructInCount = 0;

	UPROPERTY()
	TMap<FString, FMapParamValue> StringStructInout;

	UPROPERTY()
	bool StringStructValuePreserved = false;

	UPROPERTY()
	bool StringStructInPreserved = false;

	UPROPERTY()
	bool StringStructInoutSawOriginal = false;

	UPROPERTY()
	bool StringStructInoutMutated = false;

	UPROPERTY()
	bool StringStructReturnPreserved = false;

	UPROPERTY()
	int StructStringValueCount = 0;

	UPROPERTY()
	int StructStringInCount = 0;

	UPROPERTY()
	TMap<FMapParamKey, FString> StructStringInout;

	UPROPERTY()
	bool StructStringValuePreserved = false;

	UPROPERTY()
	bool StructStringInPreserved = false;

	UPROPERTY()
	bool StructStringInoutSawOriginal = false;

	UPROPERTY()
	bool StructStringInoutMutated = false;

	UPROPERTY()
	bool StructStringReturnPreserved = false;

	UPROPERTY()
	int StructNameValueCount = 0;

	UPROPERTY()
	int StructNameInCount = 0;

	UPROPERTY()
	TMap<FMapParamKey, FName> StructNameInout;

	UPROPERTY()
	bool StructNameValuePreserved = false;

	UPROPERTY()
	bool StructNameInPreserved = false;

	UPROPERTY()
	bool StructNameInoutSawOriginal = false;

	UPROPERTY()
	bool StructNameInoutMutated = false;

	UPROPERTY()
	bool StructNameReturnPreserved = false;

	UPROPERTY()
	int StructObjectValueCount = 0;

	UPROPERTY()
	int StructObjectInCount = 0;

	UPROPERTY()
	TMap<FMapParamKey, UCoverageStructMapParamValueObject> StructObjectInout;

	UPROPERTY()
	bool StructObjectValuePreserved = false;

	UPROPERTY()
	bool StructObjectInPreserved = false;

	UPROPERTY()
	bool StructObjectInoutSawOriginal = false;

	UPROPERTY()
	bool StructObjectInoutMutated = false;

	UPROPERTY()
	bool StructObjectReturnPreserved = false;
}

bool Observe_MapParamStorage_DefaultEmpty(ACoverageStructMapParamMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueParameterAndReturnMatrix_01 setup: required Actor is null");
	}
	return Actor.NameStructValueCount == 0
		&& Actor.StringStructValueCount == 0
		&& Actor.StructStringValueCount == 0
		&& Actor.StructNameValueCount == 0
		&& Actor.StructObjectValueCount == 0
		&& Actor.NameStructInout.Num() == 0
		&& Actor.StringStructInout.Num() == 0
		&& Actor.StructStringInout.Num() == 0
		&& Actor.StructNameInout.Num() == 0
		&& Actor.StructObjectInout.Num() == 0
		&& !Actor.NameStructValuePreserved
		&& !Actor.StructObjectReturnPreserved;
}

bool Observe_MapParamStorage_KeyHashBoundary()
{
	FMapParamKey Zero;
	FMapParamKey Named;
	Named.ID = 1;
	Named.Tag = n"Tag";
	return Zero.ID == 0 && Zero.Hash() == uint32(0) && !(Zero == Named) && Named.Hash() != uint32(0);
}

int Observe_MapParamStorage_ValueObjectDefault()
{
	UCoverageStructMapParamValueObject Object = Cast<UCoverageStructMapParamValueObject>(NewObject(nullptr, UCoverageStructMapParamValueObject::StaticClass()));
	if (Object == nullptr)
	{
		throw("TS-DEF-0317 setup: UCoverageStructMapParamValueObject NewObject returned null");
	}
	return Object.Value;
}
