// Theme: Definitions.Meta. Isolated compile-fail: UPARAM is a C++ UHT spelling, not script UFUNCTION params.
// C++: UParamModifiers CompileAndExpectFailure. CSV WorldStory is wrong.
// Expected diagnostic: "Expected identifier" / "Instead found '('".
// Isolate this failing program; do not strip UPARAM to make it compile.
// DiagnosticOnly.

UCLASS()
class ACoverageMacrosUParamActor : AActor
{
	UFUNCTION(BlueprintCallable, Category="Testing")
	void ProcessValue(
		UPARAM(DisplayName="Input Number") int InValue,
		UPARAM(DisplayName="Result", ref) int&out OutResult)
	{
	}
}
