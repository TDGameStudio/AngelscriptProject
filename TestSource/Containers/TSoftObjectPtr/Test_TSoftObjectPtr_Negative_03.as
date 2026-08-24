// Theme: Containers.TSoftObjectPtr. NegativeDiagnostic: TSoftObjectPtr of a primitive.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSoftObjectPtr_Negative AssertFailsToCompile
// ASSyntaxSPSoftPrimitive. Expected diagnostic: "TSoftObjectPtr of primitive should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TSoftObjectPtr<int> Soft;
}
