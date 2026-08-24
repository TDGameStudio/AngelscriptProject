// Theme: World.Subsystem.World. WorldStory: UScriptWorldSubsystem Tick override compiles.
// C++: AngelscriptSubsystemTests.cpp World-subsystem Tick method.
// CompileModuleWithResult FullReload; oracle is bCompiled after TObjectPtr routing fix.
// PlannedSymbols: UTestWorldTicker, Tick.
// sha256=210c076926057286e4fcacd504f8415c39e60727fe043a30d26646aaebe24ab9; lines 83-92.
// Extra: default handle is null; assigning aliases the same handle.
// FixtureIsolated. Runner owns module teardown.

UCLASS()
class UTestWorldTicker : UScriptWorldSubsystem
{
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
	}
}

bool Observe_WorldTicker_EmptyDefaultIsNull()
{
	UTestWorldTicker Unset;
	return Unset == nullptr;
}

bool Observe_WorldTicker_AssignAliases()
{
	UTestWorldTicker First;
	UTestWorldTicker Second;
	First = Second;
	return First == Second;
}
