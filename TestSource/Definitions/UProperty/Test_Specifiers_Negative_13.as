// Theme: Definitions.UProperty. Isolated compile-fail: empty specifier with a lone comma.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
// UPropSN_EmptyComma; lines 333-339;
// sha256=5a22345079496b99efc95a0ba9ea065517663ec14b4545632097998e223d5c80.
// Expected diagnostic: Empty specifier with lone comma should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropEmptyCommaActor : AActor
{
	UPROPERTY(,)
	int X = 0;
}
