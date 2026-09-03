// Theme: HotReload VersionPair Version_04. Delegate signature adds Bonus.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::BlueprintDelegatePropertyReloadsAfterInstanceRuntime
// Retained: class, OnCompute EditAnywhere BlueprintReadWrite, LastValue, BeginPlayCount, BeginPlay bind.
// Replaced: FHotReloadRuntimeCompute(int Value, int Bonus); HandleCompute sums; RunDelegate rebinds if unbound and Execute(Value, 7).
// Oracle: RunDelegate(30) -> 42, LastValue 37. FixtureIsolated.

/** Delegate FHotReloadRuntimeCompute: carries (int Value, int Bonus) for this reload scenario. */
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

	/** Blueprint begin-play override: binds the delegate and records the entry. */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
		OnCompute.BindUFunction(this, n"HandleCompute");
	}

	/** Handles the compute callback. */
	UFUNCTION()
	int HandleCompute(int Value, int Bonus)
	{
		LastValue = Value + Bonus;
		return LastValue + 5;
	}

	/** Runs the delegate path and returns the observed result. */
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
