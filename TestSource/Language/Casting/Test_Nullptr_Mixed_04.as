// Theme: Language.Casting. NegativeDiagnostic: assign nullptr to a value type.
// C++: AngelscriptSyntaxCastingTests.cpp::Nullptr_Mixed AssertFailsToCompile
// CSV SourceShape Positive is wrong; C++ is compile-fail.
// Expected compile failure: "Assign nullptr to value type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	FVector V = nullptr;
}
