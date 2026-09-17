/**
 * @version v1
 * @summary TMap Add, Num, Contains, index, and Find as Suite usage.
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TMap Add, Num, Contains, index, and Find as Suite usage.
 * @topic Baseline
 */
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UMapAddAndFindScriptTests : UAngelscriptTestSuite
{
	TMap<int, int> Pairs;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		Pairs.Empty();
	}

	UFUNCTION(meta=(AngelscriptTest))
	void AddGrowsNumAndOverwriteKeepsNum()
	{
		Pairs.Add(10, 100);
		AssertEquals(1, Pairs.Num());
		AssertTrue(Pairs.Contains(10));
		AssertEquals(100, Pairs[10]);

		Pairs.Add(20, 200);
		AssertEquals(2, Pairs.Num());
		AssertEquals(100, Pairs[10]);
		AssertEquals(200, Pairs[20]);

		Pairs.Add(10, 999);
		AssertEquals(2, Pairs.Num());
		AssertEquals(999, Pairs[10]);
		AssertEquals(200, Pairs[20]);
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FindCopiesPresentValueAndMissesAbsent()
	{
		Pairs.Add(10, 100);
		Pairs.Add(20, 200);

		int Found = 0;
		AssertTrue(Pairs.Find(10, Found));
		AssertEquals(100, Found);

		int Miss = 0;
		AssertFalse(Pairs.Find(99, Miss));
	}
}
/** @end */
