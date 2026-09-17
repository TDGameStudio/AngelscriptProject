/**
 * @version v1
 * @summary A weak pointer does not keep its target alive through garbage collection.
 * @topic Containers
 *
 * WeakReferenceDoesNotKeepTargetAlive
 */
/**
 * @begin WeakReferenceDoesNotKeepTargetAlive
 * @summary A weak pointer does not keep its target alive through garbage collection.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrInvalidationObject : UObject
{
}

bool WeakReferenceDoesNotKeepTargetAlive()
{
	TWeakObjectPtr<UObject> Weak;

	{
		UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrInvalidationObject::StaticClass(), n"TWeakObjInvalid_Reach", true);
		if (Target == nullptr)
		{
			return false;
		}

		Weak = Target;
	}

	CollectGarbage();

	return Weak.Get() == nullptr && !Weak.IsValid();
}
/** @end */
