// Theme: Feature.Access. NegativeDiagnostic: protected member read from a free function.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 3 AssertFailsToCompile.
// Expected compile failure: "Accessing protected member from outside".
// Isolate the failing program. DiagnosticOnly.

class AActorProtOut : AActor
{
	protected int ProtVal = 10;
}

void Test()
{
	AActorProtOut A;
	int X = A.ProtVal;
}
