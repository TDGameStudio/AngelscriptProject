/**
 * @version v1
 * @summary DestroyComponent(true) promotes children. C++ verifies DestroyReturned, ParentBeingDestroyedAfterCall and ChildReattachedToRoot by path. Defaults are false and ChildProbe.EndPlayCount is 0.
 * @topic Definitions
 */
/**
 * @version root
 * @summary DestroyComponent(true) promotes children. C++ verifies DestroyReturned, ParentBeingDestroyedAfterCall and ChildReattachedToRoot by path. Defaults are false and ChildProbe.EndPlayCount is 0.
 * @topic Baseline
 */
UCLASS()
class UCoverageDestroyPromoteChildComponent : USceneComponent
{
	UPROPERTY()
	int EndPlayCount = 0;

	/**
	 * Count EndPlay so C++ can tell a promoted child from a destroyed one.
	 *
	 * @Kind WorldStory
	 * @Covers Meta.ComponentDestroyComponentPromoteChildrenAndK2Metadata
	 * @Inputs the end-play reason
	 * @Return EndPlayCount incremented
	 * @Param EndPlayReason the reason EndPlay ran
	 */
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

	/**
	 * Destroy the parent with bPromoteChildren so the child reattaches to Root.
	 *
	 * @Kind Observe
	 * @Covers Meta.ComponentDestroyComponentPromoteChildrenAndK2Metadata
	 * @Inputs none
	 * @Return DestroyReturned, ParentBeingDestroyedAfterCall and ChildReattachedToRoot written
	 */
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

	/**
	 * Observe that the destroy flags default to false.
	 *
	 * @Kind Observe
	 * @Covers Meta.ComponentDestroyComponentPromoteChildrenAndK2Metadata
	 * @Inputs none
	 * @Return true when all three flags are false
	 * @Boundary defaults false
	 */
	UFUNCTION()
	bool DefaultsFalse()
	{
		if (DestroyReturned)
		{
			return false;
		}
		if (ParentBeingDestroyedAfterCall)
		{
			return false;
		}
		return !ChildReattachedToRoot;
	}

	/**
	 * Observe that ChildProbe has not ended play yet.
	 *
	 * @Kind Observe
	 * @Covers Meta.ComponentDestroyComponentPromoteChildrenAndK2Metadata
	 * @Inputs none
	 * @Return 0, or -1 when ChildProbe is null
	 * @Boundary EndPlayCount default
	 */
	UFUNCTION()
	int ChildEndPlayDefault()
	{
		if (ChildProbe == nullptr)
		{
			return -1;
		}
		return ChildProbe.EndPlayCount;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.ComponentDestroyComponentPromoteChildrenAndK2Metadata
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		ACoverageComponentDestroyPromoteActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
