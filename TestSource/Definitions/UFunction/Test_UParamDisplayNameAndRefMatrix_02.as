// Theme: Definitions.UFunction. Isolated compile-fail: UPARAM is not AngelScript parameter syntax.
// C++: AngelscriptCoverageUFunctionTests.cpp::UParamDisplayNameAndRefMatrix block 2
// Expected diagnostic: "Instead found '('"
// Isolate the failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionInvalidUParamActor : AActor
{
	UFUNCTION(BlueprintCallable)
	void InvalidUPARAM(UPARAM(DisplayName="Input Value") int Value)
	{
	}
}
