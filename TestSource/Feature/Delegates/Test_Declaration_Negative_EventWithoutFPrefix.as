// Theme: Feature.Delegates. C++ compile-fail is DISABLED (#as-engine-behavior):
// AngelScript does not enforce an F prefix on event type names.
// CSV NegativeDiagnostic is wrong; AssertFailsToCompile is #if 0 so this compiles.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_EventWithoutFPrefix
// sha256=f31575eee44e832bf44c6338a4903e3d955f73287849db6ffedb77dee7b80db6; lines 185-187.
// Extra: default unbound; Broadcast(0) is the zero boundary. Follow C++ method.

event void OnChanged(int X);

bool Observe_OnChanged_DefaultUnbound()
{
	OnChanged Notify;
	return !Notify.IsBound();
}

void Observe_OnChanged_ZeroBroadcastNoOp()
{
	OnChanged Notify;
	Notify.Broadcast(0);
}

bool Observe_OnChanged_TwoLocalsIndependent()
{
	OnChanged First;
	OnChanged Second;
	First.Broadcast(1);
	return !First.IsBound() && !Second.IsBound();
}
