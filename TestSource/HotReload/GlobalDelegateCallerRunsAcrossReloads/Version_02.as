// Theme: HotReload VersionPair Version_02. Soft body update of HandleCompute.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::GlobalDelegateCallerRunsAcrossReloads
// Retained: FHotReloadGlobalCompute(int Value), RunGlobal signature, bind/execute.
// Replaced: HandleCompute Value + 2 -> Value * 3.
// Oracle: RunGlobal(Receiver, 6) -> 18. FixtureIsolated.

delegate int FHotReloadGlobalCompute(int Value);

UCLASS()
class UHotReloadGlobalDelegateReceiver : UObject
{
	UFUNCTION()
	int HandleCompute(int Value)
	{
		return Value * 3;
	}
}

int RunGlobal(UHotReloadGlobalDelegateReceiver Receiver, int Value)
{
	FHotReloadGlobalCompute Compute;
	Compute.BindUFunction(Receiver, n"HandleCompute");
	return Compute.Execute(Value);
}
