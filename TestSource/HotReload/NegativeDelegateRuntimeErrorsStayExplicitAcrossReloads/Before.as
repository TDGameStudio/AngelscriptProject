// Theme: HotReload VersionPair Before. Explicit unbound / missing / mismatch errors.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::NegativeDelegateRuntimeErrorsStayExplicitAcrossReloads
// Retained after reload: TriggerUnboundExecute, TriggerMissingHandler, TriggerSignatureMismatch, WrongSignature.
// Replaced in After: HandleCompute Value + 1 -> Value * 2. Diagnostics stay the same.
// Oracle: "Executing unbound delegate."; missing UFUNCTION name; incompatible signature.
// FixtureIsolated. Isolated failing Execute/Bind, not extra declarations.

delegate int FHotReloadNegativeCompute(int Value);

UCLASS()
class UHotReloadDelegateRuntimeNegativeReceiver : UObject
{
	UFUNCTION()
	int HandleCompute(int Value)
	{
		return Value + 1;
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
