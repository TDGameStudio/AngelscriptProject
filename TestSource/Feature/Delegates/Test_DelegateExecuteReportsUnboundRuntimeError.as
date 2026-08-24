// Theme: Feature.Delegates. C++ compiles, then Execute() on an unbound delegate
// raises a script exception.
// C++: AngelscriptCompilerDelegateRuntimeTests.cpp::DelegateExecuteReportsUnboundRuntimeError
// CSV NegativeDiagnostic is wrong: bCompileSucceeded is true, then ExecuteEntryAndCaptureException.
// Runtime diagnostic: Executing unbound delegate.
// Isolation=none. Entry is the C++ execution oracle.

delegate int FRuntimeValueDelegate();

int Entry()
{
	FRuntimeValueDelegate Delegate;
	return Delegate.Execute();
}
