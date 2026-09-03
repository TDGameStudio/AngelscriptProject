// Theme: HotReload VersionPair Before. World tick drives OnTickCompute.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::BlueprintDelegateWorldTickContinuesAfterSoftReload
// Retained after reload: OnTickCompute, BeginPlayCount, TickCount, Total, live Blueprint actor.
// Replaced in After: HandleTickCompute TickIndex + 10 -> TickIndex + 100.
// Oracle: BeginPlayCount 1, TickCount 2, Total 23. Extra: unbound Tick rebinds. FixtureIsolated.

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
		return TickIndex + 10;
	}
}
