/**
 * @version v1
 * @summary TestFramework World Test_TickAndAdvanceTime
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework World Test_TickAndAdvanceTime
 * @topic Baseline
 */
// Framework contract: TickWorld/TickActor/TickComponent are direct tick
// drivers. AdvanceTime advances scheduler/world time independently of those
// direct counters. Requested elapsed time is not discarded.
// Payload: delta 0.01 with counts 2/3 and AdvanceTime(0.05, 2) are enough.
// Expected observations: actor/component counters equal requested direct
// ticks; World time after AdvanceTime is at least TimeBefore+0.1.
// C++ oracle required: independence of direct ticks vs time advancement,
// and that elapsed time is retained.

UCLASS()
class ATestSourceTickTimeProbeActor : AActor
{
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}
}

UCLASS()
class UTestSourceTickTimeProbeComponent : UActorComponent
{
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceTickAndAdvanceTimeSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyTickAndAdvanceTime()
	{
		FAngelscriptTest::CreateTestWorld(false);
		UWorld World = FAngelscriptTest::GetTestWorld();
		AssertNotNull(World, "TS-FW-WORLD-004 missing World");

		ATestSourceTickTimeProbeActor Actor =
			Cast<ATestSourceTickTimeProbeActor>(
				FAngelscriptTest::SpawnActor(
					ATestSourceTickTimeProbeActor::StaticClass()));
		UTestSourceTickTimeProbeComponent Component =
			Cast<UTestSourceTickTimeProbeComponent>(
				FAngelscriptTest::SpawnComponent(
					UTestSourceTickTimeProbeComponent::StaticClass(),
					Actor,
					true));
		FAngelscriptTest::BeginPlay(Actor);

		const float64 TimeBeforeDirectTicks = World.GetTimeSeconds();
		FAngelscriptTest::TickActor(Actor, 0.01, 2);
		FAngelscriptTest::TickComponent(Component, 0.01, 3);
		AssertEquals(2, Actor.TickCount, "TS-FW-WORLD-004 actor direct ticks");
		AssertEquals(3, Component.TickCount, "TS-FW-WORLD-004 component direct ticks");
		AssertEquals(
			TimeBeforeDirectTicks,
			World.GetTimeSeconds(),
			"TS-FW-WORLD-004 direct ticks advanced World time");

		const float64 TimeBeforeAdvance = World.GetTimeSeconds();
		FAngelscriptTest::AdvanceTime(0.05, 2);
		AssertGreaterThanOrEqual(
			World.GetTimeSeconds(),
			TimeBeforeAdvance + 0.1,
			"TS-FW-WORLD-004 AdvanceTime elapsed time discarded");

		const int ActorTicksAfterAdvance = Actor.TickCount;
		FAngelscriptTest::TickWorld(0.01, 1);
		AssertGreaterThanOrEqual(
			Actor.TickCount,
			ActorTicksAfterAdvance,
			"TS-FW-WORLD-004 TickWorld discarded");

		FAngelscriptTest::DestroyActor(Actor, true);
		FAngelscriptTest::DestroyTestWorld();
		AssertNull(FAngelscriptTest::GetTestWorld(), "TS-FW-WORLD-004 World survived");
	}
}
/** @end */
