// Theme: World.Component. WorldStory: SetCapsuleSize radius/half-height.
// C++: AngelscriptCoverageSpecialComponentTests.cpp::CapsuleComponent
// sha256=e73f0b493b42b55d202c5e8ad691be552e41e655dd3df3aef678ab0cb880b775; lines 538-569.
// Oracle NewRadius=50, NewHalfHeight=100. Extra: local construct zeros,
// CapsuleComp null. FixtureIsolated.

UCLASS()
class ACoverageSpecialCapsuleActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCapsuleComponent CapsuleComp;

	UPROPERTY()
	float InitialRadius = 0.0f;

	UPROPERTY()
	float InitialHalfHeight = 0.0f;

	UPROPERTY()
	float NewRadius = 0.0f;

	UPROPERTY()
	float NewHalfHeight = 0.0f;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitialRadius = CapsuleComp.GetUnscaledCapsuleRadius();
		InitialHalfHeight = CapsuleComp.GetUnscaledCapsuleHalfHeight();

		CapsuleComp.SetCapsuleSize(50.0f, 100.0f);

		NewRadius = CapsuleComp.GetUnscaledCapsuleRadius();
		NewHalfHeight = CapsuleComp.GetUnscaledCapsuleHalfHeight();
	}
}

bool Observe_CapsuleComponent_DefaultEmpty(ACoverageSpecialCapsuleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_CapsuleComponent setup: required Actor is null");
	}
	return Actor.InitialRadius == 0.0f
		&& Actor.InitialHalfHeight == 0.0f
		&& Actor.NewRadius == 0.0f
		&& Actor.NewHalfHeight == 0.0f
		&& Actor.CapsuleComp == nullptr;
}

bool Observe_CapsuleComponent_CopyIndependence(ACoverageSpecialCapsuleActor First, ACoverageSpecialCapsuleActor Second)
{
	if (First is null)
	{
		throw("Test_CapsuleComponent setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_CapsuleComponent setup: required Second is null");
	}
	First.NewRadius = 50.0f;
	First.NewHalfHeight = 100.0f;
	return First.NewRadius == 50.0f
		&& First.NewHalfHeight == 100.0f
		&& Second.NewRadius == 0.0f
		&& Second.NewHalfHeight == 0.0f;
}
