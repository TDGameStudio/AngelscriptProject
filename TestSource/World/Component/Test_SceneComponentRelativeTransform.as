// Theme: World.Component. WorldStory: child relative location/rotation vs world.
// C++: AngelscriptCoverageSceneComponentTests.cpp::SceneComponentRelativeTransform
// sha256=74d4dded843c76a3816b7493bf578280604fa076d2f3780e79aa95009156b326; lines 181-217.
// Oracle ChildRelativeLocation=(50,0,0), ChildRelativeRotation yaw 45,
// ChildWorldLocation=(150,0,0). Extra: local construct zeros, Root/Child null.
// FixtureIsolated.

UCLASS()
class ACoverageSceneComponentRelativeTransformActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child;

	UPROPERTY()
	FVector ChildRelativeLocation;

	UPROPERTY()
	FRotator ChildRelativeRotation;

	UPROPERTY()
	FVector ChildWorldLocation;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Set root to known position
		FHitResult SweepHit;
		Root.SetWorldLocation(FVector(100.0f, 0.0f, 0.0f), false, SweepHit, false);

		// Set child relative transform
		Child.SetRelativeLocation(FVector(50.0f, 0.0f, 0.0f));
		Child.SetRelativeRotation(FRotator(0.0f, 45.0f, 0.0f));

		// Read back
		ChildRelativeLocation = Child.RelativeLocation;
		ChildRelativeRotation = Child.RelativeRotation;
		ChildWorldLocation = Child.GetWorldLocation();
	}
}

bool Observe_RelativeTransform_DefaultEmpty(ACoverageSceneComponentRelativeTransformActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SceneComponentRelativeTransform setup: required Actor is null");
	}
	return Actor.ChildRelativeLocation.X == 0.0f
		&& Actor.ChildRelativeRotation.Yaw == 0.0f
		&& Actor.ChildWorldLocation.X == 0.0f
		&& Actor.Root == nullptr
		&& Actor.Child == nullptr;
}

bool Observe_RelativeTransform_CopyIndependence(ACoverageSceneComponentRelativeTransformActor First, ACoverageSceneComponentRelativeTransformActor Second)
{
	if (First is null)
	{
		throw("Test_SceneComponentRelativeTransform setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SceneComponentRelativeTransform setup: required Second is null");
	}
	First.ChildRelativeLocation = FVector(50.0f, 0.0f, 0.0f);
	return First.ChildRelativeLocation.X == 50.0f && Second.ChildRelativeLocation.X == 0.0f;
}
