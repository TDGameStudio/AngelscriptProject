// Theme: Containers.TMap. NegativeDiagnostic: nested TMap<FString, TArray<int>>.
// CSV WorldStory is wrong; C++ CompileAndExpectFailure ASCoverageTMap_ArrayValueUnsupported.
// Expected diagnostic: "Containers cannot be nested in other containers".
// Isolate the failing UCLASS. DiagnosticOnly.

UCLASS()
class ACoverageTMapArrayValueActor : AActor
{
	UPROPERTY()
	TMap<FString, TArray<int>> StringToArrayMap;
}
