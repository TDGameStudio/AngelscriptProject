/**
 * TArray Insert, Remove, and RemoveAt as Suite usage.
 *
 * @Theme TestFramework.Usage.Containers
 * @Subject TArray.Insert
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Containers.ArrayInsertAndRemove
 * @Provenance TestSource/Containers/TArray/Function/TArrayInsert.as
 * @Provenance TestSource/Containers/TArray/Function/TArrayRemove.as
 * @Provenance TestSource/Containers/TArray/Function/TArrayRemoveAt.as
 */

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UArrayInsertAndRemoveScriptTests : UAngelscriptTestSuite
{
	TArray<int> Values;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		Values.Empty();
	}

	UFUNCTION(meta=(AngelscriptTest))
	void InsertAtMiddleHeadAndEnd()
	{
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);

		Values.Insert(15, 1);
		AssertEquals(4, Values.Num());
		AssertEquals(10, Values[0]);
		AssertEquals(15, Values[1]);
		AssertEquals(20, Values[2]);

		Values.Insert(5, 0);
		AssertEquals(5, Values[0]);
		AssertEquals(10, Values[1]);

		Values.Insert(35, Values.Num());
		AssertEquals(35, Values[Values.Num() - 1]);
		AssertEquals(6, Values.Num());
	}

	UFUNCTION(meta=(AngelscriptTest))
	void RemoveDeletesEveryMatch()
	{
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.Add(2);
		Values.Add(4);
		Values.Add(2);
		Values.Add(5);
		int Removed = Values.Remove(2);
		AssertEquals(3, Removed);
		AssertEquals(4, Values.Num());
		AssertEquals(1, Values[0]);
		AssertEquals(3, Values[1]);
		AssertEquals(4, Values[2]);
		AssertEquals(5, Values[3]);
	}

	UFUNCTION(meta=(AngelscriptTest))
	void RemoveAtShiftsLaterElements()
	{
		Values.Add(1);
		Values.Add(2);
		Values.RemoveAt(0);
		AssertEquals(1, Values.Num());
		AssertEquals(2, Values[0]);
	}
}
