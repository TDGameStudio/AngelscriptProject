/**
 * @version v1
 * @summary TestFramework HotReload Test_LastGoodGenerationRetention_Good
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework HotReload Test_LastGoodGenerationRetention_Good
 * @topic Baseline
 */
// Framework contract: a valid compile becomes last-good and remains
// runnable until a later valid replacement. A broken follow-up must not
// publish a partial registry.
// Version pair: this Good source is paired with
// Test_LastGoodGenerationRetention_Broken.as on the same logical module
// path. The runner loads Good first, then Broken.
// Payload: stable descriptor names plus marker TS-FW-HOTRELOAD-003-GOOD
// on a passing leaf are enough to identify last-good.
// Expected observations: this generation is last-good and remains
// executable after Broken fails to compile.
// C++ oracle required: last-good retention, no partial Broken snapshot,
// and continued execution of this leaf.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceLastGoodGenerationRetentionGoodSuite : UAngelscriptTestSuite
{
	FString BodyMarker = "TS-FW-HOTRELOAD-003-GOOD";

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyLastGoodGenerationRetentionGood()
	{
		AssertEquals(
			"TS-FW-HOTRELOAD-003-GOOD",
			BodyMarker,
			"TS-FW-HOTRELOAD-003 good body marker");
	}
}
/** @end */
