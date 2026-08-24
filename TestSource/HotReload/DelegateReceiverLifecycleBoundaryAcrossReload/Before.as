// Theme: HotReload VersionPair Before. Destroyed receiver must not keep accumulating.
// C++: AngelscriptHotReloadDelegateRuntimeTests.cpp::DelegateReceiverLifecycleBoundaryAcrossReload
// Retained after reload: event FHotReloadLifecycleSignal, receiver Calls, broadcaster OnSignal, RunLifecycleCheck.
// Replaced in After: HandleSignal Value -> Value * 2; expected Calls 3 -> 6.
// Oracle: first Broadcast(3) Calls==3; after DestroyActor Broadcast(5) Calls stays 3 or C++ sees controlled error 0.
// Extra: null/destroyed bound target is the boundary. FixtureIsolated.

event void FHotReloadLifecycleSignal(int Value);

UCLASS()
class AHotReloadDelegateRuntimeLifecycleReceiver : AActor
{
	UPROPERTY()
	int Calls = 0;

	UFUNCTION()
	void HandleSignal(int Value)
	{
		Calls += Value;
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
		if (Receiver.Calls != 3)
			return 10;

		Receiver.DestroyActor();
		OnSignal.Broadcast(5);
		return Receiver.Calls == 3 ? 1 : 20;
	}
}
