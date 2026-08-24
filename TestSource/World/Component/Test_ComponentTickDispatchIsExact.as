// Theme: World.Component. WorldStory: component Tick override count.
// C++: AngelscriptComponentLifecycleExtendedTests.cpp::ComponentTickDispatchIsExact
// sha256=e5f062dedfa06868ca2d34c30d33100baa00f7105e3099e4c2a9fad005120501; lines 143-163.
// Oracle TickCount equals C++ ExpectedTicks (4) after direct dispatch.
// Extra: local construct TickCount 0, Probe null. FixtureIsolated.

UCLASS()
class UTestComponentLifecycleExactTickProbe : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}
}

UCLASS()
class ATestComponentLifecycleExactTick : AActor
{
	UPROPERTY(DefaultComponent)
	UTestComponentLifecycleExactTickProbe Probe;
}

bool Observe_ExactTick_DefaultEmpty(ATestComponentLifecycleExactTick Actor)
{
	if (Actor is null)
	{
		throw("Test_ComponentTickDispatchIsExact setup: required Actor is null");
	}
	return Actor.Probe == nullptr;
}

bool Observe_ExactTick_ProbeDefaultZero(UTestComponentLifecycleExactTickProbe Probe)
{
	if (Probe is null)
	{
		throw("Test_ComponentTickDispatchIsExact setup: required Probe is null");
	}
	return Probe.TickCount == 0;
}

bool Observe_ExactTick_CopyIndependence(UTestComponentLifecycleExactTickProbe First, UTestComponentLifecycleExactTickProbe Second)
{
	if (First is null)
	{
		throw("Test_ComponentTickDispatchIsExact setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ComponentTickDispatchIsExact setup: required Second is null");
	}
	First.TickCount = 4;
	return First.TickCount == 4 && Second.TickCount == 0;
}
