// Framework contract: after coalesced cleanup of V1, this generation
// publishes as the current registry snapshot. Idle refresh of this body
// would publish immediately.
// Version pair: applied onto the same logical module path as
// Test_RegistryRefreshAndCoalescing_V1.as. Planned class/method names keep
// the V2 suffix in this stored source; the runner treats them as the
// replacement body for the V1 identity.
// Payload: changed marker TS-FW-HOTRELOAD-002-V2 with the same flags is
// enough to prove the new generation is loaded.
// Expected observations: idle refresh publishes this marker immediately;
// active refresh only publishes it after V1 cleanup.
// C++ oracle required: publication timing, marker/flags identity, and that
// V1 functions are no longer authoritative.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceRegistryRefreshAndCoalescingV2Suite : UAngelscriptTestSuite
{
	FString BodyMarker = "TS-FW-HOTRELOAD-002-V2";

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyRegistryRefreshAndCoalescingV2()
	{
		AssertEquals(
			"TS-FW-HOTRELOAD-002-V2",
			BodyMarker,
			"TS-FW-HOTRELOAD-002 V2 body marker");
	}
}
