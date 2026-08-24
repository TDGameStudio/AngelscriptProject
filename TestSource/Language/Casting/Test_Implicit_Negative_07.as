// Theme: Language.Casting. NegativeDiagnostic: implicit TArray to element.
// C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Negative AssertFailsToCompile
// Expected compile failure: "Implicit array to element should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TArray<int> Arr;
	int X = Arr;
}
