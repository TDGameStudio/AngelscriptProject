// Theme: Containers.TSubclassOf. Isolated compile-fail: TSubclassOf without a template.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSubclassOf_Negative AssertFailsToCompile
// ASSyntaxSPSubclassNoTemplate. Expected diagnostic: "TSubclassOf without template param should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TSubclassOf Class;
}
