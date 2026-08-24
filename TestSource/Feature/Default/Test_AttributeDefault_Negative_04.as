// Theme: Feature.Default. Isolated compile-fail: default statement without a semicolon.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative AssertFailsToCompile
// ASSyntaxDS_AttrNoSemicolon. Expected diagnostic: "Default without semicolon should fail".
// DiagnosticOnly. Do not add the missing semicolon.

class AAttrNoSemiActor : AActor
{
	UPROPERTY()
	int X = 0;

	default X = 5
}
