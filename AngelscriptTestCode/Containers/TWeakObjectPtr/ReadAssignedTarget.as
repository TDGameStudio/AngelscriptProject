/**
 * @version v1
 * @summary Reading Get after assign returns the assigned object.
 * @topic Containers
 *
 * ReadAssignedTarget
 */
/**
 * @begin ReadAssignedTarget
 * @summary Reading Get after assign returns the assigned object.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrAssignObject : UObject
{
}

bool ReadAssignedTarget()
{
	UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrAssignObject::StaticClass(), n"TWeakObjAssign_Read", true);
	if (Target == nullptr)
	{
		return false;
	}

	TWeakObjectPtr<UObject> Weak;
	Weak = Target;
	UObject Read = Weak.Get();
	return Read == Target && Weak.IsValid();
}
/** @end */
