// Theme: HotReload VersionPair Before. Multicast add, broadcast, unbind, clear.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::MulticastDelegateRuntimeRunsAcrossReloads
// Retained after reload: FHotReloadMulticastSignal, OnSignal, HandlerA/HandlerB names, RunMulticast control flow.
// Replaced in After: HandlerA Value*2, HandlerB Value*20, expected counts 4/40 then 4/100.
// Oracle: RunMulticast returns 1. Error codes 10/20/30/40/50 on failed steps.
// FixtureIsolated.

event void FHotReloadMulticastSignal(int Value);

UCLASS()
class AHotReloadDelegateRuntimeMulticastActor : AActor
{
	UPROPERTY()
	FHotReloadMulticastSignal OnSignal;

	UPROPERTY()
	int CountA = 0;

	UPROPERTY()
	int CountB = 0;

	UFUNCTION()
	void HandlerA(int Value)
	{
		CountA += Value;
	}

	UFUNCTION()
	void HandlerB(int Value)
	{
		CountB += Value * 10;
	}

	UFUNCTION()
	int RunMulticast()
	{
		OnSignal.Clear();
		CountA = 0;
		CountB = 0;

		OnSignal.AddUFunction(this, n"HandlerA");
		OnSignal.AddUFunction(this, n"HandlerB");
		if (!OnSignal.IsBound())
			return 10;

		OnSignal.Broadcast(2);
		if (CountA != 2 || CountB != 20)
			return 20;

		OnSignal.Unbind(this, n"HandlerA");
		OnSignal.Broadcast(3);
		if (CountA != 2 || CountB != 50)
			return 30;

		OnSignal.Clear();
		if (OnSignal.IsBound())
			return 40;

		OnSignal.Broadcast(5);
		return (CountA == 2 && CountB == 50) ? 1 : 50;
	}
}
