// Theme: Definitions.UProperty. Isolated compile-fail: numeric literal as specifier.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
// UPropSN_NumberSpec; lines 355-361;
// sha256=476165cb02742df45b939c5096a306c88580a222ea21dd82bfe3eda9934f2a70.
// Expected diagnostic: Numeric literal as specifier should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropNumSpecActor : AActor
{
	UPROPERTY(123)
	int X = 0;
}
