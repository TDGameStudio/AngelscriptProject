/**
 * @version v1
 * @summary A UScriptWorldSubsystem subclass whose Tick override must bind. C++ compiles the module with a full reload and verifies the routing through TObjectPtr. The observers cover the handle semantics: an unset handle is null.
 * @topic World
 */
/**
 * @version root
 * @summary A UScriptWorldSubsystem subclass whose Tick override must bind. C++ compiles the module with a full reload and verifies the routing through TObjectPtr. The observers cover the handle semantics: an unset handle is null.
 * @topic Baseline
 */
UCLASS()
class UTestWorldTicker : UScriptWorldSubsystem
{
	/**
	 * WorldStory: Tick binds as the subsystem is ticked.
	 *
	 * @Kind WorldStory
	 * @Covers Subsystem.WorldTicker
	 * @Inputs the frame delta, unused
	 * @Return nothing; binding is what the test observes
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
	}

	/**
	 * Observe that an unset handle of this type is null.
	 *
	 * @Kind Observe
	 * @Covers Subsystem.WorldTicker
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UTestWorldTicker Unset;
		return Unset == nullptr;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Subsystem.WorldTicker
	 * @Inputs another handle to assign from
	 * @Return true when the assigned handle compares equal to the source
	 * @Param Second the handle to assign from
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool AssignAliases(UTestWorldTicker Second)
	{
		UTestWorldTicker First;
		First = Second;
		return First == Second;
	}
}
/** @end */
