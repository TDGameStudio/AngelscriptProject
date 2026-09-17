/**
 * @version v1
 * @summary TArray Add, Num, index, Contains, and FindIndex as Suite usage.
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TArray Add, Num, index, Contains, and FindIndex as Suite usage.
 * @topic Baseline
 */
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UArrayAddAndNumScriptTests : UAngelscriptTestSuite
{
	TArray<int> Values;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		Values.Empty();
	}

	UFUNCTION(meta=(AngelscriptTest))
	void AddThenNumAndIndexMatchInsertionOrder()
	{
		Values.Add(10);
		AssertEquals(1, Values.Num());
		AssertEquals(10, Values[0]);

		Values.Add(20);
		AssertEquals(2, Values.Num());
		AssertEquals(10, Values[0]);
		AssertEquals(20, Values[1]);

		Values.Add(30);
		AssertEquals(3, Values.Num());
		AssertEquals(30, Values[2]);
	}

	UFUNCTION(meta=(AngelscriptTest))
	void ContainsPresentAndMissesAbsent()
	{
		AssertFalse(Values.Contains(5));
		Values.Add(5);
		Values.Add(9);
		AssertTrue(Values.Contains(5));
		AssertTrue(Values.Contains(9));
		AssertFalse(Values.Contains(1));
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FindIndexHitsFirstDuplicateAndMisses()
	{
		Values.Add(100);
		Values.Add(200);
		Values.Add(300);
		Values.Add(200);
		AssertEquals(0, Values.FindIndex(100));
		AssertEquals(1, Values.FindIndex(200));
		AssertEquals(2, Values.FindIndex(300));
		AssertEquals(-1, Values.FindIndex(999));
	}
}
/** @end */
