// Framework contract: every marked leaf receives a fresh suite instance.
// BeforeAll/AfterAll use a separate session instance whose mutations are
// absent from method fixtures. Leaf identities are distinct.
// Payload: two leaves mutate the same field names and compare initial
// values. Identity versus the all-hook instance cannot be AssertSame'd
// from a method leaf, so the oracle must compare instances.
// Expected observations: each leaf starts at MutatedValue==0 and
// SuiteScopeValue==0; neither leaf sees the other's 11/22 write.
// C++ oracle required: distinct method-instance identities, all-hook
// instance identity, and no cross-leaf fixture leakage.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceFreshSuiteInstancesSuite : UAngelscriptTestSuite
{
	int SuiteScopeValue = 0;
	int MutatedValue = 0;
	UObject RecordedIdentity;

	UFUNCTION(BlueprintOverride)
	void BeforeAll()
	{
		SuiteScopeValue = 100;
		MutatedValue = 50;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyFreshSuiteInstances()
	{
		RecordedIdentity = this;
		AssertEquals(0, SuiteScopeValue, "TS-FW-LIFECYCLE-002 first leaf saw all-hook SuiteScopeValue");
		AssertEquals(0, MutatedValue, "TS-FW-LIFECYCLE-002 first leaf saw stale mutation");
		MutatedValue = 11;
		AssertSame(this, RecordedIdentity, "TS-FW-LIFECYCLE-002 first leaf identity payload");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyFreshSuiteInstancesSecondLeaf()
	{
		RecordedIdentity = this;
		AssertEquals(0, SuiteScopeValue, "TS-FW-LIFECYCLE-002 second leaf saw all-hook SuiteScopeValue");
		AssertEquals(0, MutatedValue, "TS-FW-LIFECYCLE-002 second leaf saw first leaf mutation");
		MutatedValue = 22;
		AssertSame(this, RecordedIdentity, "TS-FW-LIFECYCLE-002 second leaf identity payload");
	}

	UFUNCTION(BlueprintOverride)
	void AfterAll()
	{
		SuiteScopeValue = 0;
		MutatedValue = 0;
	}
}
