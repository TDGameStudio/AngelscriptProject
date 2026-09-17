/**
 * @version v1
 * @summary TestFramework Assertions Test_AssertionExceptionsAcrossPhases
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework Assertions Test_AssertionExceptionsAcrossPhases
 * @topic Baseline
 */
// Framework contract: ordinary throw() from leaf, BeforeEach, AfterEach,
// teardown, and cleanup are captured as source-located failures. The first
// failure is preserved; later cleanup exceptions are still reported.
// Payload: one unique throw string per phase is enough for the oracle to
// attribute the originating phase.
// Expected observations: each suite fails from its documented phase; the
// planned leaf throw is TS-FW-ASSERTIONS-006 leaf exception; cleanup after
// a prior Fail still reports its throw.
// C++ oracle required: phase identity, first-failure preservation, secondary
// cleanup exceptions, and source locations.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceAssertionExceptionsBeforeEachSuite : UAngelscriptTestSuite
{
	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		throw("TS-FW-ASSERTIONS-006 BeforeEach exception");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void LeafMustNotRunAfterBeforeEachThrow()
	{
		Fail("TS-FW-ASSERTIONS-006 leaf ran after BeforeEach exception");
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceAssertionExceptionsAfterEachSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void LeafThenAfterEachThrow()
	{
	}

	UFUNCTION(BlueprintOverride)
	void AfterEach()
	{
		throw("TS-FW-ASSERTIONS-006 AfterEach exception");
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceAssertionExceptionsTeardownSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void LeafThenTeardownThrow()
	{
		FAngelscriptTest::Commands()
			.OnTearDown(n"ThrowFromTearDown");
	}

	void ThrowFromTearDown()
	{
		throw("TS-FW-ASSERTIONS-006 teardown exception");
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceAssertionExceptionsCleanupAfterFailureSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void FailThenCleanupThrow()
	{
		FAngelscriptTest::Commands()
			.OnCleanup(n"ThrowFromCleanup");
		Fail("TS-FW-ASSERTIONS-006 primary leaf failure");
	}

	void ThrowFromCleanup()
	{
		throw("TS-FW-ASSERTIONS-006 cleanup exception");
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceAssertionExceptionsAcrossPhasesSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyAssertionExceptionsAcrossPhases()
	{
		throw("TS-FW-ASSERTIONS-006 leaf exception");
	}
}
/** @end */
