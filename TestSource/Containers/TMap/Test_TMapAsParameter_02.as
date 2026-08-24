// Theme: Containers.TMap. NegativeDiagnostic: mutate TMap passed by value.
// C++ CompileAndExpectFailure ASCoverageContainerParamTMapByValueMutationUnsupported.
// Expected diagnostic: "Non-const method call on read-only object reference".
// Isolate the failing UCLASS. DiagnosticOnly.

UCLASS()
class ACoverageContainerParamTMapByValueMutationActor : AActor
{
	int MutateByValue(TMap<int, FString> Map)
	{
		Map.Add(1, "One");
		return Map.Num();
	}
}
