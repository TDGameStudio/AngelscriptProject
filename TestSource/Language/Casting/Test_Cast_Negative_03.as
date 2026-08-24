// Theme: Language.Casting. NegativeDiagnostic: Cast on a primitive.
// C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
// Expected compile failure: "Cast on primitive type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int X = 5;
	auto Y = Cast<float>(X);
}
