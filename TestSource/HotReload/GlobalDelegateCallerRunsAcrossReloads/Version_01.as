// Theme: HotReload VersionPair Version_01. Global caller binds HandleCompute.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::GlobalDelegateCallerRunsAcrossReloads
// Retained: FHotReloadGlobalCompute, UHotReloadGlobalDelegateReceiver, RunGlobal bind/execute.
// Replaced later: HandleCompute body, then delegate arity + RunGlobal Bonus.
// Oracle: RunGlobal(Receiver, 5) -> 7. FixtureIsolated.

delegate int FHotReloadGlobalCompute(int Value);

UCLASS()
class UHotReloadGlobalDelegateReceiver : UObject
{
	UFUNCTION()
	int HandleCompute(int Value)
	{
		return Value + 2;
	}
}

int RunGlobal(UHotReloadGlobalDelegateReceiver Receiver, int Value)
{
	FHotReloadGlobalCompute Compute;
	Compute.BindUFunction(Receiver, n"HandleCompute");
	return Compute.Execute(Value);
}
