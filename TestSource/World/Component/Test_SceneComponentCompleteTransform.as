// Theme: World.Component. WorldStory: SetWorldTransform then GetComponentTransform.
// C++: AngelscriptCoverageSceneComponentTests.cpp::SceneComponentCompleteTransform
// sha256=57f9b8ef855bfa4d577147d6dbd920d647c9b9704252a605702241db99232aa4; lines 825-862.
// Oracle FinalLocation=(100,200,300), FinalRotation~(10,20,30), FinalScale=(1.5,1.5,1.5).
// Extra: local construct zeros, Root null. FixtureIsolated.

UCLASS()
class ACoverageSceneComponentCompleteTransformActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY()
	FVector FinalLocation;

	UPROPERTY()
	FRotator FinalRotation;

	UPROPERTY()
	FVector FinalScale;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create and set a complete transform
		FTransform NewTransform;
		NewTransform.SetLocation(FVector(100.0f, 200.0f, 300.0f));
		NewTransform.SetRotation(FQuat(FRotator(10.0f, 20.0f, 30.0f)));
		NewTransform.SetScale3D(FVector(1.5f, 1.5f, 1.5f));

		// SetWorldTransform is a reflective K2_ bind requiring the sweep/teleport
		// arguments (FHitResult&out has no AS default).
		FHitResult SweepHit;
		Root.SetWorldTransform(NewTransform, false, SweepHit, false);

		// Read back using GetComponentTransform
		FTransform CurrentTransform = Root.GetComponentTransform();
		FinalLocation = CurrentTransform.GetLocation();
		FinalRotation = CurrentTransform.GetRotation().Rotator();
		FinalScale = CurrentTransform.GetScale3D();
	}
}

bool Observe_CompleteTransform_DefaultEmpty(ACoverageSceneComponentCompleteTransformActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SceneComponentCompleteTransform setup: required Actor is null");
	}
	return Actor.FinalLocation.X == 0.0f
		&& Actor.FinalRotation.Pitch == 0.0f
		&& Actor.FinalScale.X == 0.0f
		&& Actor.Root == nullptr;
}

bool Observe_CompleteTransform_CopyIndependence(ACoverageSceneComponentCompleteTransformActor First, ACoverageSceneComponentCompleteTransformActor Second)
{
	if (First is null)
	{
		throw("Test_SceneComponentCompleteTransform setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SceneComponentCompleteTransform setup: required Second is null");
	}
	First.FinalLocation = FVector(100.0f, 200.0f, 300.0f);
	First.FinalScale = FVector(1.5f, 1.5f, 1.5f);
	return First.FinalLocation.X == 100.0f
		&& First.FinalScale.X == 1.5f
		&& Second.FinalLocation.X == 0.0f
		&& Second.FinalScale.X == 0.0f;
}
