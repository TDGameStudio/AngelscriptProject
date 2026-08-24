// Theme: Feature.Inheritance. WorldStory BlueprintOverride BeginPlay/Tick Super chain.
// C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintOverrideBeginPlayTickAndSuperExecute
// Oracle after BeginPlay + two 0.025 ticks: BeginPlayCount==1, ChildBeginPlayCount==1,
// TickCount==2, ChildTickCount==2, LastDeltaMillis==25.
// Extra: empty handle null; pre-lifecycle counters 0; Tick(0.0) is the zero-delta boundary.
// FixtureIsolated. Keep BeginPlayCount/TickCount/ChildBeginPlayCount/ChildTickCount/LastDeltaMillis.

UCLASS()
class ACoverageUFunctionOverrideBase : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	int LastDeltaMillis = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}
}

UCLASS()
class ACoverageUFunctionOverrideChild : ACoverageUFunctionOverrideBase
{
	UPROPERTY()
	int ChildBeginPlayCount = 0;

	UPROPERTY()
	int ChildTickCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();
		ChildBeginPlayCount += 1;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		Super::Tick(DeltaSeconds);
		ChildTickCount += 1;
		LastDeltaMillis = int(DeltaSeconds * 1000.0f);
	}
}

bool Observe_OverrideLifecycle_EmptyHandleIsNull()
{
	ACoverageUFunctionOverrideChild Actor;
	return Actor == nullptr;
}

int Observe_OverrideLifecycle_CountersBeforeBeginPlay(ACoverageUFunctionOverrideChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0125 setup: required ACoverageUFunctionOverrideChild is null");
	}
	return Actor.BeginPlayCount + Actor.TickCount + Actor.ChildBeginPlayCount + Actor.ChildTickCount + Actor.LastDeltaMillis;
}

int Observe_OverrideLifecycle_TickZeroDeltaBoundary(ACoverageUFunctionOverrideChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0125 setup: required ACoverageUFunctionOverrideChild is null");
	}
	Actor.Tick(0.0f);
	return Actor.LastDeltaMillis;
}

bool Observe_OverrideLifecycle_AfterBeginPlayAndTwoTicks(ACoverageUFunctionOverrideChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0125 setup: required ACoverageUFunctionOverrideChild is null");
	}
	return Actor.BeginPlayCount == 1
		&& Actor.ChildBeginPlayCount == 1
		&& Actor.TickCount == 2
		&& Actor.ChildTickCount == 2
		&& Actor.LastDeltaMillis == 25;
}
