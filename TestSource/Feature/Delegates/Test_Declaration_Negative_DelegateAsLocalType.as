// Theme: Feature.Delegates. Isolated compile-fail: delegate as a local type in Foo.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_DelegateAsLocalType
// sha256=576c1ed8a947d254351268f61dfa14b353888aba5dead919480bfae2e5401404; lines 250-258.
// Expected diagnostic: "Delegate as local type inside function should fail".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

class ADelLocalActor : AActor
{
	void Foo()
	{
		delegate void FOnActionLocal();
	}
}
