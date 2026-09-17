/**
 * @version v1
 * @summary A two-node UObject cycle held only by its own UPROPERTY edges is collected once the external locals are cleared, because the GC resolves reference cycles.
 * @topic Language
 */
/**
 * @version root
 * @summary A two-node UObject cycle held only by its own UPROPERTY edges is collected once the external locals are cleared, because the GC resolves reference cycles.
 * @topic Baseline
 */
/**
 * A cycle node whose single edge points back at its partner.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs the node's Other reference
 * @Return nothing; the edge is a plain UPROPERTY
 */
UCLASS()
class UCoverageGCCycleNode : UObject
{
	UPROPERTY()
	UObject Other;
}

UCLASS()
class ACoverageGCStrongCycleActor : AActor
{
	UPROPERTY()
	bool StrongCycleCreated = false;

	UPROPERTY()
	bool StrongCycleCollected = false;

	/**
	 * Builds the cycle, then clears the locals and collects.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; both flags record their outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UCoverageGCCycleNode NodeA = Cast<UCoverageGCCycleNode>(
			NewObject(GetTransientPackage(), UCoverageGCCycleNode::StaticClass(), n"CoverageGCCycleA"));
		UCoverageGCCycleNode NodeB = Cast<UCoverageGCCycleNode>(
			NewObject(GetTransientPackage(), UCoverageGCCycleNode::StaticClass(), n"CoverageGCCycleB"));

		NodeA.Other = NodeB;
		NodeB.Other = NodeA;

		TWeakObjectPtr<UObject> WeakA = NodeA;
		TWeakObjectPtr<UObject> WeakB = NodeB;
		StrongCycleCreated = WeakA.IsValid() && WeakB.IsValid();

		NodeA = nullptr;
		NodeB = nullptr;

		CoverageGC::ForceGarbageCollectionNow();
		StrongCycleCollected = !WeakA.IsValid() && !WeakB.IsValid();
	}

	/**
	 * Observe that a locally constructed actor has built no cycle.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCStrongCycleFlagsDefaultToFalse()
	{
		if (StrongCycleCreated)
		{
			return false;
		}

		return !StrongCycleCollected;
	}
}
/** @end */
