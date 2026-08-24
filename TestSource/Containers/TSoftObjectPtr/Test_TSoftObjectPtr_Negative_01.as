// Theme: Containers.TSoftObjectPtr. NegativeDiagnostic: TSoftObjectPtr without a template.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSoftObjectPtr_Negative AssertFailsToCompile
// ASSyntaxSPSoftNoTemplate. Expected diagnostic: "TSoftObjectPtr without template should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TSoftObjectPtr Soft;
}
