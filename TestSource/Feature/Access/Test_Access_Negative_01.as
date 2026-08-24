// Theme: Feature.Access. NegativeDiagnostic: private member read from outside.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 1 AssertFailsToCompile.
// Expected compile failure: "Reading private member from outside".
// Isolate the failing program. DiagnosticOnly.

class AActorPrivRead : AActor
{
	private int Secret = 42;
}

void Test()
{
	AActorPrivRead A;
	int X = A.Secret;
}
