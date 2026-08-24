// Theme: Feature.Attach. WorldStory: KeepWorld / KeepRelative / SnapToTarget attachment rules.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentSceneAttachmentRuleTransforms.
// CSV NegativeDiagnostic is wrong; C++ CompileScriptModule + spawn + ExpectBoolByPath / ReadStructByPath.
// Oracle after BeginPlay: KeepWorldAttached/KeepRelativeAttached/SnapAttached true;
// KeepWorldRelativeLocation (-75,-165,-255); KeepRelativeRelativeLocation (5,6,7);
// SnapRelativeLocation ZeroVector.
// Extra: CDO bools false / vectors zero. Keep the C++ UPROPERTY names.
// FixtureIsolated.

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
}

bool Observe_SceneAttachmentRules_CDODefaults(ACoverageComponentSceneAttachmentRulesActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComponentSceneAttachmentRuleTransforms setup: required Actor is null");
	}
	return Actor.KeepWorldAttached == false
		&& Actor.KeepRelativeAttached == false
		&& Actor.SnapAttached == false
		&& Actor.KeepWorldRelativeLocation.Equals(FVector::ZeroVector, 0.01f)
		&& Actor.KeepRelativeRelativeLocation.Equals(FVector::ZeroVector, 0.01f)
		&& Actor.SnapRelativeLocation.Equals(FVector::ZeroVector, 0.01f);
}

bool Observe_SceneAttachmentRules_CopyIndependence(ACoverageComponentSceneAttachmentRulesActor Original, ACoverageComponentSceneAttachmentRulesActor Copy)
{
	if (Original is null)
	{
		throw("Test_ComponentSceneAttachmentRuleTransforms setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_ComponentSceneAttachmentRuleTransforms setup: required Copy is null");
	}
	Copy.KeepWorldAttached = true;
	Copy.KeepWorldRelativeLocation = FVector(1.0f, 2.0f, 3.0f);
	return Original.KeepWorldAttached == false
		&& Original.KeepWorldRelativeLocation.Equals(FVector::ZeroVector, 0.01f)
		&& Copy.KeepWorldAttached
		&& Copy.KeepWorldRelativeLocation.Equals(FVector(1.0f, 2.0f, 3.0f), 0.01f);
}
