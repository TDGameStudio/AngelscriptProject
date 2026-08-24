// Theme: Language.Casting. NegativeDiagnostic: Cast with multiple template arguments.
// C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
// Expected compile failure: "Cast with multiple template arguments should fail".
// Isolate the failing program. DiagnosticOnly.

void Test(AActor A)
{
	auto X = Cast<APawn, AActor>(A);
}
