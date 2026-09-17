/**
 * @version v1
 * @summary TestFramework HotReload Test_RegistryRefreshAndCoalescing_V1
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework HotReload Test_RegistryRefreshAndCoalescing_V1
 * @topic Baseline
 */
// Framework contract: idle registry refresh publishes immediately; a refresh
// while a leaf is running defers and coalesces until that leaf's cleanup.
// Version pair: this file is V1 for the same logical module path as
// Test_RegistryRefreshAndCoalescing_V2.as. The runner replaces V1 with V2
// after observing this generation.
// Payload: body marker TS-FW-HOTRELOAD-001-V1, a 5s WaitDelay hold, and
// unique cleanup names are enough for the oracle to identify V1 and watch
// coalescing.
// Expected observations: this generation is uniquely identifiable; cleanup
// markers run on the old generation before V2 publishes.
// C++ oracle required: idle vs active refresh timing, coalescing, and that
// V2 is not visible until cleanup.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceRegistryRefreshAndCoalescingV1Suite : UAngelscriptTestSuite
{
	FString BodyMarker = "TS-FW-HOTRELOAD-001-V1";
	int CleanupCount = 0;

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyRegistryRefreshAndCoalescingV1()
	{
		AssertEquals(
			"TS-FW-HOTRELOAD-001-V1",
			BodyMarker,
			"TS-FW-HOTRELOAD-001 V1 body marker");
		FAngelscriptTest::Commands()
			.OnTearDown(n"RecordV1TearDown")
			.OnCleanup(n"RecordV1Cleanup")
			.WaitDelay(5.0, "TS-FW-HOTRELOAD-001 hold leaf active during refresh")
			.Then(n"AfterV1Hold");
	}

	void AfterV1Hold()
	{
		AssertEquals(0, CleanupCount, "TS-FW-HOTRELOAD-001 cleanup ran before hold finished");
	}

	void RecordV1TearDown()
	{
		CleanupCount += 1;
	}

	void RecordV1Cleanup()
	{
		CleanupCount += 1;
	}
}
/** @end */
