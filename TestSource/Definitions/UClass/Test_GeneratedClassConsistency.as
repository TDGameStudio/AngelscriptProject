// Theme: Definitions.UClass. Positive: abstract BlueprintType generated class keeps Score and GetScore.
// C++: AngelscriptCompilerEndToEndTests.cpp::GeneratedClassConsistency
// Oracle: GetScore returns Score; default Score is 0 after NewObject of a non-abstract path is unavailable
// (class is Abstract). Extra: default handle is null. DefaultSafe.

UCLASS(Abstract, BlueprintType)
class UCompilerConsistencyCarrier : UObject
{
	UPROPERTY()
	int Score;

	UFUNCTION()
	int GetScore()
	{
		return Score;
	}
}

int Observe_Consistency_EmptyDefaultIsNull()
{
	UCompilerConsistencyCarrier Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
