/**
 * A component Tick override incrementing a counter. C++ enables ticking, ticks the
 * world five times and verifies the count by path. The observers cover the
 * local-construct default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.Tick
 * @Harness UClass
 * @Tag World.Component.Tick
 * @Provenance Theme: World.Component. WorldStory: TestCase component Tick increments TickCount.
 * @Provenance C++: AngelscriptComponentTests.cpp::Tick
 * @Provenance enable tick + TickWorld 5 times, then VerifyByPath TickCount >= 5. Keep TickCount.
 * @Provenance sha256=05cfdc7ed2788379f75e9b0ca75f696337860210e9c393636ce08fe1baa04a6d; lines 166-179.
 * @Provenance Extra: local construct leaves TickCount 0; writing 5 on one instance leaves the other 0.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class UTestComponentTick : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	/**
	 * WorldStory: Tick increments the counter once per dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Tick
	 * @Inputs the frame delta, unused
	 * @Return TickCount incremented once per tick
	 * @Param DeltaSeconds the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}

	/**
	 * Observe that a locally constructed component has not ticked.
	 *
	 * @Kind Observe
	 * @Covers Component.Tick
	 * @Inputs a component that has not been ticked
	 * @Return true when TickCount is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return TickCount == 0;
	}

	/**
	 * Observe that writing this component leaves another component untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.Tick
	 * @Inputs this component plus a second component
	 * @Return true when this counts 5 and the other stays at 0
	 * @Param Second the other component, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UTestComponentTick Second)
	{
		if (Second is null)
		{
			throw("Tick setup: required Second is null");
		}
		TickCount = 5;

		if (TickCount != 5)
		{
			return false;
		}
		return Second.TickCount == 0;
	}
}
