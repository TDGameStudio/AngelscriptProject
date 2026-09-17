/**
 * @version v1
 * @summary TestFramework Automation Test_FlagBridgeAndSectionSession
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework Automation Test_FlagBridgeAndSectionSession
 * @topic Baseline
 */
// Framework contract: exact flag masks build persistent deterministic
// Automation bridges. A suite section shares one all-hook session instance
// across leaves without sharing method instances.
// Payload: one EditorContext;EngineFilter suite with two leaves and one
// ClientContext;ProductFilter suite provide two sections and two masks.
// BeforeAll writes 100 on the session instance; method leaves must still
// see 0.
// Expected observations: flags remain exact; both editor leaves are
// distinct; session state does not appear on method instances.
// C++ oracle required: bridge identity/persistence, section session
// sharing, and descriptor stability across rebuild.

UCLASS(meta=(AngelscriptTestFlags="ClientContext;ProductFilter"))
class UTestSourceFlagBridgeClientSectionSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyClientSectionLeaf()
	{
		AssertTrue(true, "TS-FW-AUTOMATION-001 client section payload");
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceFlagBridgeAndSectionSessionSuite : UAngelscriptTestSuite
{
	int SuiteScopeValue = 0;
	int LeafToken = 0;

	UFUNCTION(BlueprintOverride)
	void BeforeAll()
	{
		SuiteScopeValue = 100;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyFlagBridgeAndSectionSession()
	{
		AssertEquals(0, SuiteScopeValue, "TS-FW-AUTOMATION-001 first leaf saw session state");
		LeafToken = 1;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifySecondSectionLeaf()
	{
		AssertEquals(0, SuiteScopeValue, "TS-FW-AUTOMATION-001 second leaf saw session state");
		AssertEquals(0, LeafToken, "TS-FW-AUTOMATION-001 second leaf shared first instance");
		LeafToken = 2;
	}

	UFUNCTION(BlueprintOverride)
	void AfterAll()
	{
		SuiteScopeValue = 0;
	}
}
/** @end */
