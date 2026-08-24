// Framework contract: WaitDelay resumes after elapsed command time and does
// not advance the test World clock.
// Payload: a 0.01s delay plus GetTimeSeconds samples before/after on an
// optional World are enough; real-time elapsed is an oracle observation.
// Expected observations: AfterDelay runs only after the delay; World time
// equals the pre-delay sample unless AdvanceTime is used; GetTestWorld is
// released on cleanup.
// C++ oracle required: delay elapsed on command time, unchanged World time,
// and resume order.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceWaitDelayTimingSuite : UAngelscriptTestSuite
{
	float64 WorldTimeBeforeDelay = -1.0;
	bool bAfterDelayRan = false;

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyWaitDelayTiming()
	{
		FAngelscriptTest::CreateTestWorld(false);
		UWorld World = FAngelscriptTest::GetTestWorld();
		AssertNotNull(World, "TS-FW-COMMANDS-003 missing optional World");
		WorldTimeBeforeDelay = World.GetTimeSeconds();
		FAngelscriptTest::Commands()
			.OnCleanup(n"DestroyDelayWorld")
			.WaitDelay(0.01, "TS-FW-COMMANDS-003 short delay")
			.Then(n"AfterDelay");
	}

	void AfterDelay()
	{
		bAfterDelayRan = true;
		UWorld World = FAngelscriptTest::GetTestWorld();
		AssertNotNull(World, "TS-FW-COMMANDS-003 World lost during delay");
		AssertEquals(
			WorldTimeBeforeDelay,
			World.GetTimeSeconds(),
			"TS-FW-COMMANDS-003 WaitDelay advanced World time");
	}

	void DestroyDelayWorld()
	{
		AssertTrue(bAfterDelayRan, "TS-FW-COMMANDS-003 AfterDelay did not run before cleanup");
		FAngelscriptTest::DestroyTestWorld();
		AssertNull(FAngelscriptTest::GetTestWorld(), "TS-FW-COMMANDS-003 World survived cleanup");
	}
}
