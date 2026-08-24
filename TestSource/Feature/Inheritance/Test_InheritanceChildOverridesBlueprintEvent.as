// Theme: Feature.Inheritance. WorldStory child BlueprintOverride replaces parent OnPickedUp.
// C++: AngelscriptActorScriptOverrideTests.cpp::InheritanceChildOverridesBlueprintEvent
// Oracle after child BeginPlay: ChildOnPickedUpCallCount==1, ChildLastCollectorHash==99,
// parent OnPickedUpCallCount==0, LastPickedUpActorHash==0, PickupValue==10, HealAmount==0
// (current default-propagation boundary).
// Extra: empty handle null; parent instance still uses parent OnPickedUp. FixtureIsolated.
// Keep PickupValue/OnPickedUpCallCount/LastPickedUpActorHash/HealAmount/ChildOnPickedUpCallCount/ChildLastCollectorHash.

UCLASS()
class ATestInhParentBase2 : AActor
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

UCLASS()
class ATestInhHealthPickup2 : ATestInhParentBase2
{
	UPROPERTY()
	int HealAmount = 25;

	UPROPERTY()
	int ChildOnPickedUpCallCount = 0;

	UPROPERTY()
	int ChildLastCollectorHash = 0;

	default PickupValue = 25;

	UFUNCTION(BlueprintOverride)
	void OnPickedUp(int CollectorHash)
	{
		ChildOnPickedUpCallCount += 1;
		ChildLastCollectorHash = CollectorHash;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnPickedUp(99);
	}
}

bool Observe_ChildOverride_EmptyHandleIsNull()
{
	ATestInhHealthPickup2 Actor;
	return Actor == nullptr;
}

bool Observe_ChildOverride_AfterBeginPlay(ATestInhHealthPickup2 Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0176 setup: required ATestInhHealthPickup2 is null");
	}
	return Actor.ChildOnPickedUpCallCount == 1
		&& Actor.ChildLastCollectorHash == 99
		&& Actor.OnPickedUpCallCount == 0
		&& Actor.LastPickedUpActorHash == 0
		&& Actor.PickupValue == 10
		&& Actor.HealAmount == 0;
}

int Observe_ChildOverride_ParentStillDispatches(ATestInhParentBase2 Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0176 setup: required ATestInhParentBase2 is null");
	}
	Actor.OnPickedUp(42);
	return Actor.OnPickedUpCallCount;
}

int Observe_ChildOverride_ZeroCollectorBoundary(ATestInhHealthPickup2 Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0176 setup: required ATestInhHealthPickup2 is null");
	}
	Actor.OnPickedUp(0);
	return Actor.ChildLastCollectorHash;
}
