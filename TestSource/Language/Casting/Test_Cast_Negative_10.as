// Theme: Language.Casting. NegativeDiagnostic: Cast result used as an lvalue.
// C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
// Expected compile failure: "Cast result as lvalue should fail".
// Isolate the failing program. DiagnosticOnly.

void Test(AActor A)
{
	Cast<APawn>(A) = nullptr;
}
