// Theme: Feature.Default. Isolated compile-fail: defaults-only method from ordinary UFUNCTION.
// C++: AngelscriptDefaultStatementSafetyTests.cpp::DefaultsOnlyAccess
// CompileSafetyScript(..., bExpectedCompile=false). Expected diagnostic: "only accessible from default statements".
// DiagnosticOnly. Do not call BuildDefaultValue from a default statement; that would compile.

UCLASS()
class UDefaultsOnlyRejectTarget : UObject
{
	UPROPERTY()
	int Value = 0;

	int BuildDefaultValue() defaults
	{
		Value = 7;
		return Value;
	}

	UFUNCTION()
	int Entry()
	{
		return BuildDefaultValue();
	}
}
