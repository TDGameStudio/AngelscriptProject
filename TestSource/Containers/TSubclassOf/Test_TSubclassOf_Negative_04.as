// Theme: Containers.TSubclassOf. Isolated compile-fail: TSubclassOf of a struct.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSubclassOf_Negative AssertFailsToCompile
// ASSyntaxSPSubclassStruct. Expected diagnostic: "TSubclassOf of struct should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TSubclassOf<FVector> Class;
}
