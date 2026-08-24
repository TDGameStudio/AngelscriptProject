// Theme: Feature.Access. NegativeDiagnostic: protected member read from an unrelated class.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 4 AssertFailsToCompile.
// Expected compile failure: "Accessing protected from unrelated class".
// Isolate the failing program. DiagnosticOnly.

class AActorProtUnrel : AActor
{
	protected int ProtVal = 10;
}

class AOtherActor : AActor
{
	void Foo()
	{
		AActorProtUnrel A;
		int X = A.ProtVal;
	}
}
