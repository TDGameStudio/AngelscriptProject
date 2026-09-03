/**
 * TSubclassOf assign, IsValid, and IsChildOf as Suite usage.
 *
 * @Theme TestFramework.Usage.Containers
 * @Subject TSubclassOf.IsChildOf
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Containers.SubclassOfTypeCheck
 * @Provenance TestSource/Containers/TSubclassOf/Function/TSubclassOfTypeCheck.as
 * @Provenance TestSource/Containers/TSubclassOf/Function/TSubclassOfAssign.as
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
