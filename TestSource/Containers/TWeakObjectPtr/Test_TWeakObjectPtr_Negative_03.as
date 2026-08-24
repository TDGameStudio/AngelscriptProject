// Theme: Containers.TWeakObjectPtr. Isolated compile-fail: TWeakObjectPtr of a primitive.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TWeakObjectPtr_Negative AssertFailsToCompile
// ASSyntaxSPWeakPrimitive. Expected diagnostic: "TWeakObjectPtr of primitive should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TWeakObjectPtr<int> Weak;
}
