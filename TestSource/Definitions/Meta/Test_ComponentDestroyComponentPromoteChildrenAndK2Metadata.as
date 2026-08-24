// Theme: Definitions.Meta. WorldStory: DestroyComponent(true) promotes children.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentDestroyComponentPromoteChildrenAndK2Metadata
// Oracle VerifyByPath: DestroyReturned, ParentBeingDestroyedAfterCall, ChildReattachedToRoot.
// Extra: defaults false; ChildProbe.EndPlayCount 0; null handle. FixtureIsolated.

UCLASS()
class UCoverageDestroyPromoteChildComponent : USceneComponent
{
	UPROPERTY()
	int EndPlayCount = 0;

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		EndPlayCount++;
	}
}

UCLASS()
class ACoverageComponentDestroyPromoteActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCoverageDestroyPromoteChildComponent ParentProbe;

	UPROPERTY(DefaultComponent, Attach=ParentProbe)
	UCoverageDestroyPromoteChildComponent ChildProbe;

	UPROPERTY()
	bool DestroyReturned = false;

	UPROPERTY()
	bool ParentBeingDestroyedAfterCall = false;

	UPROPERTY()
	bool ChildReattachedToRoot = false;

	UFUNCTION()
	void DestroyParentWithPromotedChild()
	{
		if (ParentProbe == nullptr || ChildProbe == nullptr || Root == nullptr)
		{
			return;
		}

		ParentProbe.DestroyComponent(true);
		DestroyReturned = true;
		ParentBeingDestroyedAfterCall = ParentProbe.IsBeingDestroyed();
		ChildReattachedToRoot = ChildProbe.GetAttachParent() == Root;
	}
}

bool Observe_DestroyPromote_DefaultsFalse(ACoverageComponentDestroyPromoteActor Actor)
{
	return !Actor.DestroyReturned && !Actor.ParentBeingDestroyedAfterCall && !Actor.ChildReattachedToRoot;
}

int Observe_DestroyPromote_ChildEndPlayDefault(ACoverageComponentDestroyPromoteActor Actor)
{
	if (Actor.ChildProbe == nullptr)
	{
		return -1;
	}
	return Actor.ChildProbe.EndPlayCount;
}

int Observe_DestroyPromote_EmptyDefaultIsNull()
{
	ACoverageComponentDestroyPromoteActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
