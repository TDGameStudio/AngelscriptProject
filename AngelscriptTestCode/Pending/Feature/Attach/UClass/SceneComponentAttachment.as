/**
 * @version v1
 * @summary AttachToComponent / DetachFromComponent lifecycle. C++ reads InitiallyAttached, AfterAttach and AfterDetach after BeginPlay. The observers cover the CDO defaults and copy independence.
 * @topic Feature
 */
/**
 * @version root
 * @summary AttachToComponent / DetachFromComponent lifecycle. C++ reads InitiallyAttached, AfterAttach and AfterDetach after BeginPlay. The observers cover the CDO defaults and copy independence.
 * @topic Baseline
 */
UCLASS()
class ACoverageSceneComponentAttachmentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent)
	USceneComponent Detached;

	UPROPERTY()
	bool InitiallyAttached = true;

	UPROPERTY()
	bool AfterAttach = false;

	UPROPERTY()
	bool AfterDetach = true;

	/**
	 * WorldStory: BeginPlay detaches first so the initially-detached baseline is
	 * real, then attaches and detaches again, recording each IsAttachedTo result.
	 *
	 * @Kind WorldStory
	 * @Covers Attach.SceneComponentAttachment
	 * @Inputs Root and a default scene child that auto-attaches at construction
	 * @Return InitiallyAttached false, AfterAttach true, AfterDetach false
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// DefaultComponents auto-attach to the root component at construction, so
		// detach first to establish a real "initially detached" baseline.
		Detached.DetachFromComponent(EDetachmentRule::KeepWorld, EDetachmentRule::KeepWorld, EDetachmentRule::KeepWorld, false);

		InitiallyAttached = Detached.IsAttachedTo(Root);

		Detached.AttachToComponent(Root, NAME_None, EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, false);
		AfterAttach = Detached.IsAttachedTo(Root);

		// FDetachmentTransformRules has no AS-bound constructor; DetachFromComponent
		// takes the per-channel rules directly (Location, Rotation, Scale, bCallModify).
		Detached.DetachFromComponent(EDetachmentRule::KeepWorld, EDetachmentRule::KeepWorld, EDetachmentRule::KeepWorld, false);
		AfterDetach = Detached.IsAttachedTo(Root);
	}

	/**
	 * Observe that a locally constructed actor still holds the CDO flags.
	 *
	 * @Kind Observe
	 * @Covers Attach.SceneComponentAttachment
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when InitiallyAttached is true, AfterAttach is false and AfterDetach is true
	 * @Boundary CDO defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitiallyAttached != true)
		{
			return false;
		}
		if (AfterAttach)
		{
			return false;
		}
		return AfterDetach == true;
	}

	/**
	 * Observe that writing the second actor leaves this actor at its CDO flags.
	 *
	 * @Kind Observe
	 * @Covers Attach.SceneComponentAttachment
	 * @Inputs this actor plus a second actor
	 * @Return true when this stays at CDO flags and Second holds the written flags
	 * @Param Second the other actor, written then compared
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSceneComponentAttachmentActor Second)
	{
		if (Second is null)
		{
			throw("SceneComponentAttachment setup: required Second is null");
		}
		Second.InitiallyAttached = false;
		Second.AfterAttach = true;
		Second.AfterDetach = false;
		if (InitiallyAttached != true)
		{
			return false;
		}
		if (AfterAttach)
		{
			return false;
		}
		if (AfterDetach != true)
		{
			return false;
		}
		if (Second.InitiallyAttached)
		{
			return false;
		}
		if (!Second.AfterAttach)
		{
			return false;
		}
		return Second.AfterDetach == false;
	}
}
/** @end */
