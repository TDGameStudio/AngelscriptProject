// Theme: Containers.TSet. NegativeDiagnostic: TSet without a template argument.
// C++: AngelscriptSyntaxContainerTests.cpp::TSet_Negative AssertFailsToCompile ASSyntaxCon_SetNoTemplate.
// Expected diagnostic: "TSet without template type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TSet S;
}
