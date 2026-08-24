// Theme: Feature.Inheritance. WorldStory Blueprint child inherits script Tick.
// C++: AngelscriptBlueprintChildTests.cpp::InheritsTick
// Oracle: TickCount >= DefaultTickCount (3) after world ticks.
// Extra: empty handle null; default TickCount 0; Tick(0.0) still increments.
// FixtureIsolated. Keep TickCount.

UCLASS()
class ATestBPChildInheritsTickParent : AActor
{
	UPROPERTY()
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount += 1;
	}
}

bool Observe_InheritsTick_EmptyHandleIsNull()
{
	ATestBPChildInheritsTickParent Actor;
	return Actor == nullptr;
}

int Observe_InheritsTick_DefaultCount(ATestBPChildInheritsTickParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0179 setup: required ATestBPChildInheritsTickParent is null");
	}
	return Actor.TickCount;
}

int Observe_InheritsTick_ZeroDeltaBoundary(ATestBPChildInheritsTickParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0179 setup: required ATestBPChildInheritsTickParent is null");
	}
	Actor.Tick(0.0f);
	return Actor.TickCount;
}

int Observe_InheritsTick_AfterWorldTicks(ATestBPChildInheritsTickParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0179 setup: required ATestBPChildInheritsTickParent is null");
	}
	return Actor.TickCount;
}
