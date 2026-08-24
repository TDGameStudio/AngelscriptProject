// Theme: Feature.Delegates. WorldStory block 1: bool/float map-delegate types and storage.
// C++: AngelscriptCoverageUStructTests.cpp::UStructExtendedMapDelegatePermutationMatrix lines 6503-6698.
// Isolation=none: complete program. Oracle: default BoolStructValueResult 0 / empty maps /
// preserved flags false. Extra: default key ID 0; empty TMap Num 0. FixtureIsolated.

USTRUCT(BlueprintType)
struct FDelegateExtendedMapKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FDelegateExtendedMapKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 887) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FDelegateExtendedMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

delegate int FBoolStructMapValueSignal(TMap<bool, FDelegateExtendedMapValue> Items);
delegate int FBoolStructMapInSignal(const TMap<bool, FDelegateExtendedMapValue>&in Items);
delegate void FBoolStructMapOutSignal(TMap<bool, FDelegateExtendedMapValue>&out Items);
delegate int FBoolStructMapInoutSignal(TMap<bool, FDelegateExtendedMapValue>&inout Items);
delegate TMap<bool, FDelegateExtendedMapValue> FBoolStructMapReturnSignal();

delegate int FStructBoolMapValueSignal(TMap<FDelegateExtendedMapKey, bool> Items);
delegate int FStructBoolMapInSignal(const TMap<FDelegateExtendedMapKey, bool>&in Items);
delegate void FStructBoolMapOutSignal(TMap<FDelegateExtendedMapKey, bool>&out Items);
delegate int FStructBoolMapInoutSignal(TMap<FDelegateExtendedMapKey, bool>&inout Items);
delegate TMap<FDelegateExtendedMapKey, bool> FStructBoolMapReturnSignal();

delegate int FStructFloatMapValueSignal(TMap<FDelegateExtendedMapKey, float> Items);
delegate int FStructFloatMapInSignal(const TMap<FDelegateExtendedMapKey, float>&in Items);
delegate void FStructFloatMapOutSignal(TMap<FDelegateExtendedMapKey, float>&out Items);
delegate int FStructFloatMapInoutSignal(TMap<FDelegateExtendedMapKey, float>&inout Items);
delegate TMap<FDelegateExtendedMapKey, float> FStructFloatMapReturnSignal();

UCLASS()
class ACoverageStructExtendedMapDelegateActor : AActor
{
	UPROPERTY()
	FBoolStructMapValueSignal BoolStructValueSignal;
	UPROPERTY()
	FBoolStructMapInSignal BoolStructInSignal;
	UPROPERTY()
	FBoolStructMapOutSignal BoolStructOutSignal;
	UPROPERTY()
	FBoolStructMapInoutSignal BoolStructInoutSignal;
	UPROPERTY()
	FBoolStructMapReturnSignal BoolStructReturnSignal;
	UPROPERTY()
	FStructBoolMapValueSignal StructBoolValueSignal;
	UPROPERTY()
	FStructBoolMapInSignal StructBoolInSignal;
	UPROPERTY()
	FStructBoolMapOutSignal StructBoolOutSignal;
	UPROPERTY()
	FStructBoolMapInoutSignal StructBoolInoutSignal;
	UPROPERTY()
	FStructBoolMapReturnSignal StructBoolReturnSignal;
	UPROPERTY()
	FStructFloatMapValueSignal StructFloatValueSignal;
	UPROPERTY()
	FStructFloatMapInSignal StructFloatInSignal;
	UPROPERTY()
	FStructFloatMapOutSignal StructFloatOutSignal;
	UPROPERTY()
	FStructFloatMapInoutSignal StructFloatInoutSignal;
	UPROPERTY()
	FStructFloatMapReturnSignal StructFloatReturnSignal;

	UPROPERTY()
	int BoolStructValueResult = 0;
	UPROPERTY()
	int BoolStructInResult = 0;
	UPROPERTY()
	int BoolStructInoutResult = 0;
	UPROPERTY()
	TMap<bool, FDelegateExtendedMapValue> BoolStructOutResult;
	UPROPERTY()
	TMap<bool, FDelegateExtendedMapValue> BoolStructInoutResultItems;
	UPROPERTY()
	TMap<bool, FDelegateExtendedMapValue> BoolStructReturnResult;
	UPROPERTY()
	bool BoolStructValuePreserved = false;
	UPROPERTY()
	bool BoolStructInPreserved = false;
	UPROPERTY()
	bool BoolStructOutPreserved = false;
	UPROPERTY()
	bool BoolStructInoutPreserved = false;
	UPROPERTY()
	bool BoolStructReturnPreserved = false;
	UPROPERTY()
	int StructBoolValueResult = 0;
	UPROPERTY()
	int StructBoolInResult = 0;
	UPROPERTY()
	int StructBoolInoutResult = 0;
	UPROPERTY()
	TMap<FDelegateExtendedMapKey, bool> StructBoolOutResult;
	UPROPERTY()
	TMap<FDelegateExtendedMapKey, bool> StructBoolInoutResultItems;
	UPROPERTY()
	TMap<FDelegateExtendedMapKey, bool> StructBoolReturnResult;
	UPROPERTY()
	bool StructBoolValuePreserved = false;
	UPROPERTY()
	bool StructBoolInPreserved = false;
	UPROPERTY()
	bool StructBoolOutPreserved = false;
	UPROPERTY()
	bool StructBoolInoutPreserved = false;
	UPROPERTY()
	bool StructBoolReturnPreserved = false;
	UPROPERTY()
	int StructFloatValueResult = 0;
	UPROPERTY()
	int StructFloatInResult = 0;
	UPROPERTY()
	int StructFloatInoutResult = 0;
	UPROPERTY()
	TMap<FDelegateExtendedMapKey, float> StructFloatOutResult;
	UPROPERTY()
	TMap<FDelegateExtendedMapKey, float> StructFloatInoutResultItems;
	UPROPERTY()
	TMap<FDelegateExtendedMapKey, float> StructFloatReturnResult;
	UPROPERTY()
	bool StructFloatValuePreserved = false;
	UPROPERTY()
	bool StructFloatInPreserved = false;
	UPROPERTY()
	bool StructFloatOutPreserved = false;
	UPROPERTY()
	bool StructFloatInoutPreserved = false;
	UPROPERTY()
	bool StructFloatReturnPreserved = false;
}

int Observe_BoolStructValueResult_DefaultZero(ACoverageStructExtendedMapDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructExtendedMapDelegatePermutationMatrix_01 setup: required Actor is null");
	}
	return Actor.BoolStructValueResult;
}

int Observe_Key_DefaultZero()
{
	FDelegateExtendedMapKey Key;
	return Key.ID + Key.Hash();
}

int Observe_EmptyBoolMap_DefaultNum()
{
	TMap<bool, FDelegateExtendedMapValue> Items;
	return Items.Num();
}

bool Observe_Value_CopyIndependence()
{
	FDelegateExtendedMapValue Original;
	Original.Score = 102;
	Original.Label = "BoolValueFalse";
	FDelegateExtendedMapValue Copy = Original;
	Copy.Score = 0;
	Copy.Label = "";
	return Original.Score == 102 && Copy.Score == 0;
}
