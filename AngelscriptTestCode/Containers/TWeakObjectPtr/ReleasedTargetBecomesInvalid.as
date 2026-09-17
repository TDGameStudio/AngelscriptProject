/**
 * @version v1
 * @summary After the target is collected, the weak pointer is invalid and Get is nullptr.
 * @topic Containers
 *
 * ReleasedTargetBecomesInvalid
 */
/**
 * @begin ReleasedTargetBecomesInvalid
 * @summary After the target is collected, the weak pointer is invalid and Get is nullptr.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrInvalidationObject : UObject
{
}

bool ReleasedTargetBecomesInvalid()
{
	TWeakObjectPtr<UObject> Weak;

	{
		UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrInvalidationObject::StaticClass(), n"TWeakObjInvalid_Target", true);
		if (Target == nullptr)
		{
			return false;
		}

		Weak = Target;
		if (!Weak.IsValid() || Weak.Get() != Target)
		{
			return false;
		}
	}

	CollectGarbage();

	return !Weak.IsValid() && Weak.Get() == nullptr;
}
/** @end */
