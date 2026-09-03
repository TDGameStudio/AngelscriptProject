// Theme: HotReload VersionPair Version_03. Delegate and RunGlobal gain Bonus.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::GlobalDelegateCallerRunsAcrossReloads
// Retained: receiver class, BindUFunction HandleCompute, Execute through RunGlobal.
// Replaced: FHotReloadGlobalCompute(int Value, int Bonus); HandleCompute Value + Bonus + 4; RunGlobal arity.
// Oracle: RunGlobal(Receiver, Value, Bonus) -> 32. FixtureIsolated.

/** Delegate FHotReloadGlobalCompute: carries (int Value, int Bonus) for this reload scenario. */
delegate int FHotReloadGlobalCompute(int Value, int Bonus);

UCLASS()
class UHotReloadGlobalDelegateReceiver : UObject
{
	/** Handles the compute callback. */
	UFUNCTION()
	int HandleCompute(int Value, int Bonus)
	{
		return Value + Bonus + 4;
	}
}

/** Runs the global path and returns the observed result. */
int RunGlobal(UHotReloadGlobalDelegateReceiver Receiver, int Value, int Bonus)
{
	FHotReloadGlobalCompute Compute;
	Compute.BindUFunction(Receiver, n"HandleCompute");
	return Compute.Execute(Value, Bonus);
}
