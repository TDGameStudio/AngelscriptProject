// Theme: Containers.TArray. NegativeDiagnostic: Find/FindLast/Reverse/RemoveAll aliases.
// Expected compile failure. DiagnosticOnly.

UCLASS()
class ACoverageTArrayUnsupportedApiActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Find(1);
		Values.FindLast(1);
		Values.Reverse();
		Values.RemoveAll(1);
	}
}
