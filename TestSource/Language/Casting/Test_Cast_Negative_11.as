// Theme: Language.Casting. NegativeDiagnostic: Cast to an enum type.
// C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
// Expected compile failure: "Cast to enum type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test(AActor A)
{
	auto X = Cast<ENetRole>(A);
}
