// Framework contract: Automation bridges persist across source movement.
// Command builders are fieldless; a retained/moved builder or a closed
// session must fail once without touching the new session's queue.
// Version pair: this stored source is generation A with body marker
// TS-FW-AUTOMATION-003-GEN-A. The HotReload runner later loads generation B
// with the same suite/method names and marker GEN-B, then executes a stale
// handle captured from A.
// Payload: a retained builder plus a valid current Then callback are
// enough for the oracle to distinguish stale vs current.
// Expected observations: current Commands() remain executable; stale
// handles fail at their call site; bridge identity stays deterministic.
// C++ oracle required: stale-once failure, new-session isolation, and
// persistent bridge identity.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceCommandOwnershipAndStaleHandlesSuite : UAngelscriptTestSuite
{
	FString BodyMarker = "TS-FW-AUTOMATION-003-GEN-A";
	FAngelscriptTestCommandBuilder RetainedBuilder;
	int CurrentCallbackCount = 0;

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyCommandOwnershipAndStaleHandles()
	{
		AssertEquals(
			"TS-FW-AUTOMATION-003-GEN-A",
			BodyMarker,
			"TS-FW-AUTOMATION-003 generation A marker");
		RetainedBuilder = FAngelscriptTest::Commands();
		FAngelscriptTest::Commands()
			.Then(n"RecordCurrentCallback", "current session command");
	}

	void RecordCurrentCallback()
	{
		CurrentCallbackCount += 1;
		AssertEquals(
			1,
			CurrentCallbackCount,
			"TS-FW-AUTOMATION-003 current callback count");
		RetainedBuilder.Then(n"StaleCallbackMustNotRun", "stale retained builder");
	}

	void StaleCallbackMustNotRun()
	{
		Fail("TS-FW-AUTOMATION-003 stale callback ran on the current session");
	}
}

// Generation B replacement (applied by the HotReload runner onto the same
// logical module path): BodyMarker = "TS-FW-AUTOMATION-003-GEN-B" with the
// same class and VerifyCommandOwnershipAndStaleHandles method. A builder
// retained from generation A must fail once and must not enqueue on B.
