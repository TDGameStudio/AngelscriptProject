// Theme: Containers.TSet. NegativeDiagnostic: TSet by-value parameter is read-only.
// C++: AngelscriptCoverageContainerParameterTests.cpp::TSetAsParameter CompileAndExpectFailure
// Expected diagnostic: "Non-const method call on read-only object reference".
// Isolate the failing MutateByValue program. DiagnosticOnly.

UCLASS()
class ACoverageContainerParamTSetByValueMutationActor : AActor
{
	int MutateByValue(TSet<int> Set)
	{
		Set.Add(1);
		return Set.Num();
	}
}
