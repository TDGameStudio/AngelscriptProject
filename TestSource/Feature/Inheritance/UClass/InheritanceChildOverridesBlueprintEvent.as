/**
 * A child BlueprintOverride replaces parent OnPickedUp. C++ verifies after child
 * BeginPlay: ChildOnPickedUpCallCount==1, ChildLastCollectorHash==99, parent
 * counts stay 0, PickupValue==10 and HealAmount==0 (current default-propagation
 * boundary). A parent instance still uses parent OnPickedUp.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.InheritanceChildOverridesBlueprintEvent
 * @Harness UClass
 * @Tag Feature.Inheritance.InheritanceChildOverridesBlueprintEvent
 * @Provenance Theme: Feature.Inheritance. WorldStory child BlueprintOverride replaces parent OnPickedUp.
 * @Provenance C++: AngelscriptActorScriptOverrideTests.cpp::InheritanceChildOverridesBlueprintEvent
 * @Provenance Oracle after child BeginPlay: ChildOnPickedUpCallCount==1, ChildLastCollectorHash==99,
 * @Provenance parent OnPickedUpCallCount==0, LastPickedUpActorHash==0, PickupValue==10, HealAmount==0
 * @Provenance (current default-propagation boundary).
 * @Provenance Extra: empty handle null; parent instance still uses parent OnPickedUp. FixtureIsolated.
 * @Provenance Keep PickupValue/OnPickedUpCallCount/LastPickedUpActorHash/HealAmount/ChildOnPickedUpCallCount/ChildLastCollectorHash.
 */

UCLASS()
class ATestInhParentBase2 : AActor
{
	UPROPERTY()
	int PickupValue = 10;

	UPROPERTY()
	int OnPickedUpCallCount = 0;

	UPROPERTY()
	int LastPickedUpActorHash = 0;

	/**
	 * Parent BlueprintEvent that records the collector hash.
	 *
	 * @Kind Action
	 * @Covers Inheritance.InheritanceChildOverridesBlueprintEvent
	 * @Inputs the collector hash
	 * @Return OnPickedUpCallCount incremented and LastPickedUpActorHash set
	 * @Param CollectorHash the collector identity
	 */
	UFUNCTION(BlueprintEvent)
	void OnPickedUp(int CollectorHash)
	{
		OnPickedUpCallCount += 1;
		LastPickedUpActorHash = CollectorHash;
	}

	/**
	 * WorldStory: parent BeginPlay dispatches OnPickedUp(42).
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.InheritanceChildOverridesBlueprintEvent
	 * @Inputs OnPickedUp(42)
	 * @Return parent OnPickedUpCallCount 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnPickedUp(42);
	}

	/**
	 * Observe that a parent instance still dispatches the parent OnPickedUp.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceChildOverridesBlueprintEvent
	 * @Inputs OnPickedUp(42) on a parent instance
	 * @Return OnPickedUpCallCount, expected to be 1
	 */
	UFUNCTION()
	int ParentStillDispatches()
	{
		OnPickedUp(42);
		return OnPickedUpCallCount;
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

	/**
	 * Child BlueprintOverride that replaces parent OnPickedUp.
	 *
	 * @Kind Action
	 * @Covers Inheritance.InheritanceChildOverridesBlueprintEvent
	 * @Inputs the collector hash
	 * @Return ChildOnPickedUpCallCount incremented and ChildLastCollectorHash set
	 * @Param CollectorHash the collector identity
	 */
	UFUNCTION(BlueprintOverride)
	void OnPickedUp(int CollectorHash)
	{
		ChildOnPickedUpCallCount += 1;
		ChildLastCollectorHash = CollectorHash;
	}

	/**
	 * WorldStory: child BeginPlay dispatches OnPickedUp(99).
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.InheritanceChildOverridesBlueprintEvent
	 * @Inputs OnPickedUp(99)
	 * @Return ChildOnPickedUpCallCount 1, ChildLastCollectorHash 99, parent counts 0
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnPickedUp(99);
	}

	/**
	 * Observe the child override state after BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceChildOverridesBlueprintEvent
	 * @Inputs a child whose BeginPlay has dispatched OnPickedUp(99)
	 * @Return true when child count/hash match and parent counts stay 0
	 */
	UFUNCTION()
	bool AfterBeginPlay()
	{
		if (ChildOnPickedUpCallCount != 1)
		{
			return false;
		}
		if (ChildLastCollectorHash != 99)
		{
			return false;
		}
		if (OnPickedUpCallCount != 0)
		{
			return false;
		}
		if (LastPickedUpActorHash != 0)
		{
			return false;
		}
		if (PickupValue != 10)
		{
			return false;
		}
		return HealAmount == 0;
	}

	/**
	 * Observe OnPickedUp(0) writing the zero collector boundary on the child.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceChildOverridesBlueprintEvent
	 * @Inputs OnPickedUp(0)
	 * @Return ChildLastCollectorHash, expected to be 0
	 * @Boundary zero collector
	 */
	UFUNCTION()
	int ZeroCollectorBoundary()
	{
		OnPickedUp(0);
		return ChildLastCollectorHash;
	}
}
