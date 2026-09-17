/**
 * @version v1
 * @summary KeepWorld / KeepRelative / SnapToTarget attachment rules on scene components. C++ compiles, spawns, and reads the attached flags and relative locations after BeginPlay. The observers cover the CDO defaults and copy.
 * @topic Feature
 */
/**
 * @version root
 * @summary KeepWorld / KeepRelative / SnapToTarget attachment rules on scene components. C++ compiles, spawns, and reads the attached flags and relative locations after BeginPlay. The observers cover the CDO defaults and copy.
 * @topic Baseline
 */
UCLASS()
class ACoverageComponentSceneAttachmentRulesActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent)
	USceneComponent KeepWorldChild;

	UPROPERTY(DefaultComponent)
	USceneComponent KeepRelativeChild;

	UPROPERTY(DefaultComponent)
	USceneComponent SnapChild;

	UPROPERTY()
	bool KeepWorldAttached = false;

	UPROPERTY()
	bool KeepRelativeAttached = false;

	UPROPERTY()
	bool SnapAttached = false;

	UPROPERTY()
	FVector KeepWorldRelativeLocation;

	UPROPERTY()
	FVector KeepRelativeRelativeLocation;

	UPROPERTY()
	FVector SnapRelativeLocation;

	/**
	 * WorldStory: BeginPlay detaches each child, sets a known location, then
	 * reattaches with KeepWorld, KeepRelative, or SnapToTarget.
	 *
	 * @Kind WorldStory
	 * @Covers Attach.ComponentSceneAttachmentRuleTransforms
	 * @Inputs Root at (100,200,300) and three default scene children
	 * @Return KeepWorldAttached/KeepRelativeAttached/SnapAttached true; relative locations as the C++ oracle
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Root.SetRelativeLocation(FVector(100.0f, 200.0f, 300.0f));

		KeepWorldChild.DetachFromComponent(
			EDetachmentRule::KeepRelative, EDetachmentRule::KeepRelative, EDetachmentRule::KeepRelative, false);
		KeepWorldChild.SetRelativeLocation(FVector(25.0f, 35.0f, 45.0f));
		KeepWorldChild.AttachToComponent(Root, NAME_None,
			EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, EAttachmentRule::KeepWorld, false);
		KeepWorldAttached = KeepWorldChild.IsAttachedTo(Root);
		KeepWorldRelativeLocation = KeepWorldChild.RelativeLocation;

		KeepRelativeChild.DetachFromComponent(
			EDetachmentRule::KeepRelative, EDetachmentRule::KeepRelative, EDetachmentRule::KeepRelative, false);
		KeepRelativeChild.SetRelativeLocation(FVector(5.0f, 6.0f, 7.0f));
		KeepRelativeChild.AttachToComponent(Root, NAME_None,
			EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, false);
		KeepRelativeAttached = KeepRelativeChild.IsAttachedTo(Root);
		KeepRelativeRelativeLocation = KeepRelativeChild.RelativeLocation;

		SnapChild.DetachFromComponent(
			EDetachmentRule::KeepRelative, EDetachmentRule::KeepRelative, EDetachmentRule::KeepRelative, false);
		SnapChild.SetRelativeLocation(FVector(400.0f, 500.0f, 600.0f));
		SnapChild.AttachToComponent(Root, NAME_None,
			EAttachmentRule::SnapToTarget, EAttachmentRule::SnapToTarget, EAttachmentRule::SnapToTarget, false);
		SnapAttached = SnapChild.IsAttachedTo(Root);
		SnapRelativeLocation = SnapChild.RelativeLocation;
	}

	/**
	 * Observe that a locally constructed actor still holds the CDO flags and zero vectors.
	 *
	 * @Kind Observe
	 * @Covers Attach.ComponentSceneAttachmentRuleTransforms
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all three attached flags are false and all three relative locations are zero
	 * @Boundary CDO defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (KeepWorldAttached)
		{
			return false;
		}
		if (KeepRelativeAttached)
		{
			return false;
		}
		if (SnapAttached)
		{
			return false;
		}
		if (!KeepWorldRelativeLocation.Equals(FVector::ZeroVector, 0.01f))
		{
			return false;
		}
		if (!KeepRelativeRelativeLocation.Equals(FVector::ZeroVector, 0.01f))
		{
			return false;
		}
		return SnapRelativeLocation.Equals(FVector::ZeroVector, 0.01f);
	}

	/**
	 * Observe that writing the second actor leaves this actor at its CDO values.
	 *
	 * @Kind Observe
	 * @Covers Attach.ComponentSceneAttachmentRuleTransforms
	 * @Inputs this actor plus a second actor
	 * @Return true when this stays at CDO values and Second holds the written KeepWorld state
	 * @Param Second the other actor, written then compared
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentSceneAttachmentRulesActor Second)
	{
		if (Second is null)
		{
			throw("ComponentSceneAttachmentRuleTransforms setup: required Second is null");
		}
		Second.KeepWorldAttached = true;
		Second.KeepWorldRelativeLocation = FVector(1.0f, 2.0f, 3.0f);
		if (KeepWorldAttached)
		{
			return false;
		}
		if (!KeepWorldRelativeLocation.Equals(FVector::ZeroVector, 0.01f))
		{
			return false;
		}
		if (!Second.KeepWorldAttached)
		{
			return false;
		}
		return Second.KeepWorldRelativeLocation.Equals(FVector(1.0f, 2.0f, 3.0f), 0.01f);
	}
}
/** @end */
