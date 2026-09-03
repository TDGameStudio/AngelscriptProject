/**
 * A UScriptGameInstanceSubsystem subclass whose Initialize and Deinitialize
 * overrides must bind. C++ compiles the module with a full reload and verifies the
 * routing through TObjectPtr. The observers cover the handle semantics: an unset
 * handle is null, and assigning one handle to another aliases them.
 *
 * @Theme World.Subsystem
 * @Subject Subsystem.GameInstanceLifecycle
 * @Harness UClass
 * @Tag World.Subsystem.GameInstance.Lifecycle
 * @Provenance Theme: World.Subsystem.GameInstance. WorldStory: UScriptGameInstanceSubsystem subclass compiles.
 * @Provenance C++: AngelscriptSubsystemTests.cpp GameInstance-subsystem Lifecycle method.
 * @Provenance CompileModuleWithResult FullReload; oracle is bCompiled after TObjectPtr routing fix.
 * @Provenance PlannedSymbols: UTestGameInstanceLifecycleTracker, Initialize, Deinitialize.
 * @Provenance sha256=062361a386fc9305341482be98dfa8a753812358ba2ded1831bb2e7d178b28ce; lines 162-176.
 * @Provenance Extra: default handle is null; assigning aliases the same handle.
 * @Provenance FixtureIsolated. Runner owns module teardown.
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
