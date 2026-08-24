// Theme: Feature.Delegates. Isolated compile-fail: UPROPERTY of an undeclared delegate.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Binding_Negative_UndeclaredDelegateType
// sha256 from theme-refs TS-FEAT-0349; lines 454-460.
// Expected diagnostic: "Using undeclared delegate type should fail".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

class ADelUndeclaredActor : AActor
{
	UPROPERTY()
	FNonExistentDelegate OnAction;
}
