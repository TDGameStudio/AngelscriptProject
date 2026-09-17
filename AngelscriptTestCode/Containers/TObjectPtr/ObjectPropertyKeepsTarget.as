/**
 * @version v1
 * @summary An object pointer UPROPERTY keeps its assigned target.
 * @topic Containers
 *
 * ObjectPropertyKeepsTarget
 */
/**
 * @begin ObjectPropertyKeepsTarget
 * @summary An object pointer UPROPERTY keeps its assigned target.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrKeepsTargetObject : UObject
{
}

UCLASS()
class UTObjectPtrKeepsTargetHolder : UObject
{
	UPROPERTY()
	TObjectPtr<UTObjectPtrKeepsTargetObject> TypedRef;
}

bool ObjectPropertyKeepsTarget()
{
	UTObjectPtrKeepsTargetHolder Holder = NewObject(GetTransientPackage(), UTObjectPtrKeepsTargetHolder::StaticClass(), n"TObjPtrProp_Set", true);
	if (Holder == nullptr)
	{
		return false;
	}

	UTObjectPtrKeepsTargetObject Target = NewObject(GetTransientPackage(), UTObjectPtrKeepsTargetObject::StaticClass(), n"TObjPtrProp_Target", true);
	if (Target == nullptr)
	{
		return false;
	}

	Holder.TypedRef = Target;
	return Holder.TypedRef.Get() == Target;
}
/** @end */
