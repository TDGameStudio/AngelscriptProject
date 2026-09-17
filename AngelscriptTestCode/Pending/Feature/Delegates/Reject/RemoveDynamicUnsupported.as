/**
 * @version v1
 * @summary RemoveDynamic is a C++ macro name, not a script API, so this program is rejected. Script removes multicast listeners with Unbind by object and name.
 * @topic Feature
 */
/**
 * @version root
 * @summary RemoveDynamic is a C++ macro name, not a script API, so this program is rejected. Script removes multicast listeners with Unbind by object and name.
 * @topic Negative
 */
/**
 * A void multicast used only to name RemoveDynamic.
 *
 * @Kind CompileReject
 * @Covers Delegates.DynamicMacro
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageDynamicMacroEvent();

UCLASS()
class ACoverageRemoveDynamicMacroActor : AActor
{
	UPROPERTY()
	FCoverageDynamicMacroEvent Multi;

	/**
	 * A named handler that is not reachable through RemoveDynamic.
	 *
	 * @Covers Delegates.DynamicMacro
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void Handler()
	{
	}

	/**
	 * The isolated failing program: RemoveDynamic is not a script API.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.DynamicMacro
	 * @Inputs none
	 * @Return does not compile; RemoveDynamic has no matching signature
	 */
	UFUNCTION()
	void TryRemoveDynamic()
	{
		Multi.RemoveDynamic(this, n"Handler");
	}
}
/** @end */
