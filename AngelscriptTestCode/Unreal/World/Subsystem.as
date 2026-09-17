/**
 * @version v1
 * @summary World and game-instance subsystem lifecycle.
 * @topic Unreal
 * @topic World
 *
 * lifecycle
 * actor-access
 * lifecycle-lifecycle
 * tick
 */
/**
 * @begin lifecycle
 * @summary A UScriptGameInstanceSubsystem subclass whose Initialize and Deinitialize overrides must bind. C++ compiles the module with a full reload and verifies the routing through TObjectPtr. The observers cover the handle.
 * @topic Subsystem
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
/**
 * @begin actor-access
 * @summary A world subsystem whose Tick reads the persistent level's actor list, plus an empty actor class. C++ compiles the module with a full reload and verifies the routing through TObjectPtr. The observers cover the handle.
 * @topic Subsystem
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
/** @end */
/**
 * @begin lifecycle-lifecycle
 * @summary A UScriptWorldSubsystem subclass whose Initialize and Deinitialize overrides must bind. C++ compiles the module with a full reload and verifies the routing through TObjectPtr. The observers cover the handle semantics: an.
 * @topic Subsystem
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
/** @end */
/**
 * @begin tick
 * @summary A UScriptWorldSubsystem subclass whose Tick override must bind. C++ compiles the module with a full reload and verifies the routing through TObjectPtr. The observers cover the handle semantics: an unset handle is null.
 * @topic Subsystem
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
