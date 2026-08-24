// Theme: Feature.Access. NegativeDiagnostic: private member read from an unrelated class.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 10 AssertFailsToCompile.
// Expected compile failure: "Reading private from unrelated class".
// Isolate the failing program. DiagnosticOnly.

class AActorPrivViaUnrel : AActor
{
	private int Secret = 42;
}

class AOther : AActor
{
	void Foo()
	{
		AActorPrivViaUnrel A;
		int X = A.Secret;
	}
}
