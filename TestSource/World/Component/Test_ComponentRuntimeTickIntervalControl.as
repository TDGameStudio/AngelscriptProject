// Theme: World.Component. WorldStory: SetComponentTickInterval / Enabled
// and DisableRuntimeTick.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentRuntimeTickIntervalControl
// sha256=209acb16aff8dad3c98c48c1c8c1d56822b72dfcce6addb9ec5ba6ffaea4972e; lines 2542-2603.
// Oracle: InitiallyDisabled=false, EnabledAfterToggle=true, InitialInterval
// ~0.125 then 0.25 then 0.05. Extra: local construct intervals 0, flags false,
// TickComp null. FixtureIsolated.

UCLASS()
class UCoverageRuntimeTickIntervalComponent : UActorComponent
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

	UFUNCTION()
	void DisableRuntimeTick()
	{
		TickComp.SetComponentTickEnabled(false);
		DisabledAfterToggle = !TickComp.IsComponentTickEnabled();
	}
}

bool Observe_RuntimeTickInterval_DefaultEmpty(ACoverageComponentRuntimeTickIntervalActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComponentRuntimeTickIntervalControl setup: required Actor is null");
	}
	return !Actor.InitiallyDisabled
		&& !Actor.EnabledAfterToggle
		&& !Actor.DisabledAfterToggle
		&& Actor.InitialInterval == 0.0f
		&& Actor.UpdatedInterval == 0.0f
		&& Actor.SecondUpdatedInterval == 0.0f
		&& Actor.TickComp == nullptr;
}

bool Observe_RuntimeTickInterval_CopyIndependence(ACoverageComponentRuntimeTickIntervalActor First, ACoverageComponentRuntimeTickIntervalActor Second)
{
	if (First is null)
	{
		throw("Test_ComponentRuntimeTickIntervalControl setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ComponentRuntimeTickIntervalControl setup: required Second is null");
	}
	First.EnabledAfterToggle = true;
	First.UpdatedInterval = 0.25f;
	return First.EnabledAfterToggle
		&& First.UpdatedInterval == 0.25f
		&& !Second.EnabledAfterToggle
		&& Second.UpdatedInterval == 0.0f;
}
