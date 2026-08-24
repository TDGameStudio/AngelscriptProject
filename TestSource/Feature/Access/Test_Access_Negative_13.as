// Theme: Feature.Access. NegativeDiagnostic: private member read from a sibling class.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 13 AssertFailsToCompile.
// Expected compile failure: "Accessing private from sibling class".
// Isolate the failing program. DiagnosticOnly.

class ABase : AActor
{
}

class ASiblingA : ABase
{
	private int X = 1;
}

class ASiblingB : ABase
{
	void Foo()
	{
		ASiblingA A;
		int Y = A.X;
	}
}
