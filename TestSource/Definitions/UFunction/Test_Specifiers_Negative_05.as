// Theme: Definitions.UFunction. NegativeDiagnostic: missing UFUNCTION closing parenthesis.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 5 AssertFailsToCompile.
// sha256=9160ebec365ad678f10d3f7b96df40bee807ecddb9d5e4b945153e77bf5d4a7e; lines 243-248.
// Expected diagnostic: "Missing closing parenthesis should fail".
// Keep the unclosed UFUNCTION( so the program stays failing. DiagnosticOnly.

class AUFuncMisParenActor : AActor
{
	UFUNCTION( void Foo() { }
}
