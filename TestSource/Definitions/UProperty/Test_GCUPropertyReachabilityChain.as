// Theme: Definitions.UProperty. WorldStory: UPROPERTY chain keeps Root+Child alive, then releasing collects both.
// C++: VerifyByPath ReachabilityChainSurvivedGC true; ReleasedChainWasCollected true.
// Extra: null RootNode.Child is the empty chain. FixtureIsolated.

UCLASS()
class UCoverageGCReachabilityNode : UObject
{
	UPROPERTY()
	UObject Child;
}

UCLASS()
class ACoverageGCReachabilityChainActor : AActor
{
	UPROPERTY()
	UCoverageGCReachabilityNode RootNode;

	UPROPERTY()
	bool ReachabilityChainSurvivedGC = false;

	UPROPERTY()
	bool ReleasedChainWasCollected = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RootNode = Cast<UCoverageGCReachabilityNode>(
			NewObject(this, UCoverageGCReachabilityNode::StaticClass(), n"CoverageGCReachabilityRoot"));

		UObject LeafObject = NewObject(RootNode, UTexture2D::StaticClass(), n"CoverageGCReachabilityLeaf");
		RootNode.Child = LeafObject;

		TWeakObjectPtr<UObject> WeakRoot = RootNode;
		TWeakObjectPtr<UObject> WeakLeaf = LeafObject;
		LeafObject = nullptr;

		CoverageGC::ForceGarbageCollectionNow();
		ReachabilityChainSurvivedGC = WeakRoot.IsValid() && WeakLeaf.IsValid() && RootNode.Child != nullptr;

		RootNode.Child = nullptr;
		RootNode = nullptr;

		CoverageGC::ForceGarbageCollectionNow();
		ReleasedChainWasCollected = !WeakRoot.IsValid() && !WeakLeaf.IsValid();
	}
}

bool Observe_NullRootNodeHasNoChild()
{
	UCoverageGCReachabilityNode RootNode;
	return RootNode == nullptr;
}

bool Observe_EmptyWeakChainIsInvalid()
{
	TWeakObjectPtr<UObject> WeakRoot;
	TWeakObjectPtr<UObject> WeakLeaf;
	return !WeakRoot.IsValid() && !WeakLeaf.IsValid();
}
