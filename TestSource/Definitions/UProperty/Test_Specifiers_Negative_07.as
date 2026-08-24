// Theme: Definitions.UProperty. Isolated compile-fail: missing UPROPERTY closing paren.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
// UPropSN_MissingParen; lines 263-268;
// sha256=7e65ded9b0372ba9a6ffefc4e0891c06ebcf6b60621402ee1192a57313e87106.
// Expected diagnostic: Missing closing parenthesis should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropMisParenActor : AActor
{
	UPROPERTY( int X = 0;
}
