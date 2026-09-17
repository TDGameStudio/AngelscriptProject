/**
 * @version v1
 * @summary TWeakObjectPtr assign and IsValid as Suite usage. Uses SpawnObject, not NewObject.
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TWeakObjectPtr assign and IsValid as Suite usage. Uses SpawnObject, not NewObject.
 * @topic Baseline
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
/** @end */
