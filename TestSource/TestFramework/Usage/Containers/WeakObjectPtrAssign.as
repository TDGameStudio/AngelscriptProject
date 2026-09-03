/**
 * TWeakObjectPtr assign and IsValid as Suite usage. Uses SpawnObject, not NewObject.
 *
 * @Theme TestFramework.Usage.Containers
 * @Subject TWeakObjectPtr.IsValid
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Containers.WeakObjectPtrAssign
 * @Provenance TestSource/Containers/TWeakObjectPtr/Function/TWeakObjectPtrValidity.as
 * @Provenance TestSource/Containers/TWeakObjectPtr/Function/TWeakObjectPtrAssign.as
 */

UCLASS()
class UWeakObjectPtrUsageObject : UObject
{
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UWeakObjectPtrAssignScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void LiveTargetIsValidNotExplicitlyNull()
	{
		UObject Target = FAngelscriptTest::SpawnObject(UWeakObjectPtrUsageObject::StaticClass());
		AssertNotNull(Target);

		TWeakObjectPtr<UObject> Weak;
		AssertTrue(Weak.IsExplicitlyNull());
		AssertFalse(Weak.IsValid());

		Weak = Target;
		AssertTrue(Weak.IsValid());
		AssertFalse(Weak.IsStale());
		AssertFalse(Weak.IsExplicitlyNull());
		AssertNotNull(Weak.Get());
	}

	UFUNCTION(meta=(AngelscriptTest))
	void NullAssignIsExplicitlyNull()
	{
		TWeakObjectPtr<UObject> Weak;
		Weak = nullptr;
		AssertFalse(Weak.IsValid());
		AssertTrue(Weak.IsExplicitlyNull());
		AssertNull(Weak.Get());
	}
}
