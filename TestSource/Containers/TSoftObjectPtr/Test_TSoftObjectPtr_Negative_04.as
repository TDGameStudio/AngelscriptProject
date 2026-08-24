// Theme: Containers.TSoftObjectPtr. NegativeDiagnostic: TSoftObjectPtr of a missing class.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSoftObjectPtr_Negative AssertFailsToCompile
// ASSyntaxSPSoftBadType. Expected diagnostic: "TSoftObjectPtr of non-existent type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TSoftObjectPtr<NonExistentClass> Soft;
}
