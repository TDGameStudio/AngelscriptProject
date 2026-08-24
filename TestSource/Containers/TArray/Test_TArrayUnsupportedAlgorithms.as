// Theme: Containers.TArray. NegativeDiagnostic: StableSort/Heap/predicate aliases.
// Expected compile failure. DiagnosticOnly.

UCLASS()
class ACoverageTArrayUnsupportedAlgorithmsActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.StableSort();
		Values.FilterByPredicate(1);
		Values.FindByKey(1);
		Values.FindByPredicate(1);
		Values.Heapify();
		Values.HeapPop();
		Values.HeapPush(3);
		Values.LowerBound(1);
		Values.UpperBound(2);
	}
}
