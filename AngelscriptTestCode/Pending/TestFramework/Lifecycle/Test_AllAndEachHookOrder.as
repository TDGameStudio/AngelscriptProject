/**
 * @version v1
 * @summary TestFramework Lifecycle Test_AllAndEachHookOrder
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework Lifecycle Test_AllAndEachHookOrder
 * @topic Baseline
 */
// Framework contract: BeforeAll runs once on a suite-scope instance. Each
// marked leaf gets a fresh method instance bracketed by BeforeEach and
// AfterEach. AfterAll runs once on the suite-scope instance.
// Payload: integer phase markers on both instance kinds are enough to show
// isolation; they do not prove global order by themselves.
// Expected observations: each leaf sees BeforeEachCount==1, AfterEachCount==0,
// and SuiteScopeValue==0. AfterEach then mutates the method instance.
// C++ oracle required: BeforeAll once, AfterAll once, two-leaf bracketing
// order, and that all-hook state never appears on method instances.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceAllAndEachHookOrderSuite : UAngelscriptTestSuite
{
	int SuiteScopeValue = 0;
	int BeforeEachCount = 0;
	int AfterEachCount = 0;
	int PerLeafValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeforeAll()
	{
		SuiteScopeValue = 100;
	}

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		BeforeEachCount += 1;
		PerLeafValue = 10;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyAllAndEachHookOrder()
	{
		AssertEquals(0, SuiteScopeValue, "TS-FW-LIFECYCLE-001 all-hook state leaked into first leaf");
		AssertEquals(1, BeforeEachCount, "TS-FW-LIFECYCLE-001 first leaf BeforeEach count");
		AssertEquals(0, AfterEachCount, "TS-FW-LIFECYCLE-001 first leaf saw AfterEach early");
		AssertEquals(10, PerLeafValue, "TS-FW-LIFECYCLE-001 first leaf fixture");
		PerLeafValue = 20;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyAllAndEachHookOrderSecondLeaf()
	{
		AssertEquals(0, SuiteScopeValue, "TS-FW-LIFECYCLE-001 all-hook state leaked into second leaf");
		AssertEquals(1, BeforeEachCount, "TS-FW-LIFECYCLE-001 second leaf BeforeEach count");
		AssertEquals(0, AfterEachCount, "TS-FW-LIFECYCLE-001 second leaf saw AfterEach early");
		AssertEquals(10, PerLeafValue, "TS-FW-LIFECYCLE-001 second leaf fixture");
	}

	UFUNCTION(BlueprintOverride)
	void AfterEach()
	{
		AfterEachCount += 1;
		PerLeafValue = 99;
	}

	UFUNCTION(BlueprintOverride)
	void AfterAll()
	{
		SuiteScopeValue = 0;
	}
}
/** @end */
