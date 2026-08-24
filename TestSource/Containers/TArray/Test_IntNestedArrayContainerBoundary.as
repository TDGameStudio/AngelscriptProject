// Theme: Containers.TArray. Nested TArray<TArray<int>> property is compile-fail
// (C++ ExpectNestedContainerRejected). Isolate. DiagnosticOnly.

UCLASS()
class ACoverageIntNestedArrayActor : AActor
{
	UPROPERTY()
	TArray<TArray<int>> Matrix;
}
