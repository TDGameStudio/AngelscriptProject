// Theme: HotReload VersionPair Before. Delegate passed as argument and returned.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::DelegateArgumentAndReturnRoundTripAcrossReloads
// Retained after reload: MakeDelegate, InvokePassed, RunRoundTrip, RunRoundTripGlobal, bind HandleCompute.
// Replaced in After: HandleCompute Value + 4 -> Value * 3.
// Oracle: RunRoundTripGlobal(Value) uses V1 + 4. FixtureIsolated.

delegate int FHotReloadRoundTripCompute(int Value);

UCLASS()
class UHotReloadDelegateRuntimeRoundTripReceiver : UObject
{
	UFUNCTION()
	int HandleCompute(int Value)
	{
		return Value + 4;
	}

	UFUNCTION()
	FHotReloadRoundTripCompute MakeDelegate()
	{
		FHotReloadRoundTripCompute Compute;
		Compute.BindUFunction(this, n"HandleCompute");
		return Compute;
	}

	UFUNCTION()
	int InvokePassed(FHotReloadRoundTripCompute Compute, int Value)
	{
		return Compute.Execute(Value);
	}

	UFUNCTION()
	int RunRoundTrip(int Value)
	{
		FHotReloadRoundTripCompute Compute = MakeDelegate();
		return InvokePassed(Compute, Value);
	}
}

int RunRoundTripGlobal(int Value)
{
	UHotReloadDelegateRuntimeRoundTripReceiver Receiver = Cast<UHotReloadDelegateRuntimeRoundTripReceiver>(
		NewObject(GetTransientPackage(), UHotReloadDelegateRuntimeRoundTripReceiver::StaticClass()));
	return Receiver.RunRoundTrip(Value);
}
