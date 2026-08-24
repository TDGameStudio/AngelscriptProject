// Framework contract: a compact passing suite may combine lifecycle,
// assertion, command, and World APIs. This is a self-hosted smoke of the
// reflected protocol, not of arithmetic/World payloads.
// Payload: 40+2, one plain object, one 0.01s delay, and explicit World
// create/destroy are enough to touch each surface once.
// Expected observations: the future C++ oracle sees the expected leaf
// count with zero failures and all phase markers complete.
// C++ oracle required: leaf count, zero failures, BeforeEach/AfterEach/
// command/World cleanup order. Do not treat these assertions as the suite
// result.

UCLASS()
class UTestSourceSelfHostedSmokeObject : UObject
{
	int Value = 0;
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceFrameworkSelfHostedSmokeSuite : UAngelscriptTestSuite
{
	int BeforeEachCount = 0;
	int AfterEachCount = 0;
	bool bReady = false;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		BeforeEachCount += 1;
		FAngelscriptTest::Commands()
			.OnCleanup(n"RecordSmokeCleanup");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyFrameworkSelfHostedSmoke()
	{
		AssertEquals(42, 40 + 2, "TS-FW-SELFHOSTED-001 arithmetic payload");
		AssertEquals(1, BeforeEachCount, "TS-FW-SELFHOSTED-001 BeforeEach");
		UTestSourceSelfHostedSmokeObject Object =
			Cast<UTestSourceSelfHostedSmokeObject>(
				FAngelscriptTest::SpawnObject(
					UTestSourceSelfHostedSmokeObject::StaticClass()));
		AssertNotNull(Object, "TS-FW-SELFHOSTED-001 missing object");
		AssertSame(this, Object.GetOuter(), "TS-FW-SELFHOSTED-001 object outer");
		FAngelscriptTest::CreateTestWorld(false);
		AssertNotNull(FAngelscriptTest::GetTestWorld(), "TS-FW-SELFHOSTED-001 missing World");
		FAngelscriptTest::DestroyTestWorld();
		AssertNull(FAngelscriptTest::GetTestWorld(), "TS-FW-SELFHOSTED-001 World survived");
		FAngelscriptTest::Commands()
			.WaitDelay(0.01, "TS-FW-SELFHOSTED-001 delay")
			.Then(n"MarkSmokeReady")
			.Until(n"IsSmokeReady", 1.0, "TS-FW-SELFHOSTED-001 ready");
	}

	void MarkSmokeReady()
	{
		bReady = true;
	}

	bool IsSmokeReady()
	{
		return bReady;
	}

	void RecordSmokeCleanup()
	{
		AfterEachCount += 1;
	}

	UFUNCTION(BlueprintOverride)
	void AfterEach()
	{
		AssertEquals(0, AfterEachCount, "TS-FW-SELFHOSTED-001 cleanup ran before AfterEach");
	}
}
