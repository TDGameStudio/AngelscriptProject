// Theme: HotReload VersionPair After. Same round-trip with multiplied handler.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::DelegateArgumentAndReturnRoundTripAcrossReloads
// Retained: MakeDelegate, InvokePassed, RunRoundTrip, RunRoundTripGlobal, receiver construction.
// Replaced: HandleCompute Value + 4 -> Value * 3.
// Oracle: RunRoundTripGlobal uses V2 * 3. FixtureIsolated.

/** Delegate FHotReloadRoundTripCompute: carries (int Value) for this reload scenario. */
delegate int FHotReloadRoundTripCompute(int Value);

UCLASS()
class UHotReloadDelegateRuntimeRoundTripReceiver : UObject
{
	/** Handles the compute callback. */
	UFUNCTION()
	int HandleCompute(int Value)
	{
		return Value * 3;
	}

	/** Builds and returns the delegate. */
	UFUNCTION()
	FHotReloadRoundTripCompute MakeDelegate()
	{
		FHotReloadRoundTripCompute Compute;
		Compute.BindUFunction(this, n"HandleCompute");
		return Compute;
	}

	/** Invokes the passed callback. */
	UFUNCTION()
	int InvokePassed(FHotReloadRoundTripCompute Compute, int Value)
	{
		return Compute.Execute(Value);
	}

	/** Runs the round trip path and returns the observed result. */
	UFUNCTION()
	int RunRoundTrip(int Value)
	{
		FHotReloadRoundTripCompute Compute = MakeDelegate();
		return InvokePassed(Compute, Value);
	}
}

/** Runs the round trip global path and returns the observed result. */
int RunRoundTripGlobal(int Value)
{
	UHotReloadDelegateRuntimeRoundTripReceiver Receiver = Cast<UHotReloadDelegateRuntimeRoundTripReceiver>(
		NewObject(GetTransientPackage(), UHotReloadDelegateRuntimeRoundTripReceiver::StaticClass()));
	return Receiver.RunRoundTrip(Value);
}
