/**
 * @version v1
 * @summary TOptional Set, IsSet, GetValue, and Reset as Suite usage.
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TOptional Set, IsSet, GetValue, and Reset as Suite usage.
 * @topic Baseline
 */
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UOptionalSetAndGetScriptTests : UAngelscriptTestSuite
{
	TOptional<int> Opt;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		Opt.Reset();
	}

	UFUNCTION(meta=(AngelscriptTest))
	void SetStoresValueAndMarksSet()
	{
		AssertFalse(Opt.IsSet());
		Opt.Set(42);
		AssertTrue(Opt.IsSet());
		AssertEquals(42, Opt.GetValue());
	}

	UFUNCTION(meta=(AngelscriptTest))
	void ResetUnsetsAfterSet()
	{
		Opt.Set(42);
		AssertTrue(Opt.IsSet());
		Opt.Reset();
		AssertFalse(Opt.IsSet());
		Opt.Set(7);
		AssertTrue(Opt.IsSet());
		AssertEquals(7, Opt.GetValue());
	}
}
/** @end */
