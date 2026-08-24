// Theme: World.Component. WorldStory: TestCase component Tick increments TickCount.
// C++: AngelscriptComponentTests.cpp::Tick
// enable tick + TickWorld 5 times, then VerifyByPath TickCount >= 5. Keep TickCount.
// sha256=05cfdc7ed2788379f75e9b0ca75f696337860210e9c393636ce08fe1baa04a6d; lines 166-179.
// Extra: local construct leaves TickCount 0; writing 5 on one instance leaves the other 0.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class UTestComponentTick : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}
}

bool Observe_ComponentTick_DefaultZero(UTestComponentTick Comp)
{
	if (Comp is null)
	{
		throw("Test_Tick setup: required Comp is null");
	}
	return Comp.TickCount == 0;
}

bool Observe_ComponentTick_CopyIndependence(UTestComponentTick First, UTestComponentTick Second)
{
	if (First is null)
	{
		throw("Test_Tick setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Tick setup: required Second is null");
	}
	First.TickCount = 5;
	return First.TickCount == 5 && Second.TickCount == 0;
}
