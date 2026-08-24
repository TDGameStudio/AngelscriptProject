// Theme: HotReload VersionPair After. Same destroy boundary with doubled HandleSignal.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::DelegateReceiverLifecycleBoundaryAcrossReload
// Retained: event, RunLifecycleCheck sequence, DestroyActor after first broadcast.
// Replaced: HandleSignal Calls += Value * 2; first check Calls != 6; stay-6 success path returns 1.
// Oracle: C++ expects controlled error 0 for destroyed bound target after reload. FixtureIsolated.

event void FHotReloadLifecycleSignal(int Value);

UCLASS()
class AHotReloadDelegateRuntimeLifecycleReceiver : AActor
{
	UPROPERTY()
	int Calls = 0;

	UFUNCTION()
	void HandleSignal(int Value)
	{
		Calls += Value * 2;
	}
}

UCLASS()
class AHotReloadDelegateRuntimeLifecycleBroadcaster : AActor
{
	UPROPERTY()
	FHotReloadLifecycleSignal OnSignal;

	UFUNCTION()
	int RunLifecycleCheck(AHotReloadDelegateRuntimeLifecycleReceiver Receiver)
	{
		OnSignal.Clear();
		OnSignal.AddUFunction(Receiver, n"HandleSignal");
		OnSignal.Broadcast(3);
		if (Receiver.Calls != 6)
			return 10;

		Receiver.DestroyActor();
		OnSignal.Broadcast(5);
		return Receiver.Calls == 6 ? 1 : 20;
	}
}
