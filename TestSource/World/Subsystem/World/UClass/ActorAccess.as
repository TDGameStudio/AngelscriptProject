/**
 * A world subsystem whose Tick reads the persistent level's actor list, plus an
 * empty actor class. C++ compiles the module with a full reload and verifies the
 * routing through TObjectPtr. The observers cover the handle semantics: unset
 * handles are null, and assigning one handle to another aliases them.
 *
 * @Theme World.Subsystem
 * @Subject Subsystem.WorldActorAccess
 * @Harness UClass
 * @Tag World.Subsystem.World.ActorAccess
 * @Provenance Theme: World.Subsystem.World. WorldStory: subsystem Tick reads persistent-level actors.
 * @Provenance C++: AngelscriptSubsystemTests.cpp World-subsystem ActorAccess method.
 * @Provenance CompileModuleWithResult FullReload; oracle is bCompiled after TObjectPtr routing fix.
 * @Provenance PlannedSymbols: UTestWorldActorWatcher, Tick, ATestWorldSubsystemActorAccessActor.
 * @Provenance sha256=1edb23e6ed560d5f3f61c5617c9ad1565670e4587b0af0b85c4eb286bf46d86c; lines 116-131.
 * @Provenance Extra: default handles are null; assigning aliases the same handle.
 * @Provenance FixtureIsolated. Runner owns World/module teardown.
 */

UCLASS()
class UTestWorldActorWatcher : UScriptWorldSubsystem
{
	/**
	 * WorldStory: Tick walks the persistent level's actor list.
	 *
	 * @Kind WorldStory
	 * @Covers Subsystem.WorldActorAccess
	 * @Inputs the frame delta, unused
	 * @Return nothing; the call chain binding is what the test observes
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		GetWorld().GetPersistentLevel().GetActors().Num();
	}

	/**
	 * Observe that unset handles of both types are null.
	 *
	 * @Kind Observe
	 * @Covers Subsystem.WorldActorAccess
	 * @Inputs a freshly declared watcher handle and a freshly declared actor handle
	 * @Return true when both unset handles are null
	 * @Boundary unset handles
	 */
	UFUNCTION()
	bool DefaultHandlesNull()
	{
		UTestWorldActorWatcher Watcher;
		ATestWorldSubsystemActorAccessActor Actor;

		if (Watcher != nullptr)
		{
			return false;
		}
		return Actor == nullptr;
	}

	/**
	 * Observe that assigning one handle to another aliases them for both types.
	 *
	 * @Kind Observe
	 * @Covers Subsystem.WorldActorAccess
	 * @Inputs a second watcher handle and a second actor handle
	 * @Return true when both assignments compare equal to their sources
	 * @Param SecondWatcher the watcher handle to assign from
	 * @Param SecondActor the actor handle to assign from
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool AssignAliases(UTestWorldActorWatcher SecondWatcher, ATestWorldSubsystemActorAccessActor SecondActor)
	{
		UTestWorldActorWatcher FirstWatcher;
		ATestWorldSubsystemActorAccessActor FirstActor;
		FirstWatcher = SecondWatcher;
		FirstActor = SecondActor;

		if (FirstWatcher != SecondWatcher)
		{
			return false;
		}
		return FirstActor == SecondActor;
	}
}

/**
 * The empty actor class that C++ also compiles alongside the subsystem.
 *
 * @Covers Subsystem.WorldActorAccess
 * @Inputs none
 * @Return a declared but empty actor
 */
UCLASS()
class ATestWorldSubsystemActorAccessActor : AActor
{
}
