// Theme: World.Component. WorldStory: script component Tick override plus
// Add/RemoveTickPrerequisiteComponent and AddTickPrerequisiteActor.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentTickConfigurationAndPrerequisites
// sha256=4f4b183160ea31d2618da27f58521cc2dec69e1ea883a62b440b0117c08dd85e; lines 1662-1717.
// Oracle after spawn+BeginPlay: StartTickEnabled, ComponentPrereqAdded,
// ActorPrereqAdded, ComponentPrereqRemoved all true. C++ then sets
// TickComp interval 0.5 and TG_PrePhysics. Extra: local construct leaves
// those bools false and TickCount 0. FixtureIsolated.

UCLASS()
class UCoverageTickConfigComponent : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount++;
	}
}

UCLASS()
class UCoverageTickDisabledComponent : UActorComponent
{
}

UCLASS()
class ACoverageComponentTickConfigurationActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageTickConfigComponent TickComp;

	UPROPERTY(DefaultComponent)
	UCoverageTickDisabledComponent DisabledComp;

	UPROPERTY()
	bool StartTickEnabled = false;

	UPROPERTY()
	bool ComponentPrereqAdded = false;

	UPROPERTY()
	bool ActorPrereqAdded = false;

	UPROPERTY()
	bool ComponentPrereqRemoved = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StartTickEnabled = TickComp.IsComponentTickEnabled();

		TickComp.AddTickPrerequisiteComponent(DisabledComp);
		ComponentPrereqAdded = true;

		TickComp.AddTickPrerequisiteActor(this);
		ActorPrereqAdded = true;

		TickComp.RemoveTickPrerequisiteComponent(DisabledComp);
		ComponentPrereqRemoved = true;
	}
}

bool Observe_TickConfig_DefaultFalse(ACoverageComponentTickConfigurationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComponentTickConfigurationAndPrerequisites setup: required Actor is null");
	}
	return !Actor.StartTickEnabled
		&& !Actor.ComponentPrereqAdded
		&& !Actor.ActorPrereqAdded
		&& !Actor.ComponentPrereqRemoved
		&& Actor.TickComp == nullptr
		&& Actor.DisabledComp == nullptr;
}

bool Observe_TickConfig_CopyIndependence(ACoverageComponentTickConfigurationActor First, ACoverageComponentTickConfigurationActor Second)
{
	if (First is null)
	{
		throw("Test_ComponentTickConfigurationAndPrerequisites setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ComponentTickConfigurationAndPrerequisites setup: required Second is null");
	}
	First.StartTickEnabled = true;
	First.ComponentPrereqAdded = true;
	return First.StartTickEnabled
		&& First.ComponentPrereqAdded
		&& !Second.StartTickEnabled
		&& !Second.ComponentPrereqAdded;
}
