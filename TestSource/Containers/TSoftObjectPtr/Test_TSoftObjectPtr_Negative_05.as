// Theme: Containers.TSoftObjectPtr. NegativeDiagnostic: nested TSoftObjectPtr container.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSoftObjectPtr_Negative AssertFailsToCompile
// ASSyntaxSPSoftNested. Expected diagnostic: "Nested TSoftObjectPtr should fail".
// Isolate the failing nested-container program. Do not add extra declarations. DiagnosticOnly.

void Test()
{
	TSoftObjectPtr<TSoftObjectPtr<UStaticMesh>> Soft;
}
