// Theme: World.Component. WorldStory: SetSphereRadius / GetUnscaledSphereRadius.
// C++: AngelscriptCoverageSpecialComponentTests.cpp::SphereComponent
// sha256=53a5257362a08efedf9bb9c9933937f48990c23e29ab538c79efebb5bd82d49e; lines 472-495.
// Oracle NewRadius=150. Extra: local construct Initial/NewRadius 0, SphereComp null.
// FixtureIsolated.

UCLASS()
class ACoverageSpecialSphereActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	float InitialRadius = 0.0f;

	UPROPERTY()
	float NewRadius = 0.0f;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitialRadius = SphereComp.GetUnscaledSphereRadius();

		SphereComp.SetSphereRadius(150.0f);

		NewRadius = SphereComp.GetUnscaledSphereRadius();
	}
}

bool Observe_SphereComponent_DefaultEmpty(ACoverageSpecialSphereActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SphereComponent setup: required Actor is null");
	}
	return Actor.InitialRadius == 0.0f
		&& Actor.NewRadius == 0.0f
		&& Actor.SphereComp == nullptr;
}

bool Observe_SphereComponent_CopyIndependence(ACoverageSpecialSphereActor First, ACoverageSpecialSphereActor Second)
{
	if (First is null)
	{
		throw("Test_SphereComponent setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SphereComponent setup: required Second is null");
	}
	First.NewRadius = 150.0f;
	return First.NewRadius == 150.0f && Second.NewRadius == 0.0f;
}
