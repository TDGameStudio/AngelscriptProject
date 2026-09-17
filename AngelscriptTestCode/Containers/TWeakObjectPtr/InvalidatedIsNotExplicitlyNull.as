/**
 * @version v1
 * @summary A collected target leaves the pointer invalid and not explicitly null.
 * @topic Containers
 *
 * InvalidatedIsNotExplicitlyNull
 */
/**
 * @begin InvalidatedIsNotExplicitlyNull
 * @summary A collected target leaves the pointer invalid and not explicitly null.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrInvalidationObject : UObject
{
}

bool InvalidatedIsNotExplicitlyNull()
{
	TWeakObjectPtr<UObject> Weak;

	{
		UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrInvalidationObject::StaticClass(), n"TWeakObjInvalid_NotNull", true);
		if (Target == nullptr)
		{
			return false;
		}

		Weak = Target;
	}

	CollectGarbage();

	return !Weak.IsValid() && !Weak.IsExplicitlyNull();
}
/** @end */
