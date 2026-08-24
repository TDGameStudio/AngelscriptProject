// Theme: Language.Casting. NegativeDiagnostic: Cast to a struct type.
// C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
// Expected compile failure: "Cast to struct type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test(AActor A)
{
	auto X = Cast<FVector>(A);
}
