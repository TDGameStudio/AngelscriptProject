// Theme: HotReload VersionPair Before. Delegate passed as argument and returned.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::DelegateArgumentAndReturnRoundTripAcrossReloads
// Retained after reload: MakeDelegate, InvokePassed, RunRoundTrip, RunRoundTripGlobal, bind HandleCompute.
// Replaced in After: HandleCompute Value + 4 -> Value * 3.
// Oracle: RunRoundTripGlobal(Value) uses V1 + 4. FixtureIsolated.

/** Delegate FHotReloadRoundTripCompute: carries (int Value) for this reload scenario. */
delegate int FHotReloadRoundTripCompute(int Value);

UCLASS()
class UHotReloadDelegateRuntimeRoundTripReceiver : UObject
{
	/** Handles the compute callback. */
	UFUNCTION()
	int HandleCompute(int Value)
	{
		return Value + 4;
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
