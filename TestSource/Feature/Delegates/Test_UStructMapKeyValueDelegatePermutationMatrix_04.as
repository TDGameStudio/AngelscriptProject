// Theme: Feature.Delegates. Positive block 4: float-key map result storage.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 7434-7468.
// Isolation=none: wrap the raw UPROPERTY members. Oracle: FloatStructValueResult 0 /
// flags false / empty maps. Extra: empty TMap Num 0; 0.0f key miss. DefaultSafe.

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
	int FloatStructValueResult = 0;

	UPROPERTY()
	int FloatStructInResult = 0;

	UPROPERTY()
	int FloatStructInoutResult = 0;

	UPROPERTY()
	TMap<float, FDelegateKeyValueMapValue> FloatStructOutResult;

	UPROPERTY()
	TMap<float, FDelegateKeyValueMapValue> FloatStructInoutResultItems;

	UPROPERTY()
	TMap<float, FDelegateKeyValueMapValue> FloatStructReturnResult;

	UPROPERTY()
	bool FloatStructValuePreserved = false;

	UPROPERTY()
	bool FloatStructInPreserved = false;

	UPROPERTY()
	bool FloatStructOutPreserved = false;

	UPROPERTY()
	bool FloatStructInoutPreserved = false;

	UPROPERTY()
	bool FloatStructReturnPreserved = false;
}

int Observe_FloatStructValueResult_DefaultZero(ACoverageStructMapKeyValueDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_04 setup: required Actor is null");
	}
	return Actor.FloatStructValueResult;
}

int Observe_EmptyFloatMap_DefaultNum()
{
	TMap<float, FDelegateKeyValueMapValue> Items;
	return Items.Num();
}

bool Observe_ZeroFloatKey_MissingBoundary()
{
	TMap<float, FDelegateKeyValueMapValue> Items;
	FDelegateKeyValueMapValue Found;
	return !Items.Find(0.0f, Found) && Found.Score == 0;
}
