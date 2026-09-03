// Theme: HotReload VersionPair Version_01. Blueprint child runs V1 delegate.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::BlueprintDelegatePropertyReloadsAfterInstanceRuntime
// Retained across later versions: FHotReloadRuntimeCompute, OnCompute, LastValue, BeginPlayCount, BeginPlay bind, RunDelegate.
// Replaced later: HandleCompute body, then property specifiers, then delegate arity.
// Oracle: RunDelegate(40) -> 41, LastValue 40, BeginPlayCount 1. FixtureIsolated.

/** Delegate FHotReloadRuntimeCompute: carries (int Value) for this reload scenario. */
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
		LastValue = Value;
		return Value + 1;
	}

	/** Runs the delegate path and returns the observed result. */
	UFUNCTION()
	int RunDelegate(int Value)
	{
		return OnCompute.Execute(Value);
	}
}
