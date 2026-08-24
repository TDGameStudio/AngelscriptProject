// Theme: Feature.Inheritance. WorldStory ProcessEvent routes OnPickedUp to the child override.
// C++: AngelscriptActorScriptOverrideTests.cpp::InheritanceProcessEventDispatchesToChildOverride
// Oracle after ProcessEvent(777): ChildOnPickedUpCallCount==1, ChildLastCollectorHash==777,
// parent OnPickedUpCallCount==0.
// Extra: empty handle null; direct OnPickedUp(0) boundary. FixtureIsolated.
// Keep OnPickedUpCallCount/ChildOnPickedUpCallCount/ChildLastCollectorHash.

UCLASS()
class ATestInhParentBase3 : AActor
{
	UPROPERTY()
	int OnPickedUpCallCount = 0;

	UFUNCTION(BlueprintEvent)
	void OnPickedUp(int CollectorHash)
	{
		OnPickedUpCallCount += 1;
	}
}

UCLASS()
class ATestInhHealthPickup3 : ATestInhParentBase3
{
	UPROPERTY()
	int ChildOnPickedUpCallCount = 0;

	UPROPERTY()
	int ChildLastCollectorHash = 0;

	UFUNCTION(BlueprintOverride)
	void OnPickedUp(int CollectorHash)
	{
		ChildOnPickedUpCallCount += 1;
		ChildLastCollectorHash = CollectorHash;
	}
}

bool Observe_ProcessEventChild_EmptyHandleIsNull()
{
	ATestInhHealthPickup3 Actor;
	return Actor == nullptr;
}

int Observe_ProcessEventChild_Defaults(ATestInhHealthPickup3 Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0177 setup: required ATestInhHealthPickup3 is null");
	}
	return Actor.OnPickedUpCallCount + Actor.ChildOnPickedUpCallCount + Actor.ChildLastCollectorHash;
}

int Observe_ProcessEventChild_Direct777(ATestInhHealthPickup3 Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0177 setup: required ATestInhHealthPickup3 is null");
	}
	Actor.OnPickedUp(777);
	return Actor.ChildLastCollectorHash;
}

int Observe_ProcessEventChild_ParentStaysZero(ATestInhHealthPickup3 Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0177 setup: required ATestInhHealthPickup3 is null");
	}
	Actor.OnPickedUp(777);
	return Actor.OnPickedUpCallCount;
}

int Observe_ProcessEventChild_ZeroCollectorBoundary(ATestInhHealthPickup3 Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0177 setup: required ATestInhHealthPickup3 is null");
	}
	Actor.OnPickedUp(0);
	return Actor.ChildLastCollectorHash;
}
