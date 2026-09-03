/**
 * A parent BlueprintEvent dispatched from BeginPlay. C++ verifies
 * OnPickedUpCallCount==1, LastPickedUpActorHash==42 and PickupValue==10. A zero
 * collector is the boundary.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.InheritanceParentBlueprintEventDispatches
 * @Harness UClass
 * @Tag Feature.Inheritance.InheritanceParentBlueprintEventDispatches
 * @Provenance Theme: Feature.Inheritance. WorldStory parent BlueprintEvent dispatched from BeginPlay.
 * @Provenance C++: AngelscriptActorScriptOverrideTests.cpp::InheritanceParentBlueprintEventDispatches
 * @Provenance Oracle after BeginPlay: OnPickedUpCallCount==1, LastPickedUpActorHash==42, PickupValue==10.
 * @Provenance Extra: empty handle null; pre-BeginPlay counts 0. FixtureIsolated.
 * @Provenance Keep PickupValue/OnPickedUpCallCount/LastPickedUpActorHash.
 */

UCLASS()
class ATestInhParentBase1 : AActor
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
	 * @Covers Inheritance.InheritanceParentBlueprintEventDispatches
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
	 * WorldStory: BeginPlay dispatches OnPickedUp(42).
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.InheritanceParentBlueprintEventDispatches
	 * @Inputs OnPickedUp(42)
	 * @Return OnPickedUpCallCount 1, LastPickedUpActorHash 42, PickupValue 10
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnPickedUp(42);
	}

	/**
	 * Observe that a locally constructed actor has not dispatched OnPickedUp.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceParentBlueprintEventDispatches
	 * @Inputs an actor that has not begun play
	 * @Return OnPickedUpCallCount + LastPickedUpActorHash, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int BeforeBeginPlay()
	{
		return OnPickedUpCallCount + LastPickedUpActorHash;
	}

	/**
	 * Observe the default PickupValue.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceParentBlueprintEventDispatches
	 * @Inputs a freshly constructed actor
	 * @Return PickupValue, expected to be 10
	 */
	UFUNCTION()
	int DefaultPickupValue()
	{
		return PickupValue;
	}

	/**
	 * Observe the parent event state after BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceParentBlueprintEventDispatches
	 * @Inputs an actor whose BeginPlay has dispatched OnPickedUp(42)
	 * @Return true when count is 1, hash is 42 and PickupValue is 10
	 */
	UFUNCTION()
	bool AfterBeginPlay()
	{
		if (OnPickedUpCallCount != 1)
		{
			return false;
		}
		if (LastPickedUpActorHash != 42)
		{
			return false;
		}
		return PickupValue == 10;
	}

	/**
	 * Observe OnPickedUp(0) writing the zero collector boundary.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceParentBlueprintEventDispatches
	 * @Inputs OnPickedUp(0)
	 * @Return LastPickedUpActorHash, expected to be 0
	 * @Boundary zero collector
	 */
	UFUNCTION()
	int ZeroCollectorBoundary()
	{
		OnPickedUp(0);
		return LastPickedUpActorHash;
	}
}
