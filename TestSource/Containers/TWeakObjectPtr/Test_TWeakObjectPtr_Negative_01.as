// Theme: Containers.TWeakObjectPtr. Isolated compile-fail: TWeakObjectPtr without a template.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TWeakObjectPtr_Negative AssertFailsToCompile
// ASSyntaxSPWeakNoTemplate. Expected diagnostic: "TWeakObjectPtr without template should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TWeakObjectPtr Weak;
}
