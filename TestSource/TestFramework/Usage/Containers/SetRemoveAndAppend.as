/**
 * TSet Remove and Append(TArray) as Suite usage.
 *
 * @Theme TestFramework.Usage.Containers
 * @Subject TSet.Remove
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Containers.SetRemoveAndAppend
 * @Provenance TestSource/Containers/TSet/Function/TSetRemove.as
 * @Provenance TestSource/Containers/TSet/Function/TSetAppend.as
 */

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class USetRemoveAndAppendScriptTests : UAngelscriptTestSuite
{
	TSet<int> Values;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		Values.Empty();
	}

	UFUNCTION(meta=(AngelscriptTest))
	void RemovePresentAndMissAbsent()
	{
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		AssertTrue(Values.Remove(20));
		AssertFalse(Values.Contains(20));
		AssertEquals(2, Values.Num());
		AssertFalse(Values.Remove(99));
		AssertTrue(Values.Contains(10));
		AssertTrue(Values.Contains(30));
	}

	UFUNCTION(meta=(AngelscriptTest))
	void AppendArrayInsertsUnique()
	{
		TArray<int> Source;
		Source.Add(10);
		Source.Add(20);
		Source.Add(10);
		Values.Append(Source);
		AssertEquals(2, Values.Num());
		AssertTrue(Values.Contains(10));
		AssertTrue(Values.Contains(20));
	}
}
