/**
 * @version v1
 * @summary World blueprint spawn and class stories.
 * @topic Unreal
 * @topic World
 *
 * default-preservation
 * disk-backed-asset-scan
 * impact-filter-a
 * impact-filter-b
 * recreate-does-not-leak-state
 * script-parent-match
 */
/**
 * @begin default-preservation
 * @summary A script parent whose defaults a Blueprint child must preserve on both the CDO and any instance. C++ reads the counter, toggle and label off both classes.
 * @topic Blueprint
 */
UCLASS()
class ATestBPChildDefaultPreservationParent : AActor
{
	UPROPERTY()
	int DefaultCounter = 23;

	UPROPERTY()
	bool bDefaultToggle = true;

	UPROPERTY()
	FString DefaultLabel = "ScriptParentDefault";
}

/**
 * The sibling holding the emptied defaults, which C++ uses as the empty boundary.
 * Its UPROPERTYs are part of the fixture and must be kept.
 *
 * @Covers Blueprint.DefaultPreservation
 * @Inputs none
 * @Return an actor identical in shape but with a zeroed counter, a clear toggle and an empty label
 * @Boundary emptied defaults
 */
UCLASS()
class ATestBPChildDefaultPreservationParentEmpty : AActor
{
	UPROPERTY()
	int DefaultCounter = 0;

	UPROPERTY()
	bool bDefaultToggle = false;

	UPROPERTY()
	FString DefaultLabel = "";
}
/** @end */
/**
 * @begin disk-backed-asset-scan
 * @summary A script parent that C++ locates through its on-disk Blueprint asset scan. The marker value is what the scan resolves the class by.
 * @topic Blueprint
 */
UCLASS()
class ATestBPImpactDiskBacked : AActor
{
	UPROPERTY()
	int Marker = 10;
}

/**
 * The sibling holding the zeroed marker, which C++ uses as the empty boundary. Its
 * UPROPERTY is part of the fixture and must be kept.
 *
 * @Covers Blueprint.DiskBackedAssetScan
 * @Inputs none
 * @Return an actor identical in shape but with Marker 0
 * @Boundary zeroed marker
 */
UCLASS()
class ATestBPImpactDiskBackedEmpty : AActor
{
	UPROPERTY()
	int Marker = 0;
}
/** @end */
/**
 * @begin impact-filter-a
 * @summary Blueprint A, whose parent is this script and which must be marked impacted by a change to it. C++ compiles this as the module TestBPImpactFilterA; its companion ImpactFilterB carries the non-impacted parent.
 * @topic Blueprint
 */
UCLASS()
class ATestBPImpactFilterA : AActor
{
	UPROPERTY()
	int Value = 1;
}

/**
 * The sibling holding the zeroed value, which C++ uses as the empty boundary. Its
 * UPROPERTY is part of the fixture and must be kept.
 *
 * @Covers Blueprint.ImpactFilterA
 * @Inputs none
 * @Return an actor identical in shape but with Value 0
 * @Boundary zeroed value
 */
UCLASS()
class ATestBPImpactFilterAEmpty : AActor
{
	UPROPERTY()
	int Value = 0;
}
/** @end */
/**
 * @begin impact-filter-b
 * @summary Blueprint B, the non-impacted parent: changing the other filter must not mark this one impacted. C++ compiles this as the module TestBPImpactFilterB; its companion ImpactFilterA carries the impacted parent.
 * @topic Blueprint
 */
UCLASS()
class ATestBPImpactFilterB : AActor
{
	UPROPERTY()
	int Value = 2;
}

/**
 * The sibling holding the zeroed value, which C++ uses as the empty boundary. Its
 * UPROPERTY is part of the fixture and must be kept.
 *
 * @Covers Blueprint.ImpactFilterB
 * @Inputs none
 * @Return an actor identical in shape but with Value 0
 * @Boundary zeroed value
 */
UCLASS()
class ATestBPImpactFilterBEmpty : AActor
{
	UPROPERTY()
	int Value = 0;
}
/** @end */
/**
 * @begin recreate-does-not-leak-state
 * @summary A script parent whose state must not leak from one created child to the next. C++ bumps the state on a first actor, creates a second and verifies that the second only carries the BeginPlay increment.
 * @topic Blueprint
 */
UCLASS()
class ATestBPChildRecreateNoLeakParent : AActor
{
	UPROPERTY()
	int StatefulValue = 10;

	UPROPERTY()
	int BeginPlayCount = 0;

	/**
	 * WorldStory: BeginPlay counts the dispatch and increments the state by one.
	 *
	 * @Kind WorldStory
	 * @Covers Blueprint.RecreateDoesNotLeakState
	 * @Inputs none
	 * @Return BeginPlayCount incremented and StatefulValue grown by 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
		StatefulValue += 1;
	}

	/**
	 * Bump the state by a large amount so a leak would be visible on a later instance.
	 *
	 * @Kind Action
	 * @Covers Blueprint.RecreateDoesNotLeakState
	 * @Inputs none
	 * @Return StatefulValue grown by 37
	 */
	UFUNCTION()
	void BumpState()
	{
		StatefulValue += 37;
	}

	/**
	 * Observe that a locally constructed parent keeps its declared defaults.
	 *
	 * @Kind Observe
	 * @Covers Blueprint.RecreateDoesNotLeakState
	 * @Inputs a parent that has not begun play
	 * @Return true when the state is 10 and the count is 0
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (StatefulValue != 10)
		{
			return false;
		}
		return BeginPlayCount == 0;
	}
}
/** @end */
/**
 * @begin script-parent-match
 * @summary A script parent that C++ matches to the Blueprint asset by its marker value.
 * @topic Blueprint
 */
UCLASS()
class ATestBPImpactScriptParentMatch : AActor
{
	UPROPERTY()
	int Marker = 1;
}

/**
 * The sibling holding the zeroed marker, which C++ uses as the empty boundary. Its
 * UPROPERTY is part of the fixture and must be kept.
 *
 * @Covers Blueprint.ScriptParentMatch
 * @Inputs none
 * @Return an actor identical in shape but with Marker 0
 * @Boundary zeroed marker
 */
UCLASS()
class ATestBPImpactScriptParentMatchEmpty : AActor
{
	UPROPERTY()
	int Marker = 0;
}
/** @end */
