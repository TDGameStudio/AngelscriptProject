/**
 * TArray Append, Empty, AddUnique, and Last as Suite usage.
 *
 * @Theme TestFramework.Usage.Containers
 * @Subject TArray.Append
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Containers.ArrayAppendAndEmpty
 * @Provenance TestSource/Containers/TArray/Function/TArrayAppend.as
 * @Provenance TestSource/Containers/TArray/Function/TArrayEmptyClear.as
 * @Provenance TestSource/Containers/TArray/Function/TArrayAddUnique.as
 * @Provenance TestSource/Containers/TArray/Function/TArrayLastValidIndex.as
 */

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UArrayAppendAndEmptyScriptTests : UAngelscriptTestSuite
{
	TArray<int> Values;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		Values.Empty();
	}

	UFUNCTION(meta=(AngelscriptTest))
	void AppendConcatenatesThenEmptyIsNoOp()
	{
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		TArray<int> Tail;
		Tail.Add(4);
		Tail.Add(5);
		Values.Append(Tail);
		AssertEquals(5, Values.Num());
		AssertEquals(4, Values[3]);
		AssertEquals(5, Values[4]);

		TArray<int> EmptyTail;
		Values.Append(EmptyTail);
		AssertEquals(5, Values.Num());
	}

	UFUNCTION(meta=(AngelscriptTest))
	void EmptyClearsThenAllowsAdd()
	{
		Values.Add(1);
		Values.Empty();
		AssertEquals(0, Values.Num());
		Values.Add(2);
		AssertEquals(1, Values.Num());
		AssertEquals(2, Values[0]);
	}

	UFUNCTION(meta=(AngelscriptTest))
	void AddUniqueSkipsDuplicates()
	{
		AssertTrue(Values.AddUnique(5));
		AssertTrue(Values.AddUnique(10));
		AssertFalse(Values.AddUnique(5));
		AssertEquals(2, Values.Num());
		AssertEquals(5, Values[0]);
		AssertEquals(10, Values[1]);
	}

	UFUNCTION(meta=(AngelscriptTest))
	void LastCountsFromTheEnd()
	{
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		AssertEquals(30, Values.Last());
		AssertEquals(30, Values.Last(0));
		AssertEquals(20, Values.Last(1));
		AssertEquals(10, Values.Last(2));
		AssertTrue(Values.IsValidIndex(0));
		AssertTrue(Values.IsValidIndex(2));
		AssertFalse(Values.IsValidIndex(3));
	}
}
