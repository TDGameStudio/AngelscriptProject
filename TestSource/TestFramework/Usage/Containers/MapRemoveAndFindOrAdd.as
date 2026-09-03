/**
 * TMap Remove and FindOrAdd as Suite usage.
 *
 * @Theme TestFramework.Usage.Containers
 * @Subject TMap.Remove
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Containers.MapRemoveAndFindOrAdd
 * @Provenance TestSource/Containers/TMap/Function/TMapRemove.as
 * @Provenance TestSource/Containers/TMap/Function/TMapFindOrAdd.as
 */

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UMapRemoveAndFindOrAddScriptTests : UAngelscriptTestSuite
{
	TMap<int, int> Pairs;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		Pairs.Empty();
	}

	UFUNCTION(meta=(AngelscriptTest))
	void RemovePresentAndMissAbsent()
	{
		Pairs.Add(10, 100);
		Pairs.Add(20, 200);
		Pairs.Add(30, 300);
		AssertTrue(Pairs.Remove(20));
		AssertFalse(Pairs.Contains(20));
		AssertEquals(2, Pairs.Num());
		AssertFalse(Pairs.Remove(99));
		AssertTrue(Pairs.Contains(10));
		AssertTrue(Pairs.Contains(30));
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FindOrAddHitsOrInsertsDefault()
	{
		Pairs.Add(10, 100);
		Pairs.FindOrAdd(10) += 50;
		Pairs.FindOrAdd(20) += 200;
		AssertEquals(2, Pairs.Num());
		AssertEquals(150, Pairs[10]);
		AssertEquals(200, Pairs[20]);
	}
}
