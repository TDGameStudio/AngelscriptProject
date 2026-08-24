// Theme: World.Component. WorldStory: SetWorldLocation/Rotation/Scale3D
// with explicit FHitResult&out sweep args.
// C++: AngelscriptCoverageSceneComponentTests.cpp::SceneComponentWorldTransform
// sha256=1f4b17ce264e595e4b1c1de6135b1387275be3ff2c042790b58ac7e2baea62bd; lines 91-130.
// Oracle NewLocation=(100,200,300), NewRotation=(0,90,0), NewScale=(2,2,2).
// Extra: local construct vectors/rotator default empty, Root null.
// FixtureIsolated.

UCLASS()
class ACoverageSceneComponentWorldTransformActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY()
	FVector InitialLocation;

	UPROPERTY()
	FVector NewLocation;

	UPROPERTY()
	FRotator NewRotation;

	UPROPERTY()
	FVector NewScale;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitialLocation = Root.GetWorldLocation();

		// Set world transform. SetWorldLocation/SetWorldRotation are reflective
		// K2_ binds with a required FHitResult&out sweep param (no AS defaults on
		// out params), so all four arguments must be supplied explicitly.
		FHitResult SweepHit;
		Root.SetWorldLocation(FVector(100.0f, 200.0f, 300.0f), false, SweepHit, false);
		Root.SetWorldRotation(FRotator(0.0f, 90.0f, 0.0f), false, SweepHit, false);
		Root.SetWorldScale3D(FVector(2.0f, 2.0f, 2.0f));

		// Read back
		NewLocation = Root.GetWorldLocation();
		NewRotation = Root.GetWorldRotation();
		// No direct world-scale getter is AS-bound; derive it from the world transform.
		NewScale = Root.GetComponentTransform().GetScale3D();
	}
}

bool Observe_WorldTransform_DefaultEmpty(ACoverageSceneComponentWorldTransformActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SceneComponentWorldTransform setup: required Actor is null");
	}
	return Actor.NewLocation.X == 0.0f
		&& Actor.NewLocation.Y == 0.0f
		&& Actor.NewLocation.Z == 0.0f
		&& Actor.NewRotation.Yaw == 0.0f
		&& Actor.NewScale.X == 0.0f
		&& Actor.Root == nullptr;
}

bool Observe_WorldTransform_CopyIndependence(ACoverageSceneComponentWorldTransformActor First, ACoverageSceneComponentWorldTransformActor Second)
{
	if (First is null)
	{
		throw("Test_SceneComponentWorldTransform setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SceneComponentWorldTransform setup: required Second is null");
	}
	First.NewLocation = FVector(100.0f, 200.0f, 300.0f);
	return First.NewLocation.X == 100.0f
		&& Second.NewLocation.X == 0.0f
		&& Second.NewScale.X == 0.0f;
}
