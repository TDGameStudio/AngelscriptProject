// Theme: HotReload VersionPair Version_03. Property specifier change on OnCompute.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::BlueprintDelegatePropertyReloadsAfterInstanceRuntime
// Retained: FHotReloadRuntimeCompute arity, LastValue, BeginPlayCount, BeginPlay bind, RunDelegate.
// Replaced: OnCompute NotEditable -> EditAnywhere, BlueprintReadWrite; HandleCompute * 3 + 4.
// Oracle: RunDelegate(8) -> 28, LastValue 24. FixtureIsolated.

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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
		OnCompute.BindUFunction(this, n"HandleCompute");
	}

	UFUNCTION()
	int HandleCompute(int Value)
	{
		LastValue = Value * 3;
		return LastValue + 4;
	}

	UFUNCTION()
	int RunDelegate(int Value)
	{
		return OnCompute.Execute(Value);
	}
}
