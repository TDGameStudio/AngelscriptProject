// Theme: Feature.Access. NegativeDiagnostic: private method call from outside.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 2 AssertFailsToCompile.
// Expected compile failure: "Calling private method from outside".
// Isolate the failing program. DiagnosticOnly.

class AActorPrivMethod : AActor
{
	private void SecretMethod()
	{
	}
}

void Test()
{
	AActorPrivMethod A;
	A.SecretMethod();
}
