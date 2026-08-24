// Framework contract: an active Automation section opens all-hooks once.
// Reload must close that session cleanly before the replacement generation
// reopens BeforeAll/AfterAll.
// Version pair: this V1 file is replaced by
// Test_SessionReopenAcrossReload_V2.as on the same logical module path.
// Payload: BeforeAll/AfterAll counters, marker TS-FW-HOTRELOAD-006-V1, and
// a held latent leaf are enough for the oracle to see one open/close.
// Expected observations: BeforeAll runs once for V1; the held leaf stays
// active until replacement; the original session closes before V2.
// C++ oracle required: single V1 session open/close and no reuse of V1
// session state after reload.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceSessionReopenAcrossReloadV1Suite : UAngelscriptTestSuite
{
	FString BodyMarker = "TS-FW-HOTRELOAD-006-V1";
	int BeforeAllCount = 0;
	int AfterAllCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeforeAll()
	{
		BeforeAllCount += 1;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifySessionReopenAcrossReloadV1()
	{
		AssertEquals(
			"TS-FW-HOTRELOAD-006-V1",
			BodyMarker,
			"TS-FW-HOTRELOAD-006 V1 body marker");
		AssertEquals(0, BeforeAllCount, "TS-FW-HOTRELOAD-006 V1 leaf saw session BeforeAllCount");
		FAngelscriptTest::Commands()
			.WaitDelay(5.0, "TS-FW-HOTRELOAD-006 hold V1 leaf");
	}

	UFUNCTION(BlueprintOverride)
	void AfterAll()
	{
		AfterAllCount += 1;
	}
}
