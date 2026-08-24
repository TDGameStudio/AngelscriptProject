// Theme: World.Component. WorldStory: IsActive / Deactivate / Activate.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentActivation
// sha256=e527a3970eed44aedf06c8cf4751c52568df57668837e641e664234bbda823d5; lines 1777-1810.
// Oracle after spawn+BeginPlay VerifyByPath: InitiallyActive=false,
// AfterDeactivate=false, AfterReactivate=true. Extra: local construct keeps
// declared defaults (AfterDeactivate starts true). FixtureIsolated.

UCLASS()
class UCoverageActivationComponent : UActorComponent
{
}

UCLASS()
class ACoverageComponentActivationActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageActivationComponent TestComp;

	UPROPERTY()
	bool InitiallyActive = false;

	UPROPERTY()
	bool AfterDeactivate = true;

	UPROPERTY()
	bool AfterReactivate = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitiallyActive = TestComp.IsActive();

		TestComp.Deactivate();
		AfterDeactivate = TestComp.IsActive();

		TestComp.Activate(true);
		AfterReactivate = TestComp.IsActive();
	}
}

bool Observe_ComponentActivation_DefaultEmpty(ACoverageComponentActivationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComponentActivation setup: required Actor is null");
	}
	return !Actor.InitiallyActive
		&& Actor.AfterDeactivate
		&& !Actor.AfterReactivate
		&& Actor.TestComp == nullptr;
}

bool Observe_ComponentActivation_CopyIndependence(ACoverageComponentActivationActor First, ACoverageComponentActivationActor Second)
{
	if (First is null)
	{
		throw("Test_ComponentActivation setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ComponentActivation setup: required Second is null");
	}
	First.AfterReactivate = true;
	First.AfterDeactivate = false;
	return First.AfterReactivate
		&& !First.AfterDeactivate
		&& !Second.AfterReactivate
		&& Second.AfterDeactivate;
}
