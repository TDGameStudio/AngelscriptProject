/**
 * @version v1
 * @summary Assigning an object stores that target on the strong pointer.
 * @topic Containers
 *
 * AssignObjectStoresTarget
 */
/**
 * @begin AssignObjectStoresTarget
 * @summary Assigning an object stores that target on the strong pointer.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrAssignObjectStoresTarget : UObject
{
}

bool AssignObjectStoresTarget()
{
	UObject Target = NewObject(GetTransientPackage(), UTObjectPtrAssignObjectStoresTarget::StaticClass(), n"TObjPtrAssign_First", true);
	if (Target == nullptr)
	{
		return false;
	}

	TObjectPtr<UObject> Ptr;
	if (Ptr.Get() != nullptr)
	{
		return false;
	}

	Ptr = Target;
	return Ptr.Get() == Target && Ptr.Get() != nullptr;
}
/** @end */
