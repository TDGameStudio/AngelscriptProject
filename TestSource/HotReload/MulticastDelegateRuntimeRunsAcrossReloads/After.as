// Theme: HotReload VersionPair After. Same multicast sequence with scaled handlers.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::MulticastDelegateRuntimeRunsAcrossReloads
// Retained: event signature, RunMulticast steps, Clear/Unbind/Broadcast, actor identity.
// Replaced: HandlerA Value*2, HandlerB Value*20; checks 4/40 then 4/100.
// Oracle: RunMulticast returns 1 on the existing actor. FixtureIsolated.

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
		CountA += Value * 2;
	}

	UFUNCTION()
	void HandlerB(int Value)
	{
		CountB += Value * 20;
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
		if (CountA != 4 || CountB != 40)
			return 20;

		OnSignal.Unbind(this, n"HandlerA");
		OnSignal.Broadcast(3);
		if (CountA != 4 || CountB != 100)
			return 30;

		OnSignal.Clear();
		if (OnSignal.IsBound())
			return 40;

		OnSignal.Broadcast(5);
		return (CountA == 4 && CountB == 100) ? 1 : 50;
	}
}
