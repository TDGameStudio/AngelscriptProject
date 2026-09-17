/**
 * @version v1
 * @summary HotReload VersionPair Version_01. Blueprint child runs V1 delegate.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Version_01. Blueprint child runs V1 delegate.
 * @topic Baseline
 */
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
/** @end */
/**
 * @version version-02
 * @parent root
 * @summary HotReload VersionPair Version_02. Soft body update of HandleCompute.
 * @topic HotReload
 */
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
		LastValue = Value * 2;
		return LastValue + 3;
	}

	/** Runs the delegate path and returns the observed result. */
	UFUNCTION()
	int RunDelegate(int Value)
	{
		return OnCompute.Execute(Value);
	}
}
/** @end */
/**
 * @version version-03
 * @parent root
 * @summary HotReload VersionPair Version_03. Property specifier change on OnCompute.
 * @topic HotReload
 */
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
/** @end */
/**
 * @version version-04
 * @parent root
 * @summary HotReload VersionPair Version_04. Delegate signature adds Bonus.
 * @topic HotReload
 */
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
/** @end */
