// Theme: Feature.Access. NegativeDiagnostic: protected method call from a free function.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 9 AssertFailsToCompile.
// Expected compile failure: "Calling protected method from outside".
// Isolate the failing program. DiagnosticOnly.

class AActorProtMethodOut : AActor
{
	protected void InternalMethod()
	{
	}
}

void Test()
{
	AActorProtMethodOut A;
	A.InternalMethod();
}
