// Theme: World.Component. WorldStory: TargetArmLength and CameraLagSpeed.
// C++: AngelscriptCoverageSpecialComponentTests.cpp::SpringArmComponent
// sha256=22442d3ce978d416b7355bf496ca0af1252d385a65c30bfc3fa761321b7891ee; lines 325-359.
// Oracle NewArmLength=500, CameraLagSpeed=8. Extra: local construct zeros,
// SpringArmComp null. FixtureIsolated.

UCLASS()
class ACoverageSpecialSpringArmActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USpringArmComponent SpringArmComp;

	UPROPERTY()
	float InitialArmLength = 0.0f;

	UPROPERTY()
	float NewArmLength = 0.0f;

	UPROPERTY()
	float CameraLagSpeed = 0.0f;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (SpringArmComp != nullptr)
		{
			InitialArmLength = SpringArmComp.TargetArmLength;

			SpringArmComp.TargetArmLength = 500.0f;
			SpringArmComp.CameraLagSpeed = 8.0f;

			NewArmLength = SpringArmComp.TargetArmLength;
			CameraLagSpeed = SpringArmComp.CameraLagSpeed;
		}
	}
}

bool Observe_SpringArm_DefaultEmpty(ACoverageSpecialSpringArmActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SpringArmComponent setup: required Actor is null");
	}
	return Actor.InitialArmLength == 0.0f
		&& Actor.NewArmLength == 0.0f
		&& Actor.CameraLagSpeed == 0.0f
		&& Actor.SpringArmComp == nullptr
		&& Actor.Root == nullptr;
}

bool Observe_SpringArm_CopyIndependence(ACoverageSpecialSpringArmActor First, ACoverageSpecialSpringArmActor Second)
{
	if (First is null)
	{
		throw("Test_SpringArmComponent setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SpringArmComponent setup: required Second is null");
	}
	First.NewArmLength = 500.0f;
	First.CameraLagSpeed = 8.0f;
	return First.NewArmLength == 500.0f
		&& First.CameraLagSpeed == 8.0f
		&& Second.NewArmLength == 0.0f
		&& Second.CameraLagSpeed == 0.0f;
}
