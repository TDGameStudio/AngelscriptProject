// Theme: Feature.Access. NegativeDiagnostic: private member write from outside.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 8 AssertFailsToCompile.
// Expected compile failure: "Writing to private member from outside".
// Isolate the failing program. DiagnosticOnly.

class AActorPrivWrite : AActor
{
	private int X = 0;
}

void Test()
{
	AActorPrivWrite A;
	A.X = 5;
}
