// Theme: Feature.Access. NegativeDiagnostic: private base member written from a derived class.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 5 AssertFailsToCompile.
// Expected compile failure: "Accessing private member from derived class".
// Isolate the failing program. DiagnosticOnly.

class ABaseActorPrivDeriv : AActor
{
	private int Secret = 42;
}

class ADerivedActorPriv : ABaseActorPrivDeriv
{
	void Foo()
	{
		Secret = 10;
	}
}
