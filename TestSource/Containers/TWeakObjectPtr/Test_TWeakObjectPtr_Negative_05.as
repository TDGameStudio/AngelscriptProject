// Theme: Containers.TWeakObjectPtr. Isolated compile-fail: nested TWeakObjectPtr container.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TWeakObjectPtr_Negative AssertFailsToCompile
// ASSyntaxSPWeakNested. Expected diagnostic: "Nested TWeakObjectPtr should fail".
// Isolate the failing nested-container program. Do not add extra declarations. DiagnosticOnly.

void Test()
{
	TWeakObjectPtr<TWeakObjectPtr<AActor>> Weak;
}
