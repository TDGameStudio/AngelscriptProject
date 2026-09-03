// Theme: HotReload VersionPair After. Same tick wiring, later ticks use +100.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::BlueprintDelegateWorldTickContinuesAfterSoftReload
// Retained: Tick property/function shape, BeginPlay not replayed, running actor identity.
// Replaced: HandleTickCompute TickIndex + 10 -> TickIndex + 100.
// Oracle: TickCount 4, Total 230, BeginPlayCount stays 1. FixtureIsolated.

/** Delegate FHotReloadTickCompute: carries (int TickIndex) for this reload scenario. */
delegate int FHotReloadTickCompute(int TickIndex);

UCLASS()
class AHotReloadDelegateRuntimeTickParent : AActor
{
	UPROPERTY()
	FHotReloadTickCompute OnTickCompute;

	UPROPERTY()
	int BeginPlayCount = 0;

	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	int Total = 0;

	/** Blueprint begin-play override: binds the delegate and records the entry. */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
		OnTickCompute.BindUFunction(this, n"HandleTickCompute");
	}

	/** Blueprint tick override: runs the per-frame compute and records the delta. */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount += 1;

		if (!OnTickCompute.IsBound())
		{
			OnTickCompute.BindUFunction(this, n"HandleTickCompute");
		}

		Total += OnTickCompute.Execute(TickCount);
	}

	/** Handles the tick compute callback. */
	UFUNCTION()
	int HandleTickCompute(int TickIndex)
	{
		return TickIndex + 100;
	}
}
