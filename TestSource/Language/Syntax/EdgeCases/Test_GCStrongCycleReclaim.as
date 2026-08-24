// Theme: Language.Syntax.EdgeCases. WorldStory UObject cycle is collected without external roots.
// C++: AngelscriptCoverageGCTests.cpp::GCStrongCycleReclaim
// sha256=aea59dc3c0049865b55b3c87125c4792ecdc4d66e90d6802e3a9339949451d63; lines 954-993.
// Oracle: StrongCycleCreated=true; StrongCycleCollected=true.
// Extra: flags default false. FixtureIsolated. Cycle edges are UPROPERTY Other.

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
}

bool Observe_GCStrongCycle_DefaultFalse(ACoverageGCStrongCycleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_GCStrongCycleReclaim setup: required Actor is null");
	}
	return !Actor.StrongCycleCreated && !Actor.StrongCycleCollected;
}
