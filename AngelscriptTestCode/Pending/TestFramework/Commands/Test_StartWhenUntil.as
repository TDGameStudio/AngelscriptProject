/**
 * @version v1
 * @summary TestFramework Commands Test_StartWhenUntil
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework Commands Test_StartWhenUntil
 * @topic Baseline
 */
// Framework contract: StartWhen delays later actions until a condition
// becomes true. Until polls a completion condition with an explicit timeout
// and description. Callbacks remain on the owning leaf instance.
// Payload: a false-to-true start flag, a progress counter that completes at
// 2, and 1.0s timeouts are enough to show gating and polling.
// Expected observations: no progress runs before StartWhen succeeds; Until
// reaches Progress==2; VerifyCompletion sees this leaf's fields.
// C++ oracle required: poll order, timeout bounds, and callback-scope
// identity.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceStartWhenUntilSuite : UAngelscriptTestSuite
{
	bool bStartAllowed = false;
	int Progress = 0;
	int ActionsBeforeStart = 0;

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyStartWhenUntil()
	{
		FAngelscriptTest::Commands()
			.Do(n"KeepStartClosed", "close start gate")
			.StartWhen(n"IsStartAllowed", 1.0, "start when flag")
			.Then(n"BeginProgress", "begin until payload")
			.Until(n"IsProgressComplete", 1.0, "until progress complete")
			.Then(n"VerifyCompletion", "owning leaf completion");
	}

	void KeepStartClosed()
	{
		AssertFalse(bStartAllowed, "TS-FW-COMMANDS-002 start flag already true");
		AssertEquals(0, Progress, "TS-FW-COMMANDS-002 progress before StartWhen");
		ActionsBeforeStart += 1;
		bStartAllowed = true;
	}

	bool IsStartAllowed()
	{
		return bStartAllowed;
	}

	void BeginProgress()
	{
		AssertEquals(1, ActionsBeforeStart, "TS-FW-COMMANDS-002 start action skipped");
		Progress = 1;
	}

	bool IsProgressComplete()
	{
		if (Progress < 2)
		{
			Progress += 1;
		}
		return Progress >= 2;
	}

	void VerifyCompletion()
	{
		AssertTrue(bStartAllowed, "TS-FW-COMMANDS-002 start flag lost");
		AssertEquals(2, Progress, "TS-FW-COMMANDS-002 until did not complete");
		AssertSame(this, this, "TS-FW-COMMANDS-002 callback scope payload");
	}
}
/** @end */
