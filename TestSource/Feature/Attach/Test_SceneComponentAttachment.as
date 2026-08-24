// Theme: Feature.Attach. WorldStory: AttachToComponent / DetachFromComponent lifecycle.
// C++: AngelscriptCoverageSceneComponentTests.cpp::SceneComponentAttachment.
// Oracle after BeginPlay: InitiallyAttached==false; AfterAttach==true; AfterDetach==false.
// Extra: CDO InitiallyAttached true / AfterAttach false / AfterDetach true; copy independence.
// FixtureIsolated. Keep UPROPERTY names InitiallyAttached, AfterAttach, AfterDetach.

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
}

bool Observe_SceneAttachment_CDODefaults(ACoverageSceneComponentAttachmentActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SceneComponentAttachment setup: required Actor is null");
	}
	return Actor.InitiallyAttached == true
		&& Actor.AfterAttach == false
		&& Actor.AfterDetach == true;
}

bool Observe_SceneAttachment_CopyIndependence(ACoverageSceneComponentAttachmentActor Original, ACoverageSceneComponentAttachmentActor Copy)
{
	if (Original is null)
	{
		throw("Test_SceneComponentAttachment setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_SceneComponentAttachment setup: required Copy is null");
	}
	Copy.InitiallyAttached = false;
	Copy.AfterAttach = true;
	Copy.AfterDetach = false;
	return Original.InitiallyAttached == true
		&& Original.AfterAttach == false
		&& Original.AfterDetach == true
		&& Copy.InitiallyAttached == false
		&& Copy.AfterAttach
		&& Copy.AfterDetach == false;
}
