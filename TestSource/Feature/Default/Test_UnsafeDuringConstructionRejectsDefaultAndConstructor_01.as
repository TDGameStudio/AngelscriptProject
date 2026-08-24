// Theme: Feature.Default. Isolated compile-fail: unsafe_during_construction in a default statement.
// C++: AngelscriptDefaultStatementSafetyTests.cpp::UnsafeDuringConstructionRejectsDefaultAndConstructor
// CompileSafetyScript(..., bExpectedCompile=false). Expected diagnostic: "unsafe during construction".
// DiagnosticOnly. Do not move UnsafeValue off the default statement.

UCLASS()
class UUnsafeDefaultTarget : UObject
{
	UPROPERTY()
	int Value = 0;

	int UnsafeValue() unsafe_during_construction
	{
		return 7;
	}

	default Value = UnsafeValue();
}
