// Theme: Definitions.UFunction. NegativeDiagnostic: Server and Client together.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 3 AssertFailsToCompile.
// sha256=e2f6c67512a0932120562a8c92903ab832a46d1f8b66600924a04d00059f5993; lines 220-226.
// C++ currently wraps this AssertFailsToCompile in #if 0
// (#as-engine-behavior structural-validation-absent). Isolated failing program kept.
// Expected diagnostic: "Conflicting Server and Client should fail".
// DiagnosticOnly.

class AUFuncSvrCliActor : AActor
{
	UFUNCTION(Server, Client)
	void Foo()
	{
	}
}
