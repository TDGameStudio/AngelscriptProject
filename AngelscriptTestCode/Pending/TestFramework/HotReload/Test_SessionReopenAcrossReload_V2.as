/**
 * @version v1
 * @summary TestFramework HotReload Test_SessionReopenAcrossReload_V2
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework HotReload Test_SessionReopenAcrossReload_V2
 * @topic Baseline
 */
// Framework contract: reload reopens all-hooks for the new generation.
// No V1 session counters or body marker are reused.
// Version pair: replacement for Test_SessionReopenAcrossReload_V1.as on
// the same logical module path. Planned names keep the V2 suffix in this
// stored source.
// Payload: fresh counters starting at 0 and marker TS-FW-HOTRELOAD-007-V2
// are enough to prove a new session.
// Expected observations: BeforeAll runs again for V2; BodyMarker is V2;
// V1 AfterAllCount is not visible.
// C++ oracle required: new session generation, hook re-entry, and isolation
// from V1 session state.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceSessionReopenAcrossReloadV2Suite : UAngelscriptTestSuite
{
	FString BodyMarker = "TS-FW-HOTRELOAD-007-V2";
	int BeforeAllCount = 0;
	int AfterAllCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeforeAll()
	{
		BeforeAllCount += 1;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifySessionReopenAcrossReloadV2()
	{
		AssertEquals(
			"TS-FW-HOTRELOAD-007-V2",
			BodyMarker,
			"TS-FW-HOTRELOAD-007 V2 body marker");
		AssertEquals(0, BeforeAllCount, "TS-FW-HOTRELOAD-007 V2 leaf saw session BeforeAllCount");
		AssertEquals(0, AfterAllCount, "TS-FW-HOTRELOAD-007 V2 reused V1 AfterAllCount");
	}

	UFUNCTION(BlueprintOverride)
	void AfterAll()
	{
		AfterAllCount += 1;
	}
}
/** @end */
