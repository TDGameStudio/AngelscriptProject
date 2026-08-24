// Theme: Feature.Delegates. C++ compile-fail is DISABLED (#as-engine-behavior):
// AngelScript does not enforce an F prefix on delegate type names.
// CSV NegativeDiagnostic is wrong; AssertFailsToCompile is #if 0 so this compiles.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_WithoutFPrefix
// sha256=8bc91aec26539952310dc719676276466411124e09227cad2bde6bc3a0f7ac76; lines 146-148.
// Extra: default unbound; two locals independent. CSV DiagnosticOnly is ignored
// in favor of the C++ method.

delegate void OnAction();

bool Observe_OnAction_DefaultUnbound()
{
	OnAction Notify;
	return !Notify.IsBound();
}

bool Observe_OnAction_TwoLocalsIndependent()
{
	OnAction First;
	OnAction Second;
	return !First.IsBound() && !Second.IsBound();
}
