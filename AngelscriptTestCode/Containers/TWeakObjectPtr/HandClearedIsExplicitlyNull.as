/**
 * @version v1
 * @summary A pointer cleared by hand is explicitly null rather than stale.
 * @topic Containers
 *
 * HandClearedIsExplicitlyNull
 */
/**
 * @begin HandClearedIsExplicitlyNull
 * @summary A pointer cleared by hand is explicitly null rather than stale.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrInvalidationObject : UObject
{
}

bool HandClearedIsExplicitlyNull()
{
	UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrInvalidationObject::StaticClass(), n"TWeakObjInvalid_Cleared", true);
	if (Target == nullptr)
	{
		return false;
	}

	TWeakObjectPtr<UObject> Weak;
	Weak = Target;
	Weak = nullptr;

	return !Weak.IsValid() && Weak.IsExplicitlyNull();
}
/** @end */
