// Theme: HotReload VersionPair Version_03. Delegate and RunGlobal gain Bonus.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::GlobalDelegateCallerRunsAcrossReloads
// Retained: receiver class, BindUFunction HandleCompute, Execute through RunGlobal.
// Replaced: FHotReloadGlobalCompute(int Value, int Bonus); HandleCompute Value + Bonus + 4; RunGlobal arity.
// Oracle: RunGlobal(Receiver, Value, Bonus) -> 32. FixtureIsolated.

delegate int FHotReloadGlobalCompute(int Value, int Bonus);

UCLASS()
class UHotReloadGlobalDelegateReceiver : UObject
{
	UFUNCTION()
	int HandleCompute(int Value, int Bonus)
	{
		return Value + Bonus + 4;
	}
}

int RunGlobal(UHotReloadGlobalDelegateReceiver Receiver, int Value, int Bonus)
{
	FHotReloadGlobalCompute Compute;
	Compute.BindUFunction(Receiver, n"HandleCompute");
	return Compute.Execute(Value, Bonus);
}
