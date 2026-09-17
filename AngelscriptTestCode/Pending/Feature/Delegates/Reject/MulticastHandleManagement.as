/**
 * @version v1
 * @summary FDelegateHandle add/remove is not an AngelScript multicast API. Script uses AddUFunction and Unbind by object and function name, not C++ handles.
 * @topic Feature
 */
/**
 * @version root
 * @summary FDelegateHandle add/remove is not an AngelScript multicast API. Script uses AddUFunction and Unbind by object and function name, not C++ handles.
 * @topic Negative
 */
/**
 * A void multicast used only to name FDelegateHandle.
 *
 * @Kind CompileReject
 * @Covers Delegates.Binding
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageMulticastHandleSignal();

UCLASS()
class ACoverageMulticastHandleActor : AActor
{
	UPROPERTY()
	FCoverageMulticastHandleSignal OnMulticast;

	FDelegateHandle Handle1;

	/**
	 * A named listener that is not stored through FDelegateHandle.
	 *
	 * @Covers Delegates.Binding
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void Listener1()
	{
	}

	/**
	 * The isolated failing program: AddUFunction does not return FDelegateHandle.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.Binding
	 * @Inputs none
	 * @Return does not compile; FDelegateHandle is not a script multicast API
	 */
	void TryHandleManagement()
	{
		Handle1 = OnMulticast.AddUFunction(this, n"Listener1");
		OnMulticast.Remove(Handle1);
	}
}
/** @end */
