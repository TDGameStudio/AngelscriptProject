/**
 * Execute on an unbound unicast compiles, then raises a script exception at
 * runtime. Entry is the C++ execution oracle.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateExecuteReportsUnboundRuntimeError
 * @Harness Function
 * @Tag Feature.Delegates.DelegateExecuteReportsUnboundRuntimeError
 * @Namespace DelegatesTest
 * @Provenance Theme: Feature.Delegates. C++ compiles, then Execute() on an unbound delegate
 * @Provenance raises a script exception.
 * @Provenance C++: AngelscriptCompilerDelegateRuntimeTests.cpp::DelegateExecuteReportsUnboundRuntimeError
 * @Provenance CSV NegativeDiagnostic is wrong: bCompileSucceeded is true, then ExecuteEntryAndCaptureException.
 * @Provenance Runtime diagnostic: Executing unbound delegate.
 * @Provenance Isolation=none. Entry is the C++ execution oracle.
 */

/**
 * A unicast that returns int.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return the bound handler's int
 */
delegate int FRuntimeValueDelegate();

namespace DelegatesTest
{
	/**
	 * The C++ execution oracle: Execute on an unbound delegate.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an unbound FRuntimeValueDelegate
	 * @Return does not return; executing an unbound delegate raises
	 * @Boundary unbound execute
	 */
	UFUNCTION()
	int Entry()
	{
		FRuntimeValueDelegate Delegate;
		return Delegate.Execute();
	}
}
