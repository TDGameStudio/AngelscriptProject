/**
 * @version v1
 * @summary TestFramework HotReload Test_LastGoodGenerationRetention_Broken
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework HotReload Test_LastGoodGenerationRetention_Broken
 * @topic Baseline
 */
// Framework contract: a compile failure must not publish a partial
// registry. The prior Good generation stays authoritative.
// Version pair: this Broken source replaces
// Test_LastGoodGenerationRetention_Good.as on the same logical module path.
// The intended suite/method names remain recognizable for the oracle.
// Payload: the documented MissingReloadType error is the observation; there
// is no passing assertion in this generation.
// Expected observations: compilation fails at the documented type; no new
// snapshot publishes; Good remains last-good.
// C++ oracle required: compile diagnostic line, absence of a Broken
// generation, and that Good still runs.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceLastGoodGenerationRetentionBrokenSuite : UAngelscriptTestSuite
{
	FString BodyMarker = "TS-FW-HOTRELOAD-004-BROKEN";

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyLastGoodGenerationRetentionBroken()
	{
		// TS-FW-HOTRELOAD-004 documented type error location.
		MissingReloadType BrokenGenerationMarker = 0;
	}
}
/** @end */
