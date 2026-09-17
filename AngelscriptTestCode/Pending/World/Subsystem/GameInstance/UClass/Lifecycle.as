/**
 * @version v1
 * @summary A UScriptGameInstanceSubsystem subclass whose Initialize and Deinitialize overrides must bind. C++ compiles the module with a full reload and verifies the routing through TObjectPtr. The observers cover the handle.
 * @topic World
 */
/**
 * @version root
 * @summary A UScriptGameInstanceSubsystem subclass whose Initialize and Deinitialize overrides must bind. C++ compiles the module with a full reload and verifies the routing through TObjectPtr. The observers cover the handle.
 * @topic Baseline
 */
UCLASS()
class UTestGameInstanceLifecycleTracker : UScriptGameInstanceSubsystem
{
	/**
	 * WorldStory: Initialize binds as the subsystem starts up.
	 *
	 * @Kind WorldStory
	 * @Covers Subsystem.GameInstanceLifecycle
	 * @Inputs none
	 * @Return nothing; binding is what the test observes
	 */
	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
	}

	/**
	 * WorldStory: Deinitialize binds as the subsystem shuts down.
	 *
	 * @Kind WorldStory
	 * @Covers Subsystem.GameInstanceLifecycle
	 * @Inputs none
	 * @Return nothing; binding is what the test observes
	 */
	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
	}

	/**
	 * Observe that an unset handle of this type is null.
	 *
	 * @Kind Observe
	 * @Covers Subsystem.GameInstanceLifecycle
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UTestGameInstanceLifecycleTracker Unset;
		return Unset == nullptr;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Subsystem.GameInstanceLifecycle
	 * @Inputs another handle to assign from
	 * @Return true when the assigned handle compares equal to the source
	 * @Param Second the handle to assign from
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool AssignAliases(UTestGameInstanceLifecycleTracker Second)
	{
		UTestGameInstanceLifecycleTracker First;
		First = Second;
		return First == Second;
	}
}
/** @end */
