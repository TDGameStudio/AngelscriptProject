/**
 * @version v1
 * @summary Get returns the assigned object, not a copy.
 * @topic Containers
 *
 * GetReturnsTheAssignedObject
 */
/**
 * @begin GetReturnsTheAssignedObject
 * @summary Get returns the assigned object, not a copy.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrGetAssignedTarget : UObject
{
}

bool GetReturnsTheAssignedObject()
{
	UObject Target = NewObject(GetTransientPackage(), UTObjectPtrGetAssignedTarget::StaticClass(), n"TObjPtrValid_Get", true);
	if (Target == nullptr)
	{
		return false;
	}

	TObjectPtr<UObject> Ptr;
	Ptr = Target;
	return Ptr.Get() == Target && Ptr.Get() == Ptr.Get();
}
/** @end */
