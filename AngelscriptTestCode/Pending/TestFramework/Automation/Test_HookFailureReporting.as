/**
 * @version v1
 * @summary TestFramework Automation Test_HookFailureReporting
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework Automation Test_HookFailureReporting
 * @topic Baseline
 */
// Framework contract: BeforeAll failure skips leaves but still closes the
// section session. AfterAll failure is counted after leaves. All-hooks may
// not call FAngelscriptTest leaf helpers.
// Payload: unique throw/Fail strings per suite distinguish skip, AfterAll,
// and facade-misuse diagnostics.
// Expected observations: skipped leaves never run their Fail bodies;
// AfterAll throw is TS-FW-AUTOMATION-002 AfterAll exception; facade misuse
// reports at BeforeAll.
// C++ oracle required: skip vs run, session close, AfterAll counting, and
// explicit facade diagnostics.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceHookFailureAfterAllSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void PassingLeafBeforeAfterAllFailure()
	{
		AssertTrue(true, "TS-FW-AUTOMATION-002 AfterAll suite leaf payload");
	}

	UFUNCTION(BlueprintOverride)
	void AfterAll()
	{
		throw("TS-FW-AUTOMATION-002 AfterAll exception");
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceHookFailureFacadeMisuseSuite : UAngelscriptTestSuite
{
	UFUNCTION(BlueprintOverride)
	void BeforeAll()
	{
		FAngelscriptTest::CreateTestWorld();
	}

	UFUNCTION(meta=(AngelscriptTest))
	void MustNotRunAfterFacadeMisuse()
	{
		Fail("TS-FW-AUTOMATION-002 leaf ran after all-hook facade misuse");
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceHookFailureReportingSuite : UAngelscriptTestSuite
{
	UFUNCTION(BlueprintOverride)
	void BeforeAll()
	{
		throw("TS-FW-AUTOMATION-002 BeforeAll exception");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyHookFailureReporting()
	{
		Fail("TS-FW-AUTOMATION-002 leaf ran after BeforeAll failure");
	}

	UFUNCTION(BlueprintOverride)
	void AfterAll()
	{
	}
}
/** @end */
