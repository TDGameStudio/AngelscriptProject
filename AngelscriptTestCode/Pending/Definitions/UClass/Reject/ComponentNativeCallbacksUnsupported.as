/**
 * @version v1
 * @summary Native-only component BlueprintOverride callbacks are rejected. OnComponentCreated, InitializeComponent, and OnComponentDestroyed do not exist in the script-visible superclass.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Native-only component BlueprintOverride callbacks are rejected. OnComponentCreated, InitializeComponent, and OnComponentDestroyed do not exist in the script-visible superclass.
 * @topic Negative
 */
UCLASS()
class ULifecycleComponentNativeCallbacksUnsupported : UActorComponent
{
	/**
	 * Illegal BlueprintOverride of OnComponentCreated.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Inputs OnComponentCreated override on UActorComponent
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void OnComponentCreated()
	{
	}

	/**
	 * Illegal BlueprintOverride of InitializeComponent.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Inputs InitializeComponent override on UActorComponent
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void InitializeComponent()
	{
	}

	/**
	 * Illegal BlueprintOverride of OnComponentDestroyed.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Param bDestroyingHierarchy Native destroy flag
	 * @Inputs OnComponentDestroyed override on UActorComponent
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void OnComponentDestroyed(bool bDestroyingHierarchy)
	{
	}
}
/** @end */
