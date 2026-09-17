/**
 * @version v1
 * @summary Assigning nullptr clears the strong pointer.
 * @topic Containers
 *
 * AssignNullptrClearsTarget
 */
/**
 * @begin AssignNullptrClearsTarget
 * @summary Assigning nullptr clears the strong pointer.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrAssignNullptrTarget : UObject
{
}

bool AssignNullptrClearsTarget()
{
	UObject Target = NewObject(GetTransientPackage(), UTObjectPtrAssignNullptrTarget::StaticClass(), n"TObjPtrAssign_Clear", true);
	if (Target == nullptr)
	{
		return false;
	}

	TObjectPtr<UObject> Ptr;
	Ptr = Target;
	if (Ptr.Get() != Target)
	{
		return false;
	}

	Ptr = nullptr;
	return Ptr.Get() == nullptr;
}
/** @end */
