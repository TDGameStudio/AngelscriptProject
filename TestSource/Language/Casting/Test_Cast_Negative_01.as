// Theme: Language.Casting. NegativeDiagnostic: Cast to a non-existent class.
// C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
// Expected compile failure: "Cast to non-existent type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test(AActor A)
{
	auto X = Cast<NonExistentClass>(A);
}
