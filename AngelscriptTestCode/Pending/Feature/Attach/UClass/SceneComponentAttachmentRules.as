/**
 * @version v1
 * @summary KeepWorld / KeepRelative / SnapToTarget on scene components. C++ reads the world and relative locations, attached/parent flags and RootChildrenCount after BeginPlay. The observers cover the CDO defaults and copy.
 * @topic Feature
 */
/**
 * @version root
 * @summary KeepWorld / KeepRelative / SnapToTarget on scene components. C++ reads the world and relative locations, attached/parent flags and RootChildrenCount after BeginPlay. The observers cover the CDO defaults and copy.
 * @topic Baseline
 */
UCLASS()
class ACoverageSceneComponentAttachmentRulesActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent)
	USceneComponent TestComp1;

	UPROPERTY(DefaultComponent)
	USceneComponent TestComp2;

	UPROPERTY(DefaultComponent)
	USceneComponent TestComp3;

	UPROPERTY()
	FVector KeepWorldLocation;

	UPROPERTY()
	FVector KeepWorldRelativeLocation;

	UPROPERTY()
	FVector KeepRelativeLocation;

	UPROPERTY()
	FVector KeepRelativeRelativeLocation;

	UPROPERTY()
	FVector SnapToTargetLocation;

	UPROPERTY()
	FVector SnapToTargetRelativeLocation;

	UPROPERTY()
	bool KeepWorldAttachedToRoot = false;

	UPROPERTY()
	bool KeepRelativeAttachedToRoot = false;

	UPROPERTY()
	bool SnapToTargetAttachedToRoot = false;

	UPROPERTY()
	bool KeepWorldParentIsRoot = false;

	UPROPERTY()
	bool KeepRelativeParentIsRoot = false;

	UPROPERTY()
	bool SnapToTargetParentIsRoot = false;

	UPROPERTY()
	int RootChildrenCount = 0;

	/**
	 * WorldStory: BeginPlay places Root, then attaches TestComp1 KeepWorld,
	 * TestComp2 KeepRelative and TestComp3 SnapToTarget after a KeepWorld detach.
	 *
	 * @Kind WorldStory
	 * @Covers Attach.SceneComponentAttachmentRules
	 * @Inputs Root at (100,100,0) and three default scene children
	 * @Return locations, attached/parent flags and RootChildrenCount as the C++ oracle
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FHitResult SweepHit;
		Root.SetWorldLocation(FVector(100.0f, 100.0f, 0.0f), false, SweepHit, false);

		TestComp1.SetWorldLocation(FVector(50.0f, 50.0f, 0.0f), false, SweepHit, false);
		TestComp1.AttachToComponent(Root, NAME_None, EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, false);
		KeepWorldLocation = TestComp1.GetWorldLocation();
		KeepWorldRelativeLocation = TestComp1.RelativeLocation;
		KeepWorldAttachedToRoot = TestComp1.IsAttachedTo(Root);
		KeepWorldParentIsRoot = TestComp1.GetAttachParent() == Root;

		TestComp2.SetRelativeLocation(FVector(20.0f, 0.0f, 0.0f));
		TestComp2.AttachToComponent(Root, NAME_None, EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, false);
		KeepRelativeLocation = TestComp2.GetWorldLocation();
		KeepRelativeRelativeLocation = TestComp2.RelativeLocation;
		KeepRelativeAttachedToRoot = TestComp2.IsAttachedTo(Root);
		KeepRelativeParentIsRoot = TestComp2.GetAttachParent() == Root;

		// SnapToTarget rule: snaps to parent. TestComp3 is a DefaultComponent already
		// attached to Root, and AttachToComponent on an already-attached component with
		// the same parent/socket is a no-op in UE (the new rules are not re-applied).
		// Detach first (keeping world position) so the SnapToTarget rule genuinely runs.
		TestComp3.SetWorldLocation(FVector(200.0f, 200.0f, 0.0f), false, SweepHit, false);
		TestComp3.DetachFromComponent(EDetachmentRule::KeepWorld, EDetachmentRule::KeepWorld, EDetachmentRule::KeepWorld, false);
		TestComp3.AttachToComponent(Root, NAME_None, EAttachmentRule::SnapToTarget, EAttachmentRule::SnapToTarget, EAttachmentRule::SnapToTarget, false);
		SnapToTargetLocation = TestComp3.GetWorldLocation();
		SnapToTargetRelativeLocation = TestComp3.RelativeLocation;
		SnapToTargetAttachedToRoot = TestComp3.IsAttachedTo(Root);
		SnapToTargetParentIsRoot = TestComp3.GetAttachParent() == Root;

		// GetAttachChildren has no direct AS getter; GetChildrenComponents fills an
		// out array (bIncludeAllDescendants, Children&out).
		TArray<USceneComponent> RootChildren;
		Root.GetChildrenComponents(false, RootChildren);
		RootChildrenCount = RootChildren.Num();
	}

	/**
	 * Observe that a locally constructed actor still holds the CDO flags, zero
	 * count and zero vectors.
	 *
	 * @Kind Observe
	 * @Covers Attach.SceneComponentAttachmentRules
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all six flags are false, RootChildrenCount is 0 and the sampled vectors are zero
	 * @Boundary CDO defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (KeepWorldAttachedToRoot)
		{
			return false;
		}
		if (KeepRelativeAttachedToRoot)
		{
			return false;
		}
		if (SnapToTargetAttachedToRoot)
		{
			return false;
		}
		if (KeepWorldParentIsRoot)
		{
			return false;
		}
		if (KeepRelativeParentIsRoot)
		{
			return false;
		}
		if (SnapToTargetParentIsRoot)
		{
			return false;
		}
		if (RootChildrenCount != 0)
		{
			return false;
		}
		if (!KeepWorldLocation.Equals(FVector::ZeroVector, 0.01f))
		{
			return false;
		}
		return SnapToTargetRelativeLocation.Equals(FVector::ZeroVector, 0.01f);
	}

	/**
	 * Observe that writing the second actor leaves this actor at its CDO values.
	 *
	 * @Kind Observe
	 * @Covers Attach.SceneComponentAttachmentRules
	 * @Inputs this actor plus a second actor
	 * @Return true when this stays at CDO values and Second holds the written KeepWorld state
	 * @Param Second the other actor, written then compared
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSceneComponentAttachmentRulesActor Second)
	{
		if (Second is null)
		{
			throw("SceneComponentAttachmentRules setup: required Second is null");
		}
		Second.RootChildrenCount = 3;
		Second.KeepWorldAttachedToRoot = true;
		Second.KeepWorldLocation = FVector(50.0f, 50.0f, 0.0f);
		if (RootChildrenCount != 0)
		{
			return false;
		}
		if (KeepWorldAttachedToRoot)
		{
			return false;
		}
		if (!KeepWorldLocation.Equals(FVector::ZeroVector, 0.01f))
		{
			return false;
		}
		if (Second.RootChildrenCount != 3)
		{
			return false;
		}
		if (!Second.KeepWorldAttachedToRoot)
		{
			return false;
		}
		return Second.KeepWorldLocation.Equals(FVector(50.0f, 50.0f, 0.0f), 0.01f);
	}
}
/** @end */
