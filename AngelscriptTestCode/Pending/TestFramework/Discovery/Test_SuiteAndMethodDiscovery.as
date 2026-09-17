/**
 * @version v1
 * @summary TestFramework Discovery Test_SuiteAndMethodDiscovery
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework Discovery Test_SuiteAndMethodDiscovery
 * @topic Baseline
 */
// Framework contract: discovery publishes only direct marked void() methods
// on concrete UAngelscriptTestSuite classes. Unmarked helpers, abstract
// bases, inherited-only children, and unrelated UObject markers are inputs
// that must not become extra leaves.
// Payload: incidental identity/arithmetic checks give the future C++ oracle
// unique messages and source locations without proving registry behavior.
// Expected observations: exactly the marked leaves below keep stable
// suite/method identity and source-line order.
// C++ oracle required: leaf count, descriptor order, omission of unmarked
// and inherited methods, and Automation names. Do not treat AS assertions
// as the discovery result.

UCLASS(Abstract, meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceSuiteAndMethodDiscoveryAbstractSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void InheritedMarkedMethodIsNotADirectLeaf()
	{
		AssertTrue(true, "TS-FW-DISCOVERY-001 abstract marked helper");
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceSuiteAndMethodDiscoveryInheritedOnlySuite : UTestSourceSuiteAndMethodDiscoveryAbstractSuite
{
}

UCLASS()
class UTestSourceSuiteAndMethodDiscoveryUnrelatedObject : UObject
{
	UFUNCTION(meta=(AngelscriptTest))
	void UnrelatedMarkedMethodIsNotASuiteLeaf()
	{
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceSuiteAndMethodDiscoverySecondSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifySecondDiscoveredSuiteLeaf()
	{
		AssertEquals(2, 1 + 1, "TS-FW-DISCOVERY-001 second suite payload");
	}

	void UnmarkedSecondSuiteHelper()
	{
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceSuiteAndMethodDiscoverySuite : UAngelscriptTestSuite
{
	void UnmarkedDiscoveryHelper()
	{
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifySuiteAndMethodDiscovery()
	{
		AssertEquals(3, 1 + 2, "TS-FW-DISCOVERY-001 first marked leaf payload");
		UnmarkedDiscoveryHelper();
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifySecondMarkedDiscoveryLeaf()
	{
		AssertEquals(4, 2 + 2, "TS-FW-DISCOVERY-001 second marked leaf payload");
	}
}
/** @end */
