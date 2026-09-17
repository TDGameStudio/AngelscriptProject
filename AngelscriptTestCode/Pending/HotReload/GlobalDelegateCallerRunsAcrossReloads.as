/**
 * @version v1
 * @summary HotReload VersionPair Version_01. Global caller binds HandleCompute.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Version_01. Global caller binds HandleCompute.
 * @topic Baseline
 */
/** Delegate FHotReloadGlobalCompute: carries (int Value) for this reload scenario. */
delegate int FHotReloadGlobalCompute(int Value);

UCLASS()
class UHotReloadGlobalDelegateReceiver : UObject
{
	/** Handles the compute callback. */
	UFUNCTION()
	int HandleCompute(int Value)
	{
		return Value + 2;
	}
}

/** Runs the global path and returns the observed result. */
int RunGlobal(UHotReloadGlobalDelegateReceiver Receiver, int Value)
{
	FHotReloadGlobalCompute Compute;
	Compute.BindUFunction(Receiver, n"HandleCompute");
	return Compute.Execute(Value);
}
/** @end */
/**
 * @version version-02
 * @parent root
 * @summary HotReload VersionPair Version_02. Soft body update of HandleCompute.
 * @topic HotReload
 */
/** Delegate FHotReloadGlobalCompute: carries (int Value) for this reload scenario. */
delegate int FHotReloadGlobalCompute(int Value);

UCLASS()
class UHotReloadGlobalDelegateReceiver : UObject
{
	/** Handles the compute callback. */
	UFUNCTION()
	int HandleCompute(int Value)
	{
		return Value * 3;
	}
}

/** Runs the global path and returns the observed result. */
int RunGlobal(UHotReloadGlobalDelegateReceiver Receiver, int Value)
{
	FHotReloadGlobalCompute Compute;
	Compute.BindUFunction(Receiver, n"HandleCompute");
	return Compute.Execute(Value);
}
/** @end */
/**
 * @version version-03
 * @parent root
 * @summary HotReload VersionPair Version_03. Delegate and RunGlobal gain Bonus.
 * @topic HotReload
 */
/** Delegate FHotReloadGlobalCompute: carries (int Value, int Bonus) for this reload scenario. */
delegate int FHotReloadGlobalCompute(int Value, int Bonus);

UCLASS()
class UHotReloadGlobalDelegateReceiver : UObject
{
	/** Handles the compute callback. */
	UFUNCTION()
	int HandleCompute(int Value, int Bonus)
	{
		return Value + Bonus + 4;
	}
}

/** Runs the global path and returns the observed result. */
int RunGlobal(UHotReloadGlobalDelegateReceiver Receiver, int Value, int Bonus)
{
	FHotReloadGlobalCompute Compute;
	Compute.BindUFunction(Receiver, n"HandleCompute");
	return Compute.Execute(Value, Bonus);
}
/** @end */
