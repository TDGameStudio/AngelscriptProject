/**
 * TSet Add, Num, and Contains as Suite usage. Duplicate Add keeps Num.
 *
 * @Theme TestFramework.Usage.Containers
 * @Subject TSet.Add
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Containers.SetAddAndContains
 * @Provenance TestSource/Containers/TSet/Function/TSetAdd.as
 * @Provenance TestSource/Containers/TSet/Function/TSetContains.as
 * @Provenance TestSource/Containers/TSet/Function/TSetNum.as
 */

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class USetAddAndContainsScriptTests : UAngelscriptTestSuite
{
	TSet<int> Values;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		Values.Empty();
	}

	UFUNCTION(meta=(AngelscriptTest))
	void AddInsertsAndDuplicateKeepsNum()
	{
		Values.Add(10);
		AssertEquals(1, Values.Num());
		AssertTrue(Values.Contains(10));

		Values.Add(20);
		AssertEquals(2, Values.Num());
		AssertTrue(Values.Contains(20));
		AssertTrue(Values.Contains(10));

		Values.Add(10);
		AssertEquals(2, Values.Num());
		AssertFalse(Values.Contains(99));
	}
}
