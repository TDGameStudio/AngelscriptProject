// Theme: Feature.PropertyAccess. Isolated compile-fail: TSet set-operation aliases.
// C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetSetOperations block 2
// CompileAndExpectFailure. Expected diagnostics:
// TSet::Union / Intersect / Difference / Includes / FilterByPredicate
// have no matching signatures.
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageTSetSetOperationAliasesActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TSet<int> Values;
		TSet<int> Other;
		Values.Union(Other);
		Values.Intersect(Other);
		Values.Difference(Other);
		Values.Includes(Other);
		Values.FilterByPredicate(1);
	}
}
