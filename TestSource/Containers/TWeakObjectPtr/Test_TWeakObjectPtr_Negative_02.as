// Theme: Containers.TWeakObjectPtr. Isolated compile-fail: TWeakObjectPtr of a non-UObject.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TWeakObjectPtr_Negative AssertFailsToCompile
// ASSyntaxSPWeakNonUObj. Expected diagnostic: "TWeakObjectPtr of non-UObject type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TWeakObjectPtr<FVector> Weak;
}
