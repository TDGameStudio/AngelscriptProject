/**
 * A UPROPERTY chain keeps Root and Child alive, then releasing collects both.
 * C++ verifies named properties by path, so those names are kept. The observers
 * cover a null RootNode and an empty weak chain.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.GCUPropertyReachabilityChain
 * @Harness UClass
 * @Tag Definitions.UProperty.GCUPropertyReachabilityChain
 * @Provenance Theme: Definitions.UProperty. WorldStory: UPROPERTY chain keeps Root+Child alive, then releasing collects both.
 * @Provenance C++: VerifyByPath ReachabilityChainSurvivedGC true; ReleasedChainWasCollected true.
 * @Provenance Extra: null RootNode.Child is the empty chain. FixtureIsolated.
 */

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

	/**
	 * WorldStory: keep Root+Child alive through UPROPERTY, then release both.
	 *
	 * @Kind WorldStory
	 * @Covers UProperty.GCUPropertyReachabilityChain
	 * @Inputs a root node whose Child is a Texture2D
	 * @Return ReachabilityChainSurvivedGC then ReleasedChainWasCollected
	 */
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

	/**
	 * Observe that a null RootNode has no child.
	 *
	 * @Kind Observe
	 * @Covers UProperty.GCUPropertyReachabilityChain
	 * @Inputs an unset UCoverageGCReachabilityNode
	 * @Return true when the node is null
	 * @Boundary null default
	 */
	UFUNCTION()
	bool NullRootNodeHasNoChild()
	{
		UCoverageGCReachabilityNode RootNode;
		return RootNode == nullptr;
	}

	/**
	 * Observe that an empty weak chain is invalid on both ends.
	 *
	 * @Kind Observe
	 * @Covers UProperty.GCUPropertyReachabilityChain
	 * @Inputs two default-constructed TWeakObjectPtr<UObject>
	 * @Return true when both weak refs are invalid
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyWeakChainIsInvalid()
	{
		TWeakObjectPtr<UObject> WeakRoot;
		TWeakObjectPtr<UObject> WeakLeaf;
		if (WeakRoot.IsValid())
		{
			return false;
		}
		return !WeakLeaf.IsValid();
	}
}
