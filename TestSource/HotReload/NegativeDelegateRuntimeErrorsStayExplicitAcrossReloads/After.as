// Theme: HotReload VersionPair After. Same negative triggers after HandleCompute body change.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::NegativeDelegateRuntimeErrorsStayExplicitAcrossReloads
// Retained: unbound Execute, missing handler name, WrongSignature mismatch, MakeReceiver.
// Replaced: HandleCompute Value + 1 -> Value * 2. Expected diagnostics unchanged.
// Oracle: "Executing unbound delegate."; "Could not find function in object with this name."; incompatible signature.
// FixtureIsolated. Pair with Before.as.

delegate int FHotReloadNegativeCompute(int Value);

UCLASS()
class UHotReloadDelegateRuntimeNegativeReceiver : UObject
{
	UFUNCTION()
	int HandleCompute(int Value)
	{
		return Value * 2;
	}

	UFUNCTION()
	void WrongSignature()
	{
	}
}

UHotReloadDelegateRuntimeNegativeReceiver MakeReceiver()
{
	return Cast<UHotReloadDelegateRuntimeNegativeReceiver>(
		NewObject(GetTransientPackage(), UHotReloadDelegateRuntimeNegativeReceiver::StaticClass()));
}

void TriggerUnboundExecute()
{
	FHotReloadNegativeCompute Compute;
	Compute.Execute(5);
}

void TriggerMissingHandler()
{
	UHotReloadDelegateRuntimeNegativeReceiver Receiver = MakeReceiver();
	FHotReloadNegativeCompute Compute;
	Compute.BindUFunction(Receiver, n"MissingHandler");
}

void TriggerSignatureMismatch()
{
	UHotReloadDelegateRuntimeNegativeReceiver Receiver = MakeReceiver();
	FHotReloadNegativeCompute Compute;
	Compute.BindUFunction(Receiver, n"WrongSignature");
}
