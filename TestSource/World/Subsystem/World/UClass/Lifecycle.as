/**
 * A UScriptWorldSubsystem subclass whose Initialize and Deinitialize overrides must
 * bind. C++ compiles the module with a full reload and verifies the routing through
 * TObjectPtr. The observers cover the handle semantics: an unset handle is null, and
 * assigning one handle to another aliases them.
 *
 * @Theme World.Subsystem
 * @Subject Subsystem.WorldLifecycle
 * @Harness UClass
 * @Tag World.Subsystem.World.Lifecycle
 * @Provenance Theme: World.Subsystem.World. WorldStory: UScriptWorldSubsystem lifecycle subclass compiles.
 * @Provenance C++: AngelscriptSubsystemTests.cpp World-subsystem Lifecycle method.
 * @Provenance CompileModuleWithResult FullReload; oracle is bCompiled after TObjectPtr routing fix.
 * @Provenance PlannedSymbols: UTestWorldLifecycleTracker, Initialize, Deinitialize.
 * @Provenance sha256=57d7beb28334b7f3cd81e6d91f65c4316ba0547f935a5e93368c0c2ea6ba2b97; lines 45-59.
 * @Provenance Extra: default handle is null; assigning aliases the same handle.
 * @Provenance FixtureIsolated. Runner owns module teardown.
 */

UCLASS()
class UTestWorldLifecycleTracker : UScriptWorldSubsystem
{
	/**
	 * WorldStory: Initialize binds as the subsystem starts up.
	 *
	 * @Kind WorldStory
	 * @Covers Subsystem.WorldLifecycle
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
	 * @Covers Subsystem.WorldLifecycle
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
	 * @Covers Subsystem.WorldLifecycle
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UTestWorldLifecycleTracker Unset;
		return Unset == nullptr;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Subsystem.WorldLifecycle
	 * @Inputs another handle to assign from
	 * @Return true when the assigned handle compares equal to the source
	 * @Param Second the handle to assign from
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool AssignAliases(UTestWorldLifecycleTracker Second)
	{
		UTestWorldLifecycleTracker First;
		First = Second;
		return First == Second;
	}
}
