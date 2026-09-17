/**
 * @version v1
 * @summary ProcessEvent routes OnPickedUp to the child override. C++ verifies after ProcessEvent(777): ChildOnPickedUpCallCount==1, ChildLastCollectorHash==777 and parent OnPickedUpCallCount==0. Direct OnPickedUp(0) is the.
 * @topic Feature
 */
/**
 * @version root
 * @summary ProcessEvent routes OnPickedUp to the child override. C++ verifies after ProcessEvent(777): ChildOnPickedUpCallCount==1, ChildLastCollectorHash==777 and parent OnPickedUpCallCount==0. Direct OnPickedUp(0) is the.
 * @topic Baseline
 */
UCLASS()
class ATestInhParentBase3 : AActor
{
	UPROPERTY()
	int OnPickedUpCallCount = 0;

	/**
	 * Parent BlueprintEvent that would count if ProcessEvent did not hit the child.
	 *
	 * @Kind Action
	 * @Covers Inheritance.InheritanceProcessEventDispatchesToChildOverride
	 * @Inputs the collector hash
	 * @Return OnPickedUpCallCount incremented
	 * @Param CollectorHash the collector identity
	 */
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

	/**
	 * Child BlueprintOverride that ProcessEvent must dispatch to.
	 *
	 * @Kind Action
	 * @Covers Inheritance.InheritanceProcessEventDispatchesToChildOverride
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
	 * Observe that a locally constructed child has not been dispatched.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceProcessEventDispatchesToChildOverride
	 * @Inputs a child that has not received OnPickedUp
	 * @Return the sum of parent and child counts, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int Defaults()
	{
		return OnPickedUpCallCount + ChildOnPickedUpCallCount + ChildLastCollectorHash;
	}

	/**
	 * Observe a direct OnPickedUp(777) writing the child hash.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceProcessEventDispatchesToChildOverride
	 * @Inputs OnPickedUp(777)
	 * @Return ChildLastCollectorHash, expected to be 777
	 */
	UFUNCTION()
	int Direct777()
	{
		OnPickedUp(777);
		return ChildLastCollectorHash;
	}

	/**
	 * Observe that a child dispatch leaves the parent count at 0.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceProcessEventDispatchesToChildOverride
	 * @Inputs OnPickedUp(777)
	 * @Return OnPickedUpCallCount, expected to be 0
	 */
	UFUNCTION()
	int ParentStaysZero()
	{
		OnPickedUp(777);
		return OnPickedUpCallCount;
	}

	/**
	 * Observe OnPickedUp(0) writing the zero collector boundary on the child.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceProcessEventDispatchesToChildOverride
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
/** @end */
