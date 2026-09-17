/**
 * @version v1
 * @summary TestFramework Discovery Test_AutomationFlagsAndDisabledCases
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework Discovery Test_AutomationFlagsAndDisabledCases
 * @topic Baseline
 */
// Framework contract: AngelscriptTestFlags is an exact UE Automation mask.
// Valid multi-token masks remain on published descriptors. Unknown tokens
// are diagnosed. Disabled is discoverable and must never execute.
// Payload: eligible leaves use a silent true check so the oracle can still
// count source locations. The Disabled leaf carries a unique Fail message
// that must not appear if execution is skipped.
// Expected observations: valid masks stay exact; the invalid token set is
// omitted with a diagnostic; the Disabled leaf is present but not run.
// C++ oracle required: parsed flag bits, diagnostic text/line, Disabled
// publication, and zero execution of the Disabled body.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;UnknownFlag;EngineFilter"))
class UTestSourceAutomationFlagsInvalidTokenSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyInvalidFlagTokenIsOmitted()
	{
		Fail("TS-FW-DISCOVERY-002 invalid token leaf must not execute");
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;Disabled;EngineFilter"))
class UTestSourceAutomationFlagsDisabledSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyDisabledLeafIsDiscoverableButNotExecuted()
	{
		Fail("TS-FW-DISCOVERY-002 Disabled leaf must not execute");
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;ClientContext;ServerContext;CommandletContext;EngineFilter"))
class UTestSourceAutomationFlagsAndDisabledCasesSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyAutomationFlagsAndDisabledCases()
	{
		AssertTrue(true, "TS-FW-DISCOVERY-002 eligible multi-context leaf payload");
	}
}
/** @end */
