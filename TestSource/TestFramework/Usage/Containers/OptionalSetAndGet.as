/**
 * TOptional Set, IsSet, GetValue, and Reset as Suite usage.
 *
 * @Theme TestFramework.Usage.Containers
 * @Subject TOptional.Set
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Containers.OptionalSetAndGet
 * @Provenance TestSource/Containers/TOptional/Function/TOptionalSet.as
 * @Provenance TestSource/Containers/TOptional/Function/TOptionalIsSet.as
 * @Provenance TestSource/Containers/TOptional/Function/TOptionalGetValue.as
 * @Provenance TestSource/Containers/TOptional/Function/TOptionalReset.as
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
