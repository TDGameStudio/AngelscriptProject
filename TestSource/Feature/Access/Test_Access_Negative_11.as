// Theme: Feature.Access. NegativeDiagnostic: protected member write from a free function.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 11 AssertFailsToCompile.
// Expected compile failure: "Writing to protected member from outside".
// Isolate the failing program. DiagnosticOnly.

class AActorProtWrite : AActor
{
	protected int ProtVal = 0;
}

void Test()
{
	AActorProtWrite A;
	A.ProtVal = 99;
}
