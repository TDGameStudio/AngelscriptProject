/**
 * @version v1
 * @summary TestFramework Commands Test_TeardownCleanupLifo
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework Commands Test_TeardownCleanupLifo
 * @topic Baseline
 */
// Framework contract: OnTearDown and OnCleanup are distinct LIFO phases.
// Teardown precedes cleanup. Both still run after a failing leaf.
// Payload: two teardown names, two cleanup names, one passing leaf and one
// failing leaf with unique markers are enough.
// Expected observations: passing leaf trace is TearDownSecond;TearDownFirst;
// CleanupSecond;CleanupFirst;. Failing leaf still records the same LIFO
// phases after TS-FW-COMMANDS-004 leaf assertion.
// C++ oracle required: phase separation, LIFO order, and execution after
// failure.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceTeardownCleanupLifoSuite : UAngelscriptTestSuite
{
	FString PhaseTrace;
	int AfterFailureSentinel = 0;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		PhaseTrace = "";
		FAngelscriptTest::Commands()
			.OnTearDown(n"RecordTearDownFirst", "teardown first")
			.OnTearDown(n"RecordTearDownSecond", "teardown second")
			.OnCleanup(n"RecordCleanupFirst", "cleanup first")
			.OnCleanup(n"RecordCleanupSecond", "cleanup second");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyTeardownCleanupLifo()
	{
		FAngelscriptTest::Commands()
			.Then(n"RecordPassingLeaf");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailThenObserveLifo()
	{
		Fail("TS-FW-COMMANDS-004 leaf assertion");
		AfterFailureSentinel = 99;
	}

	void RecordPassingLeaf()
	{
		AssertEquals(0, AfterFailureSentinel, "TS-FW-COMMANDS-004 passing leaf saw fail sentinel");
	}

	void RecordTearDownSecond()
	{
		PhaseTrace += "TearDownSecond;";
	}

	void RecordTearDownFirst()
	{
		PhaseTrace += "TearDownFirst;";
		AssertTrue(
			PhaseTrace.Contains("TearDownSecond;"),
			"TS-FW-COMMANDS-004 teardown was not LIFO");
	}

	void RecordCleanupSecond()
	{
		AssertTrue(
			PhaseTrace.Contains("TearDownFirst;"),
			"TS-FW-COMMANDS-004 cleanup ran before teardown");
		PhaseTrace += "CleanupSecond;";
	}

	void RecordCleanupFirst()
	{
		PhaseTrace += "CleanupFirst;";
		AssertEquals(
			0,
			AfterFailureSentinel,
			"TS-FW-COMMANDS-004 cleanup saw mutation after Fail");
	}
}
/** @end */
