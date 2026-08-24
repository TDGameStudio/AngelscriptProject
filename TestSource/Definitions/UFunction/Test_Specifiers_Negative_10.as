// Theme: Definitions.UFunction. NegativeDiagnostic: Server and NetMulticast together.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 10 AssertFailsToCompile.
// sha256=6b8b35eb4615ef08011dec735919e2c825c5981b6b2bfe4241c9b328aa5c84e3; lines 303-309.
// C++ currently wraps this AssertFailsToCompile in #if 0
// (#as-engine-behavior structural-validation-absent). Isolated failing program kept.
// Expected diagnostic: "Conflicting Server and NetMulticast should fail".
// DiagnosticOnly.

class AUFuncSvrMCActor : AActor
{
	UFUNCTION(Server, NetMulticast)
	void Foo()
	{
	}
}
