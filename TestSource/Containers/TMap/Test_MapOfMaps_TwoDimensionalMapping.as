// Theme: Containers.TMap. NegativeDiagnostic: nested TMap<int, TMap<FString, float>>.
// C++ ExpectNestedContainerRejected ASCoverageMapOfMapsUnsupported.
// Expected diagnostic: "Containers cannot be nested in other containers".
// Isolate the failing UCLASS. DiagnosticOnly.

UCLASS()
class ACoverageMapOfMapsActor : AActor
{
	UPROPERTY()
	TMap<int, TMap<FString, float>> NestedMap;
}
