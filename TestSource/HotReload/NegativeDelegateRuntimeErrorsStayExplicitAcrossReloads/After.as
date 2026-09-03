// Theme: HotReload VersionPair After. Same negative triggers after HandleCompute body change.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::NegativeDelegateRuntimeErrorsStayExplicitAcrossReloads
// Retained: unbound Execute, missing handler name, WrongSignature mismatch, MakeReceiver.
// Replaced: HandleCompute Value + 1 -> Value * 2. Expected diagnostics unchanged.
// Oracle: "Executing unbound delegate."; "Could not find function in object with this name."; incompatible signature.
// FixtureIsolated. Pair with Before.as.

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
