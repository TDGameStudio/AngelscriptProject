// Theme: World.Subsystem.World. WorldStory: subsystem Tick reads persistent-level actors.
// C++: AngelscriptSubsystemTests.cpp World-subsystem ActorAccess method.
// CompileModuleWithResult FullReload; oracle is bCompiled after TObjectPtr routing fix.
// PlannedSymbols: UTestWorldActorWatcher, Tick, ATestWorldSubsystemActorAccessActor.
// sha256=1edb23e6ed560d5f3f61c5617c9ad1565670e4587b0af0b85c4eb286bf46d86c; lines 116-131.
// Extra: default handles are null; assigning aliases the same handle.
// FixtureIsolated. Runner owns World/module teardown.

UCLASS()
class UTestWorldActorWatcher : UScriptWorldSubsystem
{
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		GetWorld().GetPersistentLevel().GetActors().Num();
	}
}

UCLASS()
class ATestWorldSubsystemActorAccessActor : AActor
{
}

bool Observe_WorldActorAccess_DefaultHandlesNull()
{
	UTestWorldActorWatcher Watcher;
	ATestWorldSubsystemActorAccessActor Actor;
	return Watcher == nullptr && Actor == nullptr;
}

bool Observe_WorldActorAccess_AssignAliases()
{
	UTestWorldActorWatcher FirstWatcher;
	UTestWorldActorWatcher SecondWatcher;
	ATestWorldSubsystemActorAccessActor FirstActor;
	ATestWorldSubsystemActorAccessActor SecondActor;
	FirstWatcher = SecondWatcher;
	FirstActor = SecondActor;
	return FirstWatcher == SecondWatcher && FirstActor == SecondActor;
}
