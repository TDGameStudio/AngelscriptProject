// Theme: HotReload VersionPair After. Same round-trip with multiplied handler.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::DelegateArgumentAndReturnRoundTripAcrossReloads
// Retained: MakeDelegate, InvokePassed, RunRoundTrip, RunRoundTripGlobal, receiver construction.
// Replaced: HandleCompute Value + 4 -> Value * 3.
// Oracle: RunRoundTripGlobal uses V2 * 3. FixtureIsolated.

delegate int FHotReloadRoundTripCompute(int Value);

UCLASS()
class UHotReloadDelegateRuntimeRoundTripReceiver : UObject
{
	UFUNCTION()
	int HandleCompute(int Value)
	{
		return Value * 3;
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
