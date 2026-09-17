/**
 * @version v1
 * @summary BindDynamic is a C++ macro name, not a script API, so this program is rejected. Script binds unicast handlers with BindUFunction.
 * @topic Feature
 */
/**
 * @version root
 * @summary BindDynamic is a C++ macro name, not a script API, so this program is rejected. Script binds unicast handlers with BindUFunction.
 * @topic Negative
 */
/**
 * A void unicast used only to name BindDynamic.
 *
 * @Kind CompileReject
 * @Covers Delegates.DynamicMacro
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FCoverageDynamicMacroSingle();

UCLASS()
class ACoverageBindDynamicMacroActor : AActor
{
	UPROPERTY()
	FCoverageDynamicMacroSingle Single;

	/**
	 * A named handler that is not reachable through BindDynamic.
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
	 * The isolated failing program: BindDynamic is not a script API.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.DynamicMacro
	 * @Inputs none
	 * @Return does not compile; BindDynamic has no matching signature
	 */
	UFUNCTION()
	void TryBindDynamic()
	{
		Single.BindDynamic(this, n"Handler");
	}
}
/** @end */
