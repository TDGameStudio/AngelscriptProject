/**
 * @version v1
 * @summary TestFramework SelfHosted Test_FrameworkSelfHostedLatent
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework SelfHosted Test_FrameworkSelfHostedLatent
 * @topic Baseline
 */
// Framework contract: a self-hosted latent leaf may mix fluent
// Do/Then/Until/WaitDelay with one ULatentAutomationCommand. Completion is
// deterministic and bounded.
// Payload: counters that reach a fixed count plus a 0.01s delay are enough.
// Expected observations: one completed leaf, callback order
// First -> delay -> Until -> advanced Before/Update/After -> final, no
// timeout, and cleanup.
// C++ oracle required: exact callback order, no timeout, and final cleanup.

UCLASS()
class UTestSourceSelfHostedLatentCommand : ULatentAutomationCommand
{
	UFUNCTION(BlueprintOverride)
	void Before()
	{
		UTestSourceFrameworkSelfHostedLatentSuite Suite =
			Cast<UTestSourceFrameworkSelfHostedLatentSuite>(GetCurrentSuite());
		Suite.AssertNotNull(Suite, "TS-FW-SELFHOSTED-003 advanced Before missing suite");
		Suite.Value = 1;
	}

	UFUNCTION(BlueprintOverride)
	bool Update()
	{
		UTestSourceFrameworkSelfHostedLatentSuite Suite =
			Cast<UTestSourceFrameworkSelfHostedLatentSuite>(GetCurrentSuite());
		Suite.Value += 1;
		return Suite.Value >= 3;
	}

	UFUNCTION(BlueprintOverride)
	void After()
	{
		UTestSourceFrameworkSelfHostedLatentSuite Suite =
			Cast<UTestSourceFrameworkSelfHostedLatentSuite>(GetCurrentSuite());
		Suite.AssertEquals(3, Suite.Value, "TS-FW-SELFHOSTED-003 advanced After value");
		Suite.Value = 4;
	}

	UFUNCTION(BlueprintOverride)
	FString Describe() const
	{
		return "TS-FW-SELFHOSTED-003 advanced latent";
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceFrameworkSelfHostedLatentSuite : UAngelscriptTestSuite
{
	int Value = 0;
	FString CallbackTrace;
	bool bUntilReady = false;
	int CleanupCount = 0;

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyFrameworkSelfHostedLatent()
	{
		UTestSourceSelfHostedLatentCommand Command =
			Cast<UTestSourceSelfHostedLatentCommand>(
				NewObject(
					this,
					UTestSourceSelfHostedLatentCommand::StaticClass()));
		FAngelscriptTest::Commands()
			.OnCleanup(n"RecordLatentCleanup")
			.Do(n"AppendFirst", "first fluent action")
			.WaitDelay(0.01, "TS-FW-SELFHOSTED-003 delay")
			.Then(n"MarkUntilReady")
			.Until(n"IsUntilReady", 1.0, "until ready")
			.AddLatentCommand(Command, 1.0)
			.Then(n"VerifyLatentFinished");
	}

	void AppendFirst()
	{
		CallbackTrace += "First;";
	}

	void MarkUntilReady()
	{
		CallbackTrace += "Delay;";
		bUntilReady = true;
	}

	bool IsUntilReady()
	{
		return bUntilReady;
	}

	void VerifyLatentFinished()
	{
		CallbackTrace += "Advanced;";
		AssertEquals(4, Value, "TS-FW-SELFHOSTED-003 final advanced value");
		AssertEquals(
			"First;Delay;Advanced;",
			CallbackTrace,
			"TS-FW-SELFHOSTED-003 callback order");
		AssertEquals(0, CleanupCount, "TS-FW-SELFHOSTED-003 cleanup ran early");
	}

	void RecordLatentCleanup()
	{
		CleanupCount += 1;
		CallbackTrace += "Cleanup;";
	}
}
/** @end */
