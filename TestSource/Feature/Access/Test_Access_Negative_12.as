// Theme: Feature.Access. NegativeDiagnostic: private Init method call from outside.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 12 AssertFailsToCompile.
// Expected compile failure: "Calling private Init from outside".
// Isolate the failing program. DiagnosticOnly.

class AActorPrivStatic : AActor
{
	private void Init()
	{
	}
}

void Test()
{
	AActorPrivStatic A;
	A.Init();
}
