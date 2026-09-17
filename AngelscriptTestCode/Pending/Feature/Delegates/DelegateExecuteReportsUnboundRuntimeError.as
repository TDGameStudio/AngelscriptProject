/**
 * @version v1
 * @summary Execute on an unbound unicast compiles, then raises a script exception at runtime. Entry is the C++ execution oracle.
 * @topic Feature
 */
/**
 * @version root
 * @summary Execute on an unbound unicast compiles, then raises a script exception at runtime. Entry is the C++ execution oracle.
 * @topic Baseline
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
/** @end */
