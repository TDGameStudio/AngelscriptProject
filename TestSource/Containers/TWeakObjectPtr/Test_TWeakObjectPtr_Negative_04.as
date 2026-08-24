// Theme: Containers.TWeakObjectPtr. Isolated compile-fail: TWeakObjectPtr of a missing type.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TWeakObjectPtr_Negative AssertFailsToCompile
// ASSyntaxSPWeakBadType. Expected diagnostic: "TWeakObjectPtr of non-existent type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TWeakObjectPtr<NonExistentClass> Weak;
}
