// Theme: Feature.Delegates. WorldStory multicast fan-out plus unicast Execute.
// C++: AngelscriptDelegateBroadcastWithParamsTests.cpp::EventBroadcastFanOutsToAllListenersAndDelegateExecuteReturnsValue
// sha256=7533fb19602f61479ef0babdbb00b8e2e138e07eae6862790e562786cd8cbb45; lines 32-94.
// Oracle after BeginPlay: ListenerOneCount==2; ListenerTwoCount==1; LastDamage==7.0;
// DelegateWasBound==true; LastCanInteractResult==true (Execute(3)).
// Extra: local construct zeros/false; ResolveCanInteract(0) is the false boundary.
// FixtureIsolated. BeginPlay owns bind/unbind/broadcast/execute.

event void FFunctionalDamageEvent(float Damage, bool bWasCrit, FVector Origin);
delegate bool FFunctionalCanInteract(int32 Querier);

UCLASS()
class AFunctionalBroadcastActor : AActor
{
	UPROPERTY()
	int32 ListenerOneCount = 0;

	UPROPERTY()
	int32 ListenerTwoCount = 0;

	UPROPERTY()
	float LastDamage = 0.0;

	UPROPERTY()
	bool LastCanInteractResult = false;

	UPROPERTY()
	bool DelegateWasBound = false;

	UPROPERTY()
	FFunctionalDamageEvent DamageEvent;

	UPROPERTY()
	FFunctionalCanInteract CanInteract;

	UFUNCTION()
	void HandleDamageOne(float Damage, bool bWasCrit, FVector Origin)
	{
		ListenerOneCount += 1;
		LastDamage = Damage;
	}

	UFUNCTION()
	void HandleDamageTwo(float Damage, bool bWasCrit, FVector Origin)
	{
		ListenerTwoCount += 1;
	}

	UFUNCTION()
	bool ResolveCanInteract(int32 Querier)
	{
		return Querier > 0;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DamageEvent.AddUFunction(this, n"HandleDamageOne");
		DamageEvent.AddUFunction(this, n"HandleDamageTwo");
		DamageEvent.Broadcast(42.0, false, FVector(1.0, 2.0, 3.0));

		DamageEvent.Unbind(this, n"HandleDamageTwo");
		DamageEvent.Broadcast(7.0, true, FVector::ZeroVector);

		CanInteract.BindUFunction(this, n"ResolveCanInteract");
		DelegateWasBound = CanInteract.IsBound();
		LastCanInteractResult = CanInteract.Execute(3);
	}
}

bool Observe_FanOut_DefaultEmpty(AFunctionalBroadcastActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventBroadcastFanOutsToAllListenersAndDelegateExecuteReturnsValue setup: required Actor is null");
	}
	return Actor.ListenerOneCount == 0
		&& Actor.ListenerTwoCount == 0
		&& Actor.LastDamage == 0.0
		&& !Actor.LastCanInteractResult
		&& !Actor.DelegateWasBound
		&& !Actor.DamageEvent.IsBound()
		&& !Actor.CanInteract.IsBound();
}

bool Observe_ResolveCanInteract_FalseZeroBoundary(AFunctionalBroadcastActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventBroadcastFanOutsToAllListenersAndDelegateExecuteReturnsValue setup: required Actor is null");
	}
	return !Actor.ResolveCanInteract(0) && !Actor.ResolveCanInteract(-1) && Actor.ResolveCanInteract(3);
}

int Observe_HandleDamageOne_ZeroDamageBoundary(AFunctionalBroadcastActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventBroadcastFanOutsToAllListenersAndDelegateExecuteReturnsValue setup: required Actor is null");
	}
	Actor.HandleDamageOne(0.0, false, FVector::ZeroVector);
	return Actor.ListenerOneCount;
}
