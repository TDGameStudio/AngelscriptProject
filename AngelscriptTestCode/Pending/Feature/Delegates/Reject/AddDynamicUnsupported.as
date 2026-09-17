/**
 * @version v1
 * @summary AddDynamic is a C++ macro name, not a script API, so this program is rejected. Script adds multicast listeners with AddUFunction.
 * @topic Feature
 */
/**
 * @version root
 * @summary AddDynamic is a C++ macro name, not a script API, so this program is rejected. Script adds multicast listeners with AddUFunction.
 * @topic Negative
 */
/**
 * A void multicast used only to name AddDynamic.
 *
 * @Kind CompileReject
 * @Covers Delegates.DynamicMacro
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageDynamicMacroEvent();

UCLASS()
class ACoverageAddDynamicMacroActor : AActor
{
	UPROPERTY()
	FCoverageDynamicMacroEvent Multi;

	/**
	 * A named handler that is not reachable through AddDynamic.
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
	 * The isolated failing program: AddDynamic is not a script API.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.DynamicMacro
	 * @Inputs none
	 * @Return does not compile; AddDynamic has no matching signature
	 */
	UFUNCTION()
	void TryAddDynamic()
	{
		Multi.AddDynamic(this, n"Handler");
	}
}
/** @end */
