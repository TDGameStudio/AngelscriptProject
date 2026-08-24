// Theme: Containers.TSubclassOf. Isolated compile-fail: nested TSubclassOf container.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSubclassOf_Negative AssertFailsToCompile
// ASSyntaxSPSubclassNested. Expected diagnostic: "Nested TSubclassOf should fail".
// Isolate the failing nested-container program. Do not add extra declarations. DiagnosticOnly.

void Test()
{
	TSubclassOf<TSubclassOf<AActor>> Class;
}
