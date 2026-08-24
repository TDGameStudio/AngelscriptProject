// Theme: Definitions.UProperty. Isolated compile-fail: unknown specifier.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
// UPropSN_Invalid; lines 194-200;
// sha256=413eef42ffa74a5548b10661bb81387ee0c20955d81166d8b7052d41631b0d19.
// Expected diagnostic: Unknown property specifier (method expects 3 occurrences).
// DiagnosticOnly. Isolated failing program.

class AUPropInvalidActor : AActor
{
	UPROPERTY(InvalidSpecifier)
	int X = 0;
}
