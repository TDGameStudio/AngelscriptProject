// Theme: Feature.Default. Isolated compile-fail: default value type mismatch.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative AssertFailsToCompile
// ASSyntaxDS_AttrTypeMismatch. Expected diagnostic: "Default with type mismatch should fail".
// DiagnosticOnly. Do not change the string literal to an int.

class AAttrTypeMismatchActor : AActor
{
	UPROPERTY()
	int Health = 0;

	default Health = "hello";
}
