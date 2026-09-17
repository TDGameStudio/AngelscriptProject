/**
 * @version v1
 * @summary A const&in TObjectPtr reads the assigned target.
 * @topic Containers
 *
 * ReadAssignedTarget
 */
/**
 * @begin ReadAssignedTarget
 * @summary A const&in TObjectPtr reads the assigned target.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrReadAssignedTarget : UObject
{
}

bool ReadIn(const TObjectPtr<UObject>&in Value)
{
	return Value.Get() != nullptr;
}

bool ReadAssignedTarget()
{
	UObject Target = NewObject(GetTransientPackage(), UTObjectPtrReadAssignedTarget::StaticClass(), n"TObjPtrAssign_Read", true);
	if (Target == nullptr)
	{
		return false;
	}

	TObjectPtr<UObject> Ptr;
	Ptr = Target;
	return ReadIn(Ptr) && Ptr.Get() == Target;
}
/** @end */
