// Framework contract: self-hosted failure cases exist so a C++ oracle can
// assert exact pass/fail counts, messages, locations, fail-fast, and
// cleanup order without circular AS self-validation.
// Payload: three isolated failing leaves with unique messages plus one
// passing control. Arithmetic in the control is incidental.
// Expected observations: assertion fail, expected-error-count fail, and
// cleanup-throw fail are distinguishable; the control leaf is silent.
// C++ oracle required: pass/fail counts, unique messages, source locations,
// fail-fast (AfterFailureSentinel stays 0), and cleanup order.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceFrameworkSelfHostedFailureOracleSuite : UAngelscriptTestSuite
{
	int AfterFailureSentinel = 0;
	int CleanupCount = 0;

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyFrameworkSelfHostedFailureOracle()
	{
		AssertEquals(2, 1 + 1, "TS-FW-SELFHOSTED-002 passing control payload");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailIsolatedAssertion()
	{
		FAngelscriptTest::Commands()
			.OnCleanup(n"RecordFailureOracleCleanup");
		AssertTrue(false, "TS-FW-SELFHOSTED-002 assertion failure");
		AfterFailureSentinel = 99;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailIsolatedExpectedErrorCount()
	{
		ExpectError("TS-FW-SELFHOSTED-002 expected-error-count token", 2);
		Error("TS-FW-SELFHOSTED-002 expected-error-count token");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailIsolatedCleanupException()
	{
		FAngelscriptTest::Commands()
			.OnCleanup(n"ThrowFailureOracleCleanup");
		Fail("TS-FW-SELFHOSTED-002 cleanup-path primary failure");
	}

	void RecordFailureOracleCleanup()
	{
		CleanupCount += 1;
		AssertEquals(
			0,
			AfterFailureSentinel,
			"TS-FW-SELFHOSTED-002 fail-fast sentinel mutated");
	}

	void ThrowFailureOracleCleanup()
	{
		throw("TS-FW-SELFHOSTED-002 cleanup exception");
	}
}
