/**
 * @version v1
 * @summary TestFramework HotReload Test_ActiveLeafCancellationAndCleanup
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework HotReload Test_ActiveLeafCancellationAndCleanup
 * @topic Baseline
 */
// Framework contract: cancelling an active latent leaf during reload or
// shutdown runs After, teardown, and cleanup exactly once on the old
// generation before releasing old functions or objects.
// Payload: pending Until plus WaitDelay, an advanced command with After,
// teardown/cleanup callbacks, and a spawned object give the oracle
// unique phase markers.
// Expected observations: cancellation records After, TearDown, and Cleanup
// once each; owned objects are released only after those phases.
// C++ oracle required: exact-once phase order, old-generation identity,
// and that functions are not released before cleanup.

UCLASS()
class UTestSourceCancellationObject : UObject
{
	int Value = 0;
}

UCLASS()
class UTestSourceCancellationCommand : ULatentAutomationCommand
{
	int AfterCount = 0;

	UFUNCTION(BlueprintOverride)
	void Before()
	{
		UTestSourceActiveLeafCancellationAndCleanupSuite Suite =
			Cast<UTestSourceActiveLeafCancellationAndCleanupSuite>(GetCurrentSuite());
		Suite.AssertNotNull(Suite, "TS-FW-HOTRELOAD-005 Before missing suite");
		Suite.Value = 1;
	}

	UFUNCTION(BlueprintOverride)
	bool Update()
	{
		return false;
	}

	UFUNCTION(BlueprintOverride)
	void After()
	{
		UTestSourceActiveLeafCancellationAndCleanupSuite Suite =
			Cast<UTestSourceActiveLeafCancellationAndCleanupSuite>(GetCurrentSuite());
		AfterCount += 1;
		Suite.AfterCount = AfterCount;
	}

	UFUNCTION(BlueprintOverride)
	FString Describe() const
	{
		return "TS-FW-HOTRELOAD-005 cancellation command";
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceActiveLeafCancellationAndCleanupSuite : UAngelscriptTestSuite
{
	int Value = 0;
	int AfterCount = 0;
	int TearDownCount = 0;
	int CleanupCount = 0;

	bool NeverReady()
	{
		return false;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyActiveLeafCancellationAndCleanup()
	{
		UTestSourceCancellationObject Object =
			Cast<UTestSourceCancellationObject>(
				FAngelscriptTest::SpawnObject(
					UTestSourceCancellationObject::StaticClass()));
		AssertNotNull(Object, "TS-FW-HOTRELOAD-005 missing owned object");
		Object.Value = 7;
		UTestSourceCancellationCommand Command =
			Cast<UTestSourceCancellationCommand>(
				NewObject(
					this,
					UTestSourceCancellationCommand::StaticClass()));
		FAngelscriptTest::Commands()
			.OnTearDown(n"RecordCancellationTearDown")
			.OnCleanup(n"RecordCancellationCleanup")
			.AddLatentCommand(Command, 5.0)
			.Until(n"NeverReady", 5.0, "TS-FW-HOTRELOAD-005 pending until")
			.WaitDelay(5.0, "TS-FW-HOTRELOAD-005 pending delay");
	}

	void RecordCancellationTearDown()
	{
		TearDownCount += 1;
	}

	void RecordCancellationCleanup()
	{
		CleanupCount += 1;
	}
}
/** @end */
