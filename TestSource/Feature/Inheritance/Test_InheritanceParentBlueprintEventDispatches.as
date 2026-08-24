// Theme: Feature.Inheritance. WorldStory parent BlueprintEvent dispatched from BeginPlay.
// C++: AngelscriptActorScriptOverrideTests.cpp::InheritanceParentBlueprintEventDispatches
// Oracle after BeginPlay: OnPickedUpCallCount==1, LastPickedUpActorHash==42, PickupValue==10.
// Extra: empty handle null; pre-BeginPlay counts 0. FixtureIsolated.
// Keep PickupValue/OnPickedUpCallCount/LastPickedUpActorHash.

UCLASS()
class ATestInhParentBase1 : AActor
{
	UPROPERTY()
	int PickupValue = 10;

	UPROPERTY()
	int OnPickedUpCallCount = 0;

	UPROPERTY()
	int LastPickedUpActorHash = 0;

	UFUNCTION(BlueprintEvent)
	void OnPickedUp(int CollectorHash)
	{
		OnPickedUpCallCount += 1;
		LastPickedUpActorHash = CollectorHash;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnPickedUp(42);
	}
}

bool Observe_ParentEvent_EmptyHandleIsNull()
{
	ATestInhParentBase1 Actor;
	return Actor == nullptr;
}

int Observe_ParentEvent_BeforeBeginPlay(ATestInhParentBase1 Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0175 setup: required ATestInhParentBase1 is null");
	}
	return Actor.OnPickedUpCallCount + Actor.LastPickedUpActorHash;
}

int Observe_ParentEvent_PickupDefault(ATestInhParentBase1 Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0175 setup: required ATestInhParentBase1 is null");
	}
	return Actor.PickupValue;
}

bool Observe_ParentEvent_AfterBeginPlay(ATestInhParentBase1 Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0175 setup: required ATestInhParentBase1 is null");
	}
	return Actor.OnPickedUpCallCount == 1
		&& Actor.LastPickedUpActorHash == 42
		&& Actor.PickupValue == 10;
}

int Observe_ParentEvent_ZeroCollectorBoundary(ATestInhParentBase1 Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0175 setup: required ATestInhParentBase1 is null");
	}
	Actor.OnPickedUp(0);
	return Actor.LastPickedUpActorHash;
}
