// Theme: HotReload VersionPair Version_02. Soft body update of HandleCompute.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::BlueprintDelegatePropertyReloadsAfterInstanceRuntime
// Retained: NotEditable OnCompute, BeginPlay bind, RunDelegate, live Blueprint child, BeginPlayCount.
// Replaced: HandleCompute LastValue = Value * 2; return LastValue + 3.
// Oracle: RunDelegate(10) -> 23, LastValue 20, BeginPlayCount stays 1. FixtureIsolated.

delegate int FHotReloadRuntimeCompute(int Value);

UCLASS()
class AHotReloadDelegateRuntimeBlueprintParent : AActor
{
	UPROPERTY(NotEditable)
	FHotReloadRuntimeCompute OnCompute;

	UPROPERTY()
	int LastValue = 0;

	UPROPERTY()
	int BeginPlayCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
		OnCompute.BindUFunction(this, n"HandleCompute");
	}

	UFUNCTION()
	int HandleCompute(int Value)
	{
		LastValue = Value * 2;
		return LastValue + 3;
	}

	UFUNCTION()
	int RunDelegate(int Value)
	{
		return OnCompute.Execute(Value);
	}
}
