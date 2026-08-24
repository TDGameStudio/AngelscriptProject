// Theme: Gameplay.Anim. WorldStory RepNotify state-change event path.
// C++: AngelscriptCoverageEventTests.cpp::EventRepNotifyExecutesStateChange
// Oracle VerifyByPath after ApplyReplicatedHealth(87): TrackedHealth 87,
// RepNotifyCount 1, LastReplicatedHealth 87, bRepNotifyExecuted true.
// Extra: defaults 0/false; ApplyReplicatedHealth(0) is the zero boundary.
// FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageEventRepNotifyActor : AActor
{
	UPROPERTY(ReplicatedUsing=OnRep_TrackedHealth)
	int TrackedHealth = 0;

	UPROPERTY()
	int RepNotifyCount = 0;

	UPROPERTY()
	int LastReplicatedHealth = 0;

	UPROPERTY()
	bool bRepNotifyExecuted = false;

	UFUNCTION()
	void ApplyReplicatedHealth(int NewHealth)
	{
		TrackedHealth = NewHealth;
		OnRep_TrackedHealth();
	}

	UFUNCTION()
	void OnRep_TrackedHealth()
	{
		RepNotifyCount += 1;
		LastReplicatedHealth = TrackedHealth;
		bRepNotifyExecuted = true;
	}
}

bool Observe_RepNotify_DefaultEmpty(ACoverageEventRepNotifyActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventRepNotifyExecutesStateChange setup: required Actor is null");
	}
	return Actor.TrackedHealth == 0
		&& Actor.RepNotifyCount == 0
		&& Actor.LastReplicatedHealth == 0
		&& Actor.bRepNotifyExecuted == false;
}

bool Observe_RepNotify_Apply87(ACoverageEventRepNotifyActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventRepNotifyExecutesStateChange setup: required Actor is null");
	}
	Actor.ApplyReplicatedHealth(87);
	return Actor.TrackedHealth == 87
		&& Actor.RepNotifyCount == 1
		&& Actor.LastReplicatedHealth == 87
		&& Actor.bRepNotifyExecuted == true;
}

bool Observe_RepNotify_ZeroBoundary(ACoverageEventRepNotifyActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventRepNotifyExecutesStateChange setup: required Actor is null");
	}
	Actor.ApplyReplicatedHealth(0);
	return Actor.TrackedHealth == 0
		&& Actor.RepNotifyCount == 1
		&& Actor.LastReplicatedHealth == 0
		&& Actor.bRepNotifyExecuted == true;
}
