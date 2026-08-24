// Theme: Feature.Attach. WorldStory: KeepWorld / KeepRelative / SnapToTarget on scene components.
// C++: AngelscriptCoverageSceneComponentTests.cpp::SceneComponentAttachmentRules.
// Oracle after BeginPlay: KeepWorldLocation (50,50,0); KeepWorldRelativeLocation (-50,-50,0);
// KeepRelativeLocation (120,100,0); KeepRelativeRelativeLocation (20,0,0);
// SnapToTargetLocation (100,100,0); SnapToTargetRelativeLocation ZeroVector;
// attached/parent flags true; RootChildrenCount==3.
// Extra: CDO vectors zero / bools false / RootChildrenCount 0.
// FixtureIsolated. Keep the C++ UPROPERTY names.

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
}

bool Observe_AttachmentRules_CDODefaults(ACoverageSceneComponentAttachmentRulesActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SceneComponentAttachmentRules setup: required Actor is null");
	}
	return Actor.KeepWorldAttachedToRoot == false
		&& Actor.KeepRelativeAttachedToRoot == false
		&& Actor.SnapToTargetAttachedToRoot == false
		&& Actor.KeepWorldParentIsRoot == false
		&& Actor.KeepRelativeParentIsRoot == false
		&& Actor.SnapToTargetParentIsRoot == false
		&& Actor.RootChildrenCount == 0
		&& Actor.KeepWorldLocation.Equals(FVector::ZeroVector, 0.01f)
		&& Actor.SnapToTargetRelativeLocation.Equals(FVector::ZeroVector, 0.01f);
}

bool Observe_AttachmentRules_CopyIndependence(ACoverageSceneComponentAttachmentRulesActor Original, ACoverageSceneComponentAttachmentRulesActor Copy)
{
	if (Original is null)
	{
		throw("Test_SceneComponentAttachmentRules setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_SceneComponentAttachmentRules setup: required Copy is null");
	}
	Copy.RootChildrenCount = 3;
	Copy.KeepWorldAttachedToRoot = true;
	Copy.KeepWorldLocation = FVector(50.0f, 50.0f, 0.0f);
	return Original.RootChildrenCount == 0
		&& Original.KeepWorldAttachedToRoot == false
		&& Original.KeepWorldLocation.Equals(FVector::ZeroVector, 0.01f)
		&& Copy.RootChildrenCount == 3
		&& Copy.KeepWorldAttachedToRoot
		&& Copy.KeepWorldLocation.Equals(FVector(50.0f, 50.0f, 0.0f), 0.01f);
}
