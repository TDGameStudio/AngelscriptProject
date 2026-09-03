// Theme: HotReload VersionPair Version_01. Global caller binds HandleCompute.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::GlobalDelegateCallerRunsAcrossReloads
// Retained: FHotReloadGlobalCompute, UHotReloadGlobalDelegateReceiver, RunGlobal bind/execute.
// Replaced later: HandleCompute body, then delegate arity + RunGlobal Bonus.
// Oracle: RunGlobal(Receiver, 5) -> 7. FixtureIsolated.

/** Delegate FHotReloadGlobalCompute: carries (int Value) for this reload scenario. */
delegate int FHotReloadGlobalCompute(int Value);

UCLASS()
class UHotReloadGlobalDelegateReceiver : UObject
{
	/** Handles the compute callback. */
	UFUNCTION()
	int HandleCompute(int Value)
	{
		return Value + 2;
	}
}

/** Runs the global path and returns the observed result. */
int RunGlobal(UHotReloadGlobalDelegateReceiver Receiver, int Value)
{
	FHotReloadGlobalCompute Compute;
	Compute.BindUFunction(Receiver, n"HandleCompute");
	return Compute.Execute(Value);
}
