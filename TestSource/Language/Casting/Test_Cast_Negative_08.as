// Theme: Language.Casting. NegativeDiagnostic: Cast with too many arguments.
// C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
// Expected compile failure: "Cast with too many arguments should fail".
// Isolate the failing program. DiagnosticOnly.

void Test(AActor A, AActor B)
{
	auto X = Cast<APawn>(A, B);
}
