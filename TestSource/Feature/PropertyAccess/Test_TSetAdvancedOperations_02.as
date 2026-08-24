// Theme: Feature.PropertyAccess. Isolated compile-fail: TSet.Find is unsupported.
// C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetAdvancedOperations block 2
// CompileAndExpectFailure. Expected diagnostic:
// "No matching signatures to 'TSet::Find(const int)'".
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageTSetFindUnsupportedActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TSet<int> Values;
		Values.Add(1);
		Values.Find(1);
	}
}
