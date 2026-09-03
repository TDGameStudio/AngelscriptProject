// Theme: HotReload VersionPair Version_03. Property specifier change on OnCompute.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::BlueprintDelegatePropertyReloadsAfterInstanceRuntime
// Retained: FHotReloadRuntimeCompute arity, LastValue, BeginPlayCount, BeginPlay bind, RunDelegate.
// Replaced: OnCompute NotEditable -> EditAnywhere, BlueprintReadWrite; HandleCompute * 3 + 4.
// Oracle: RunDelegate(8) -> 28, LastValue 24. FixtureIsolated.

/** Delegate FHotReloadRuntimeCompute: carries (int Value) for this reload scenario. */
delegate int FHotReloadRuntimeCompute(int Value);

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
	int HandleCompute(int Value)
	{
		LastValue = Value * 3;
		return LastValue + 4;
	}

	/** Runs the delegate path and returns the observed result. */
	UFUNCTION()
	int RunDelegate(int Value)
	{
		return OnCompute.Execute(Value);
	}
}
