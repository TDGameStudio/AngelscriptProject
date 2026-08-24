// Framework contract: Commands().Do and Then enqueue named actions FIFO.
// Descriptions remain attached to the queue entries. The final callback sees
// the complete ordered observation list.
// Payload: appending distinct tokens First/Second/Third is enough; values
// are incidental markers for the oracle trace.
// Expected observations: actions run First then Second then VerifyFifoOrder;
// ObservedTrace equals First;Second;Third; descriptions stay with enqueue.
// C++ oracle required: FIFO order, attached descriptions, and that the
// final callback ran on this leaf.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceDoThenFifoSuite : UAngelscriptTestSuite
{
	FString ObservedTrace;
	TArray<FString> Observations;

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyDoThenFifo()
	{
		FAngelscriptTest::Commands()
			.Do(n"AppendFirst", "first fifo action")
			.Then(n"AppendSecond", "second fifo action")
			.Then(n"AppendThird", "third fifo action")
			.Then(n"VerifyFifoOrder", "final fifo callback");
	}

	void AppendFirst()
	{
		Observations.Add("First");
		ObservedTrace += "First;";
	}

	void AppendSecond()
	{
		Observations.Add("Second");
		ObservedTrace += "Second;";
	}

	void AppendThird()
	{
		Observations.Add("Third");
		ObservedTrace += "Third;";
	}

	void VerifyFifoOrder()
	{
		AssertEquals(3, Observations.Num(), "TS-FW-COMMANDS-001 fifo observation count");
		AssertEquals("First;", Observations[0] + ";", "TS-FW-COMMANDS-001 fifo first");
		AssertEquals("Second;", Observations[1] + ";", "TS-FW-COMMANDS-001 fifo second");
		AssertEquals("Third;", Observations[2] + ";", "TS-FW-COMMANDS-001 fifo third");
		AssertEquals(
			"First;Second;Third;",
			ObservedTrace,
			"TS-FW-COMMANDS-001 fifo concatenated trace");
	}
}
