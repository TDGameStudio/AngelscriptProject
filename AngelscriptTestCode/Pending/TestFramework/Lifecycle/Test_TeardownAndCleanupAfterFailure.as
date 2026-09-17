/**
 * @version v1
 * @summary TestFramework Lifecycle Test_TeardownAndCleanupAfterFailure
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework Lifecycle Test_TeardownAndCleanupAfterFailure
 * @topic Baseline
 */
// Framework contract: AfterEach, OnTearDown, OnCleanup, and AfterAll still
// run after a controlled assertion failure. Teardown/cleanup are LIFO and
// do not leak fixture state into a later leaf.
// Payload: one failing leaf, two teardown names, two cleanup names, and a
// later fresh leaf are enough to expose order and isolation.
// Expected observations: the failing leaf stops at Fail; AfterFailureSentinel
// stays 0; later leaf starts at 0; teardown precedes cleanup in LIFO.
// C++ oracle required: phase order AfterEach -> teardown LIFO -> cleanup
// LIFO -> AfterAll, uniqueness of failure TS-FW-LIFECYCLE-003 leaf assertion,
// and no fixture leak.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceTeardownAndCleanupAfterFailureSuite : UAngelscriptTestSuite
{
	int AfterFailureSentinel = 0;
	int AfterEachCount = 0;
	FString PhaseTrace;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		FAngelscriptTest::Commands()
			.OnTearDown(n"RecordTearDownFirst", "teardown first")
			.OnTearDown(n"RecordTearDownSecond", "teardown second")
			.OnCleanup(n"RecordCleanupFirst", "cleanup first")
			.OnCleanup(n"RecordCleanupSecond", "cleanup second");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyTeardownAndCleanupAfterFailure()
	{
		Fail("TS-FW-LIFECYCLE-003 leaf assertion");
		AfterFailureSentinel = 99;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyLaterLeafDoesNotSeeFailedFixture()
	{
		AssertEquals(
			0,
			AfterFailureSentinel,
			"TS-FW-LIFECYCLE-003 later leaf saw failed-leaf sentinel");
		AssertEquals(
			0,
			AfterEachCount,
			"TS-FW-LIFECYCLE-003 later leaf saw prior AfterEach count");
	}

	UFUNCTION(BlueprintOverride)
	void AfterEach()
	{
		AfterEachCount += 1;
		PhaseTrace += "AfterEach;";
		AssertEquals(
			0,
			AfterFailureSentinel,
			"TS-FW-LIFECYCLE-003 AfterEach saw mutation after Fail");
	}

	void RecordTearDownSecond()
	{
		PhaseTrace += "TearDownSecond;";
	}

	void RecordTearDownFirst()
	{
		PhaseTrace += "TearDownFirst;";
	}

	void RecordCleanupSecond()
	{
		PhaseTrace += "CleanupSecond;";
	}

	void RecordCleanupFirst()
	{
		PhaseTrace += "CleanupFirst;";
	}

	UFUNCTION(BlueprintOverride)
	void AfterAll()
	{
		PhaseTrace += "AfterAll;";
	}
}
/** @end */
