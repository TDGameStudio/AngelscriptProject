/**
 * @version v1
 * @summary TestFramework Assertions Test_ExpectedErrorAssertions
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework Assertions Test_ExpectedErrorAssertions
 * @topic Baseline
 */
// Framework contract: ExpectError/ExpectErrorRegex register literal-contains
// and regex expectations before Error() emission. Matching counts finalize
// as expected; over-count, under-count, and missing emissions become
// source-located framework failures.
// Payload: unique log strings and a [0-9]+ regex are enough to distinguish
// match, mismatch, and count cases without other logging APIs.
// Expected observations: matching leaves finalize silently; count mismatch
// and missing leaves each produce one diagnostic the oracle can attribute
// to this file.
// C++ oracle required: expected-error finalization, count mismatches,
// missing-error diagnostics, and source locations.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceExpectedErrorAssertionsSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyExpectedErrorAssertions()
	{
		ExpectError("TS-FW-ASSERTIONS-004 literal [brackets]", 1);
		Error("prefix TS-FW-ASSERTIONS-004 literal [brackets] suffix");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void MatchExpectedErrorRegex()
	{
		ExpectErrorRegex("TS-FW-ASSERTIONS-004 regex-value-[0-9]+", 2);
		Error("TS-FW-ASSERTIONS-004 regex-value-12");
		Error("TS-FW-ASSERTIONS-004 regex-value-34");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailExpectedErrorOverCount()
	{
		ExpectError("TS-FW-ASSERTIONS-004 over-count token", 1);
		Error("TS-FW-ASSERTIONS-004 over-count token");
		Error("TS-FW-ASSERTIONS-004 over-count token");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailExpectedErrorUnderCount()
	{
		ExpectError("TS-FW-ASSERTIONS-004 under-count token", 2);
		Error("TS-FW-ASSERTIONS-004 under-count token");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailExpectedErrorMissing()
	{
		ExpectError("TS-FW-ASSERTIONS-004 missing token", 1);
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailExpectedErrorNonmatching()
	{
		ExpectError("TS-FW-ASSERTIONS-004 required token", 1);
		Error("TS-FW-ASSERTIONS-004 unrelated token");
	}
}
/** @end */
