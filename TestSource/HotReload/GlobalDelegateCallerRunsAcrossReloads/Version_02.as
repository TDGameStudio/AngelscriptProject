// Theme: HotReload VersionPair Version_02. Soft body update of HandleCompute.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::GlobalDelegateCallerRunsAcrossReloads
// Retained: FHotReloadGlobalCompute(int Value), RunGlobal signature, bind/execute.
// Replaced: HandleCompute Value + 2 -> Value * 3.
// Oracle: RunGlobal(Receiver, 6) -> 18. FixtureIsolated.

/** Delegate FHotReloadGlobalCompute: carries (int Value) for this reload scenario. */
delegate int FHotReloadGlobalCompute(int Value);

UCLASS()
class UHotReloadGlobalDelegateReceiver : UObject
{
	/** Handles the compute callback. */
	UFUNCTION()
	int HandleCompute(int Value)
	{
		return Value * 3;
	}
}

/** Runs the global path and returns the observed result. */
int RunGlobal(UHotReloadGlobalDelegateReceiver Receiver, int Value)
{
	FHotReloadGlobalCompute Compute;
	Compute.BindUFunction(Receiver, n"HandleCompute");
	return Compute.Execute(Value);
}
