/**
 * A UScriptWorldSubsystem subclass whose Tick override must bind. C++ compiles the
 * module with a full reload and verifies the routing through TObjectPtr. The
 * observers cover the handle semantics: an unset handle is null, and assigning one
 * handle to another aliases them.
 *
 * @Theme World.Subsystem
 * @Subject Subsystem.WorldTicker
 * @Harness UClass
 * @Tag World.Subsystem.World.Tick
 * @Provenance Theme: World.Subsystem.World. WorldStory: UScriptWorldSubsystem Tick override compiles.
 * @Provenance C++: AngelscriptSubsystemTests.cpp World-subsystem Tick method.
 * @Provenance CompileModuleWithResult FullReload; oracle is bCompiled after TObjectPtr routing fix.
 * @Provenance PlannedSymbols: UTestWorldTicker, Tick.
 * @Provenance sha256=210c076926057286e4fcacd504f8415c39e60727fe043a30d26646aaebe24ab9; lines 83-92.
 * @Provenance Extra: default handle is null; assigning aliases the same handle.
 * @Provenance FixtureIsolated. Runner owns module teardown.
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
