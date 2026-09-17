/**
 * @version v1
 * @summary HotReload VersionPair Before. Explicit unbound / missing / mismatch errors.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Explicit unbound / missing / mismatch errors.
 * @topic Baseline
 */
// Retained after reload: TriggerUnboundExecute, TriggerMissingHandler, TriggerSignatureMismatch, WrongSignature.
// Replaced in After: HandleCompute Value + 1 -> Value * 2. Diagnostics stay the same.
// Oracle: "Executing unbound delegate."; missing UFUNCTION name; incompatible signature.
// FixtureIsolated. Isolated failing Execute/Bind, not extra declarations.

/** Delegate FHotReloadNegativeCompute: carries (int Value) for this reload scenario. */
delegate int FHotReloadNegativeCompute(int Value);

UCLASS()
class UHotReloadDelegateRuntimeNegativeReceiver : UObject
{
	/** Handles the compute callback. */
	UFUNCTION()
	int HandleCompute(int Value)
	{
		return Value + 1;
	}

	/** WrongSignature: exercises the wrong signature behaviour. */
	UFUNCTION()
	void WrongSignature()
	{
	}
}

/** Builds and returns the receiver. */
UHotReloadDelegateRuntimeNegativeReceiver MakeReceiver()
{
	return Cast<UHotReloadDelegateRuntimeNegativeReceiver>(
		NewObject(GetTransientPackage(), UHotReloadDelegateRuntimeNegativeReceiver::StaticClass()));
}

/** Triggers the unbound execute path. */
void TriggerUnboundExecute()
{
	FHotReloadNegativeCompute Compute;
	Compute.Execute(5);
}

/** Triggers the missing handler path. */
void TriggerMissingHandler()
{
	UHotReloadDelegateRuntimeNegativeReceiver Receiver = MakeReceiver();
	FHotReloadNegativeCompute Compute;
	Compute.BindUFunction(Receiver, n"MissingHandler");
}

/** Triggers the signature mismatch path. */
void TriggerSignatureMismatch()
{
	UHotReloadDelegateRuntimeNegativeReceiver Receiver = MakeReceiver();
	FHotReloadNegativeCompute Compute;
	Compute.BindUFunction(Receiver, n"WrongSignature");
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Same negative triggers after HandleCompute body change.
 * @topic HotReload
 */
/** Delegate FHotReloadNegativeCompute: carries (int Value) for this reload scenario. */
delegate int FHotReloadNegativeCompute(int Value);

UCLASS()
class UHotReloadDelegateRuntimeNegativeReceiver : UObject
{
	/** Handles the compute callback. */
	UFUNCTION()
	int HandleCompute(int Value)
	{
		return Value * 2;
	}

	/** WrongSignature: exercises the wrong signature behaviour. */
	UFUNCTION()
	void WrongSignature()
	{
	}
}

/** Builds and returns the receiver. */
UHotReloadDelegateRuntimeNegativeReceiver MakeReceiver()
{
	return Cast<UHotReloadDelegateRuntimeNegativeReceiver>(
		NewObject(GetTransientPackage(), UHotReloadDelegateRuntimeNegativeReceiver::StaticClass()));
}

/** Triggers the unbound execute path. */
void TriggerUnboundExecute()
{
	FHotReloadNegativeCompute Compute;
	Compute.Execute(5);
}

/** Triggers the missing handler path. */
void TriggerMissingHandler()
{
	UHotReloadDelegateRuntimeNegativeReceiver Receiver = MakeReceiver();
	FHotReloadNegativeCompute Compute;
	Compute.BindUFunction(Receiver, n"MissingHandler");
}

/** Triggers the signature mismatch path. */
void TriggerSignatureMismatch()
{
	UHotReloadDelegateRuntimeNegativeReceiver Receiver = MakeReceiver();
	FHotReloadNegativeCompute Compute;
	Compute.BindUFunction(Receiver, n"WrongSignature");
}
/** @end */
