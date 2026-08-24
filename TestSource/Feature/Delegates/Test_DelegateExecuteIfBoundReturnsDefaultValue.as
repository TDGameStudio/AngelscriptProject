// Theme: Feature.Delegates. Positive unbound ExecuteIfBound returns default values.
// C++: AngelscriptCompilerDelegateRuntimeTests.cpp::DelegateExecuteIfBoundReturnsDefaultValue
// Oracle: Entry()==0, EntryBool()==0. Extra: two unbound int delegates stay 0 independently.
// DefaultSafe.

delegate int FRuntimeValueDelegate();
delegate bool FRuntimeBoolDelegate();

int Entry()
{
	FRuntimeValueDelegate Delegate;
	return Delegate.ExecuteIfBound();
}

int EntryBool()
{
	FRuntimeBoolDelegate Delegate;
	return Delegate.ExecuteIfBound() ? 1 : 0;
}

int Observe_UnboundIntDefault()
{
	return Entry();
}

int Observe_UnboundBoolDefault()
{
	return EntryBool();
}

int Observe_UnboundIntCopyIndependence()
{
	FRuntimeValueDelegate First;
	FRuntimeValueDelegate Second;
	return First.ExecuteIfBound() + Second.ExecuteIfBound();
}
