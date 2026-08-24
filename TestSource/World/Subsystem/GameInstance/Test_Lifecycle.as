// Theme: World.Subsystem.GameInstance. WorldStory: UScriptGameInstanceSubsystem subclass compiles.
// C++: AngelscriptSubsystemTests.cpp GameInstance-subsystem Lifecycle method.
// CompileModuleWithResult FullReload; oracle is bCompiled after TObjectPtr routing fix.
// PlannedSymbols: UTestGameInstanceLifecycleTracker, Initialize, Deinitialize.
// sha256=062361a386fc9305341482be98dfa8a753812358ba2ded1831bb2e7d178b28ce; lines 162-176.
// Extra: default handle is null; assigning aliases the same handle.
// FixtureIsolated. Runner owns module teardown.

UCLASS()
class UTestGameInstanceLifecycleTracker : UScriptGameInstanceSubsystem
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

bool Observe_GameInstanceLifecycle_EmptyDefaultIsNull()
{
	UTestGameInstanceLifecycleTracker Unset;
	return Unset == nullptr;
}

bool Observe_GameInstanceLifecycle_AssignAliases()
{
	UTestGameInstanceLifecycleTracker First;
	UTestGameInstanceLifecycleTracker Second;
	First = Second;
	return First == Second;
}
