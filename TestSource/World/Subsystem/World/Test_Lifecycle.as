// Theme: World.Subsystem.World. WorldStory: UScriptWorldSubsystem lifecycle subclass compiles.
// C++: AngelscriptSubsystemTests.cpp World-subsystem Lifecycle method.
// CompileModuleWithResult FullReload; oracle is bCompiled after TObjectPtr routing fix.
// PlannedSymbols: UTestWorldLifecycleTracker, Initialize, Deinitialize.
// sha256=57d7beb28334b7f3cd81e6d91f65c4316ba0547f935a5e93368c0c2ea6ba2b97; lines 45-59.
// Extra: default handle is null; assigning aliases the same handle.
// FixtureIsolated. Runner owns module teardown.

UCLASS()
class UTestWorldLifecycleTracker : UScriptWorldSubsystem
{
	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
	}

	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
	}
}

bool Observe_WorldLifecycle_EmptyDefaultIsNull()
{
	UTestWorldLifecycleTracker Unset;
	return Unset == nullptr;
}

bool Observe_WorldLifecycle_AssignAliases()
{
	UTestWorldLifecycleTracker First;
	UTestWorldLifecycleTracker Second;
	First = Second;
	return First == Second;
}
