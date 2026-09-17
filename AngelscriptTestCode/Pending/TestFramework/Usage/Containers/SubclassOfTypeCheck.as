/**
 * @version v1
 * @summary TSubclassOf assign, IsValid, and IsChildOf as Suite usage.
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TSubclassOf assign, IsValid, and IsChildOf as Suite usage.
 * @topic Baseline
 */
UCLASS()
class USubclassOfUsageBase : UObject
{
}

UCLASS()
class USubclassOfUsageDerived : USubclassOfUsageBase
{
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class USubclassOfTypeCheckScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void DerivedIsChildOfBase()
	{
		TSubclassOf<UObject> Class;
		AssertFalse(Class.IsValid());
		Class = USubclassOfUsageDerived::StaticClass();
		AssertTrue(Class.IsValid());
		AssertTrue(Class.IsChildOf(USubclassOfUsageBase::StaticClass()));
		AssertTrue(Class.IsChildOf(USubclassOfUsageDerived::StaticClass()));
	}
}
/** @end */
