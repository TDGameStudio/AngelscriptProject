// Theme: Language.Casting. NegativeDiagnostic: Cast between unrelated types.
// C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
// Expected compile failure: "Cast between unrelated types should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	FString S = "hello";
	auto X = Cast<AActor>(S);
}
