/**
 * Tick prerequisites added and removed against both a component and an actor,
 * alongside the starting tick-enabled state. C++ verifies the four flags and then
 * sets the interval and tick group itself. The observers cover the local-construct
 * default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.TickConfigurationAndPrerequisites
 * @Harness UClass
 * @Tag World.Component.ComponentTickConfigurationAndPrerequisites
 * @Provenance Theme: World.Component. WorldStory: script component Tick override plus
 * @Provenance Add/RemoveTickPrerequisiteComponent and AddTickPrerequisiteActor.
 * @Provenance C++: AngelscriptCoverageComponentTests.cpp::ComponentTickConfigurationAndPrerequisites
 * @Provenance sha256=4f4b183160ea31d2618da27f58521cc2dec69e1ea883a62b440b0117c08dd85e; lines 1662-1717.
 * @Provenance Oracle after spawn+BeginPlay: StartTickEnabled, ComponentPrereqAdded,
 * @Provenance ActorPrereqAdded, ComponentPrereqRemoved all true. C++ then sets
 * @Provenance TickComp interval 0.5 and TG_PrePhysics. Extra: local construct leaves
 * @Provenance those bools false and TickCount 0. FixtureIsolated.
 */

UCLASS()
class UCoverageTickConfigComponent : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	/**
	 * Count every tick the component receives.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TickConfigurationAndPrerequisites
	 * @Inputs the frame delta, unused
	 * @Return TickCount incremented once per tick
	 * @Param DeltaTime the frame delta
	 */
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

	/**
	 * WorldStory: BeginPlay records the starting tick state, adds a component and an
	 * actor prerequisite, then removes the component prerequisite again.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TickConfigurationAndPrerequisites
	 * @Inputs two default components
	 * @Return all four flags true
	 */
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

	/**
	 * Observe that a locally constructed actor has no flags and no components.
	 *
	 * @Kind Observe
	 * @Covers Component.TickConfigurationAndPrerequisites
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all flags are clear and both components are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (StartTickEnabled)
		{
			return false;
		}
		if (ComponentPrereqAdded)
		{
			return false;
		}
		if (ActorPrereqAdded)
		{
			return false;
		}
		if (ComponentPrereqRemoved)
		{
			return false;
		}
		if (TickComp != nullptr)
		{
			return false;
		}
		return DisabledComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.TickConfigurationAndPrerequisites
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the flags and the other stays clear
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentTickConfigurationActor Second)
	{
		if (Second is null)
		{
			throw("ComponentTickConfigurationAndPrerequisites setup: required Second is null");
		}
		StartTickEnabled = true;
		ComponentPrereqAdded = true;

		if (!StartTickEnabled)
		{
			return false;
		}
		if (!ComponentPrereqAdded)
		{
			return false;
		}
		if (Second.StartTickEnabled)
		{
			return false;
		}
		return !Second.ComponentPrereqAdded;
	}
}
