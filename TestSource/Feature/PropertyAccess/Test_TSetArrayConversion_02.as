// Theme: Feature.PropertyAccess. Isolated compile-fail: TSet.Array() is unsupported.
// C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetArrayConversion block 2
// CompileAndExpectFailure. Expected diagnostic:
// "No matching signatures to 'TSet::Array()'".
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageTSetArrayConversionUnsupportedActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TSet<int> Values;
		Values.Add(1);
		TArray<int> Converted = Values.Array();
	}
}
