/**
 * TMap GetKeys copies keys; membership is asserted, not iteration order.
 *
 * @Theme TestFramework.Usage.Containers
 * @Subject TMap.GetKeys
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Containers.MapGetKeys
 * @Provenance TestSource/Containers/TMap/Function/TMapGetKeysValues.as
 */

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UMapGetKeysScriptTests : UAngelscriptTestSuite
{
	TMap<int, int> Pairs;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		Pairs.Empty();
	}

	UFUNCTION(meta=(AngelscriptTest))
	void GetKeysContainsEveryKey()
	{
		Pairs.Add(10, 100);
		Pairs.Add(20, 200);
		Pairs.Add(30, 300);
		TArray<int> Keys;
		Pairs.GetKeys(Keys);
		AssertEquals(3, Keys.Num());
		AssertTrue(Keys.Contains(10));
		AssertTrue(Keys.Contains(20));
		AssertTrue(Keys.Contains(30));
	}
}
