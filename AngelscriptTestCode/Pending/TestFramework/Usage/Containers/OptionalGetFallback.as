/**
 * @version v1
 * @summary TOptional.Get returns the value when set and the fallback when unset.
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TOptional.Get returns the value when set and the fallback when unset.
 * @topic Baseline
 */
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UOptionalGetFallbackScriptTests : UAngelscriptTestSuite
{
	TOptional<int> Opt;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		Opt.Reset();
	}

	UFUNCTION(meta=(AngelscriptTest))
	void GetReturnsValueWhenSet()
	{
		Opt.Set(42);
		AssertEquals(42, Opt.Get(7));
		AssertTrue(Opt.IsSet());
	}

	UFUNCTION(meta=(AngelscriptTest))
	void GetReturnsFallbackWhenUnset()
	{
		AssertFalse(Opt.IsSet());
		AssertEquals(7, Opt.Get(7));
		AssertFalse(Opt.IsSet());
	}
}
/** @end */
