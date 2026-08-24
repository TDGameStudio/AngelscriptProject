// Theme: Debugger marker. Getter increments EvalCount; NeedsArg is not auto-eval.
// C++: AngelscriptDebuggerValueTests.cpp::FunctionEvaluationGuards
// Extra: EvalCount starts 0. DiagnosticOnly marker program.

UCLASS()
class UDebuggerValueGuardProbe : UObject
{
	UPROPERTY()
	int EvalCount = 0;

	UFUNCTION()
	int GetValue()
	{
		EvalCount += 1;
		return 42;
	}

	UFUNCTION()
	int NeedsArg(int Value)
	{
		EvalCount += 100;
		return Value;
	}
}
