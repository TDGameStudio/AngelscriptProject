// Theme: Containers.TSoftObjectPtr. NegativeDiagnostic: TSoftObjectPtr of a non-UObject.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSoftObjectPtr_Negative AssertFailsToCompile
// ASSyntaxSPSoftNonUObj. Expected diagnostic: "TSoftObjectPtr of non-UObject should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TSoftObjectPtr<FVector> Soft;
}
