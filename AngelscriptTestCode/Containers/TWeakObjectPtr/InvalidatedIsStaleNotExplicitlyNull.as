/**
 * @version v1
 * @summary After invalidation, the weak pointer is stale and not explicitly null.
 * @topic Containers
 *
 * InvalidatedIsStaleNotExplicitlyNull
 */
/**
 * @begin InvalidatedIsStaleNotExplicitlyNull
 * @summary After invalidation, the weak pointer is stale and not explicitly null.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrInvalidationObject : UObject
{
}

bool InvalidatedIsStaleNotExplicitlyNull()
{
	TWeakObjectPtr<UObject> Weak;

	{
		UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrInvalidationObject::StaticClass(), n"TWeakObjInvalid_Stale", true);
		if (Target == nullptr)
		{
			return false;
		}

		Weak = Target;
	}

	CollectGarbage();

	return Weak.IsStale() && !Weak.IsExplicitlyNull();
}
/** @end */
