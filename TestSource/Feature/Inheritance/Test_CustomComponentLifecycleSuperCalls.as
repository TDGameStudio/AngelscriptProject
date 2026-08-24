// Theme: Feature.Inheritance. WorldStory component Super:: BeginPlay and Tick.
// C++: AngelscriptCoverageComponentTests.cpp::CustomComponentLifecycleSuperCalls
// sha256 from theme-refs TS-FEAT-0013; lines 1445-1502.
// Oracle after spawn+BeginPlay+two ticks of 0.025: SuperProbe BaseBeginPlayCount==1;
// DerivedBeginPlayCount==1; BaseTickCount==2; DerivedTickCount==2; LastDeltaMillis==25.
// Extra: local construct zeros; Tick(0) is the zero-delta boundary. FixtureIsolated.

UCLASS()
class UCoverageBaseLifecycleSuperComponent : UActorComponent
{
	UPROPERTY()
	int BaseBeginPlayCount = 0;

	UPROPERTY()
	int BaseTickCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BaseBeginPlayCount++;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		BaseTickCount++;
	}
}

UCLASS()
class UCoverageDerivedLifecycleSuperComponent : UCoverageBaseLifecycleSuperComponent
{
	UPROPERTY()
	int DerivedBeginPlayCount = 0;

	UPROPERTY()
	int DerivedTickCount = 0;

	UPROPERTY()
	int LastDeltaMillis = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();
		DerivedBeginPlayCount++;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		Super::Tick(DeltaTime);
		DerivedTickCount++;
		LastDeltaMillis = int(DeltaTime * 1000.0f);
	}
}

UCLASS()
class ACoverageComponentLifecycleSuperActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageDerivedLifecycleSuperComponent SuperProbe;
}

bool Observe_ComponentSuper_ActorDefaultEmpty(ACoverageComponentLifecycleSuperActor Actor)
{
	if (Actor is null)
	{
		throw("Test_CustomComponentLifecycleSuperCalls setup: required Actor is null");
	}
	return Actor.SuperProbe == nullptr || (Actor.SuperProbe.BaseBeginPlayCount == 0 && Actor.SuperProbe.LastDeltaMillis == 0);
}

int Observe_ComponentSuper_BeginPlayCounts(UCoverageDerivedLifecycleSuperComponent Probe)
{
	if (Probe is null)
	{
		throw("Test_CustomComponentLifecycleSuperCalls setup: required Probe is null");
	}
	Probe.BeginPlay();
	return Probe.BaseBeginPlayCount * 10 + Probe.DerivedBeginPlayCount;
}

int Observe_ComponentSuper_ZeroDeltaTick(UCoverageDerivedLifecycleSuperComponent Probe)
{
	if (Probe is null)
	{
		throw("Test_CustomComponentLifecycleSuperCalls setup: required Probe is null");
	}
	Probe.Tick(0.0f);
	return Probe.LastDeltaMillis;
}

int Observe_ComponentSuper_TwentyFiveMillisTick(UCoverageDerivedLifecycleSuperComponent Probe)
{
	if (Probe is null)
	{
		throw("Test_CustomComponentLifecycleSuperCalls setup: required Probe is null");
	}
	Probe.Tick(0.025f);
	return Probe.LastDeltaMillis;
}
