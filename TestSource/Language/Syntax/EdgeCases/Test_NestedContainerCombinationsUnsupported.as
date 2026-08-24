// Theme: Language.Syntax.EdgeCases. NegativeDiagnostic: nested containers.
// C++: AngelscriptCoverageContainerAdvancedTests.cpp::NestedContainerCombinationsUnsupported
// sha256=81c9921fca1f6b16b34a37ae4bdaa8f371c55208c4867f79299a1ad0d8f60dac; lines 408-415.
// Expected diagnostic: Containers cannot be nested in other containers.
// Isolate this failing UCLASS. DiagnosticOnly.

UCLASS()
class ACoverageContainerArrayOfMapsActor : AActor
{
	UPROPERTY()
	TArray<TMap<int, FString>> ArrayOfMaps;
}
