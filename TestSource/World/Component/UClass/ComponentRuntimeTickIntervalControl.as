/**
 * Component tick interval and enable state driven at runtime. C++ verifies the
 * flags and the three intervals. The observers cover the local-construct default
 * and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.RuntimeTickIntervalControl
 * @Harness UClass
 * @Tag World.Component.ComponentRuntimeTickIntervalControl
 * @Provenance Theme: World.Component. WorldStory: SetComponentTickInterval / Enabled
 * @Provenance and DisableRuntimeTick.
 * @Provenance C++: AngelscriptCoverageComponentTests.cpp::ComponentRuntimeTickIntervalControl
 * @Provenance sha256=209acb16aff8dad3c98c48c1c8c1d56822b72dfcce6addb9ec5ba6ffaea4972e; lines 2542-2603.
 * @Provenance Oracle: InitiallyDisabled=false, EnabledAfterToggle=true, InitialInterval
 * @Provenance ~0.125 then 0.25 then 0.05. Extra: local construct intervals 0, flags false,
 * @Provenance TickComp null. FixtureIsolated.
 */

UCLASS()
class UCoverageRuntimeTickIntervalComponent : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	/**
	 * Count every tick the component receives.
	 *
	 * @Kind WorldStory
	 * @Covers Component.RuntimeTickIntervalControl
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
class ACoverageComponentRuntimeTickIntervalActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageRuntimeTickIntervalComponent TickComp;

	UPROPERTY()
	bool InitiallyDisabled = false;

	UPROPERTY()
	bool EnabledAfterToggle = false;

	UPROPERTY()
	bool DisabledAfterToggle = false;

	UPROPERTY()
	float InitialInterval = 0.0f;

	UPROPERTY()
	float UpdatedInterval = 0.0f;

	UPROPERTY()
	float SecondUpdatedInterval = 0.0f;

	/**
	 * WorldStory: BeginPlay reads the starting state, moves the interval twice, then
	 * re-enables ticking.
	 *
	 * @Kind WorldStory
	 * @Covers Component.RuntimeTickIntervalControl
	 * @Inputs a default-attached ticking component
	 * @Return InitiallyDisabled false, EnabledAfterToggle true, intervals ~0.125 then 0.25 then 0.05
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitiallyDisabled = !TickComp.IsComponentTickEnabled();
		InitialInterval = TickComp.GetComponentTickInterval();

		TickComp.SetComponentTickInterval(0.25f);
		UpdatedInterval = TickComp.GetComponentTickInterval();

		TickComp.SetComponentTickInterval(0.05f);
		SecondUpdatedInterval = TickComp.GetComponentTickInterval();

		TickComp.SetComponentTickEnabled(true);
		EnabledAfterToggle = TickComp.IsComponentTickEnabled();
	}

	/**
	 * Disable ticking at runtime and record that it took effect.
	 *
	 * @Kind Action
	 * @Covers Component.RuntimeTickIntervalControl
	 * @Inputs none
	 * @Return DisabledAfterToggle set from the tick-enabled state after disabling
	 */
	UFUNCTION()
	void DisableRuntimeTick()
	{
		TickComp.SetComponentTickEnabled(false);
		DisabledAfterToggle = !TickComp.IsComponentTickEnabled();
	}

	/**
	 * Observe that a locally constructed actor has no intervals and no flags set.
	 *
	 * @Kind Observe
	 * @Covers Component.RuntimeTickIntervalControl
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all flags are clear, all intervals are 0 and TickComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitiallyDisabled)
		{
			return false;
		}
		if (EnabledAfterToggle)
		{
			return false;
		}
		if (DisabledAfterToggle)
		{
			return false;
		}
		if (InitialInterval != 0.0f)
		{
			return false;
		}
		if (UpdatedInterval != 0.0f)
		{
			return false;
		}
		if (SecondUpdatedInterval != 0.0f)
		{
			return false;
		}
		return TickComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.RuntimeTickIntervalControl
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the toggled state and the other stays at zero
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentRuntimeTickIntervalActor Second)
	{
		if (Second is null)
		{
			throw("ComponentRuntimeTickIntervalControl setup: required Second is null");
		}
		EnabledAfterToggle = true;
		UpdatedInterval = 0.25f;

		if (!EnabledAfterToggle)
		{
			return false;
		}
		if (UpdatedInterval != 0.25f)
		{
			return false;
		}
		if (Second.EnabledAfterToggle)
		{
			return false;
		}
		return Second.UpdatedInterval == 0.0f;
	}
}
