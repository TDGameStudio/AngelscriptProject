/**
 * @version v1
 * @summary A strong object pointer UPROPERTY keeps its target alive across GC.
 * @topic Containers
 *
 * StrongPropertyKeepsTargetAlive
 */
/**
 * @begin StrongPropertyKeepsTargetAlive
 * @summary A strong object pointer UPROPERTY keeps its target alive across GC.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrKeepsAliveObject : UObject
{
}

UCLASS()
class UTObjectPtrKeepsAliveHolder : UObject
{
	UPROPERTY()
	TObjectPtr<UTObjectPtrKeepsAliveObject> TypedRef;
}

bool StrongPropertyKeepsTargetAlive()
{
	UTObjectPtrKeepsAliveHolder Holder = NewObject(GetTransientPackage(), UTObjectPtrKeepsAliveHolder::StaticClass(), n"TObjPtrProp_Reach", true);
	if (Holder == nullptr)
	{
		return false;
	}

	Holder.TypedRef = NewObject(GetTransientPackage(), UTObjectPtrKeepsAliveObject::StaticClass(), n"TObjPtrProp_ReachTarget", true);
	if (Holder.TypedRef.Get() == nullptr)
	{
		return false;
	}

	CollectGarbage();

	return Holder.TypedRef.Get() != nullptr;
}
/** @end */
