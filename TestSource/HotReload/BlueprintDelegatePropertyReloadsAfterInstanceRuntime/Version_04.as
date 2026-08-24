// Theme: HotReload VersionPair Version_04. Delegate signature adds Bonus.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::BlueprintDelegatePropertyReloadsAfterInstanceRuntime
// Retained: class, OnCompute EditAnywhere BlueprintReadWrite, LastValue, BeginPlayCount, BeginPlay bind.
// Replaced: FHotReloadRuntimeCompute(int Value, int Bonus); HandleCompute sums; RunDelegate rebinds if unbound and Execute(Value, 7).
// Oracle: RunDelegate(30) -> 42, LastValue 37. FixtureIsolated.

delegate int FHotReloadRuntimeCompute(int Value, int Bonus);

UCLASS()
class AHotReloadDelegateRuntimeBlueprintParent : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
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
	int HandleCompute(int Value, int Bonus)
	{
		LastValue = Value + Bonus;
		return LastValue + 5;
	}

	UFUNCTION()
	int RunDelegate(int Value)
	{
		if (!OnCompute.IsBound())
		{
			OnCompute.BindUFunction(this, n"HandleCompute");
		}

		return OnCompute.Execute(Value, 7);
	}
}
