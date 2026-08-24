// Theme: World.Component. WorldStory: CameraComp.FieldOfView write/read.
// C++: AngelscriptCoverageSpecialComponentTests.cpp::CameraComponent
// sha256=99c54353731e267c5f1e5085fe5f07663c3d33c84a2ac6e41bd4cdcc6eb7e5b9; lines 247-280.
// Oracle NewFOV=120, FieldOfViewSet true. Extra: local construct FOV 0,
// FieldOfViewSet false, CameraComp null. FixtureIsolated.

UCLASS()
class ACoverageSpecialCameraActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCameraComponent CameraComp;

	UPROPERTY()
	float InitialFOV = 0.0f;

	UPROPERTY()
	float NewFOV = 0.0f;

	UPROPERTY()
	bool FieldOfViewSet = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (CameraComp != nullptr)
		{
			InitialFOV = CameraComp.FieldOfView;

			CameraComp.FieldOfView = 120.0f;

			NewFOV = CameraComp.FieldOfView;
			FieldOfViewSet = NewFOV > 119.0f;
		}
	}
}

bool Observe_CameraComponent_DefaultEmpty(ACoverageSpecialCameraActor Actor)
{
	if (Actor is null)
	{
		throw("Test_CameraComponent setup: required Actor is null");
	}
	return Actor.InitialFOV == 0.0f
		&& Actor.NewFOV == 0.0f
		&& !Actor.FieldOfViewSet
		&& Actor.CameraComp == nullptr
		&& Actor.Root == nullptr;
}

bool Observe_CameraComponent_CopyIndependence(ACoverageSpecialCameraActor First, ACoverageSpecialCameraActor Second)
{
	if (First is null)
	{
		throw("Test_CameraComponent setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_CameraComponent setup: required Second is null");
	}
	First.NewFOV = 120.0f;
	First.FieldOfViewSet = true;
	return First.NewFOV == 120.0f
		&& First.FieldOfViewSet
		&& Second.NewFOV == 0.0f
		&& !Second.FieldOfViewSet;
}
