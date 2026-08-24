// Framework contract: command callbacks route to the owning leaf instance.
// Enqueue during an active callback, zero/negative/excessive timeouts, and
// stale/moved builders fail at their call sites without corrupting other
// queues.
// Payload: two waiting leaves, one mutating callback, and dedicated timeout
// leaves provide unique messages for the oracle.
// Expected observations: waiting leaves spawn objects outered to this;
// illegal mutations do not run NeverRuns; timeout leaves fail at enqueue.
// C++ oracle required: per-leaf routing, call-site diagnostics, and that
// the other waiting queue still completes.

UCLASS()
class UTestSourceCommandScopeObject : UObject
{
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceCommandScopeAndQueueMutationErrorsSuite : UAngelscriptTestSuite
{
	FAngelscriptTestCommandBuilder RetainedBuilder;
	int ScopeToken = 0;

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyCommandScopeAndQueueMutationErrors()
	{
		RetainedBuilder = FAngelscriptTest::Commands();
		RetainedBuilder.Until(n"NeverReady", 0.0, "TS-FW-COMMANDS-005 zero timeout");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailNegativeTimeout()
	{
		FAngelscriptTest::Commands()
			.Until(n"NeverReady", -1.0, "TS-FW-COMMANDS-005 negative timeout");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailExcessiveTimeout()
	{
		FAngelscriptTest::Commands()
			.Until(n"NeverReady", 15.01, "TS-FW-COMMANDS-005 excessive timeout");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailActiveQueueMutation()
	{
		FAngelscriptTest::Commands()
			.Do(n"MutateQueue")
			.OnCleanup(n"MutationCleanup");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FirstWaitingLeaf()
	{
		ScopeToken = 1;
		FAngelscriptTest::Commands()
			.Do(n"VerifyFirstScope")
			.Until(n"AlwaysReady", 1.0, "first waiting leaf");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void SecondWaitingLeaf()
	{
		ScopeToken = 2;
		FAngelscriptTest::Commands()
			.Do(n"VerifySecondScope")
			.Until(n"AlwaysReady", 1.0, "second waiting leaf");
	}

	void MutateQueue()
	{
		FAngelscriptTest::Commands()
			.Then(n"NeverRuns");
	}

	void NeverRuns()
	{
		Fail("TS-FW-COMMANDS-005 mutated command unexpectedly ran");
	}

	void MutationCleanup()
	{
	}

	void VerifyFirstScope()
	{
		UObject Object = FAngelscriptTest::SpawnObject(
			UTestSourceCommandScopeObject::StaticClass());
		AssertSame(this, Object.GetOuter(), "TS-FW-COMMANDS-005 first leaf outer");
		AssertEquals(1, ScopeToken, "TS-FW-COMMANDS-005 first leaf token");
	}

	void VerifySecondScope()
	{
		UObject Object = FAngelscriptTest::SpawnObject(
			UTestSourceCommandScopeObject::StaticClass());
		AssertSame(this, Object.GetOuter(), "TS-FW-COMMANDS-005 second leaf outer");
		AssertEquals(2, ScopeToken, "TS-FW-COMMANDS-005 second leaf token");
	}

	bool NeverReady()
	{
		return false;
	}

	bool AlwaysReady()
	{
		return true;
	}
}
