// Framework contract: a failing assertion records exactly one diagnostic
// with the custom message and call-site location, then stops the leaf.
// AfterEach and OnCleanup still run.
// Payload: AssertTrue(false) plus a sentinel mutation that must remain 0 is
// enough to prove fail-fast without extra APIs.
// Expected observations: one diagnostic contains
// TS-FW-ASSERTIONS-005 custom assertion; AfterFailureSentinel stays 0;
// cleanup marker runs once.
// C++ oracle required: diagnostic uniqueness, source location, fail-fast
// control flow, and cleanup execution.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceFailureDiagnosticsAndFailFastSuite : UAngelscriptTestSuite
{
	int AfterFailureSentinel = 0;
	int CleanupCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		FAngelscriptTest::Commands()
			.OnCleanup(n"RecordFailFastCleanup");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyFailureDiagnosticsAndFailFast()
	{
		AssertTrue(false, "TS-FW-ASSERTIONS-005 custom assertion");
		AfterFailureSentinel = 99;
	}

	UFUNCTION(BlueprintOverride)
	void AfterEach()
	{
		AssertEquals(
			0,
			AfterFailureSentinel,
			"TS-FW-ASSERTIONS-005 statement after failure executed");
	}

	void RecordFailFastCleanup()
	{
		CleanupCount += 1;
		AssertEquals(
			1,
			CleanupCount,
			"TS-FW-ASSERTIONS-005 cleanup should run once");
	}
}
