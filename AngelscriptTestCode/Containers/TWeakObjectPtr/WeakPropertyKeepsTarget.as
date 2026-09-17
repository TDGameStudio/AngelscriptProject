/**
 * @version v1
 * @summary A weak UPROPERTY keeps the assigned target on the instance.
 * @topic Containers
 *
 * WeakPropertyKeepsTarget
 */
/**
 * @begin WeakPropertyKeepsTarget
 * @summary A weak UPROPERTY keeps the assigned target on the instance.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrPropertyHolder : UObject
{
	UPROPERTY()
	TWeakObjectPtr<UObject> WeakRef;
}

bool WeakPropertyKeepsTarget()
{
	UTWeakObjectPtrPropertyHolder Holder = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyHolder::StaticClass(), n"TWeakObjProp_Set", true);
	if (Holder == nullptr)
	{
		return false;
	}

	UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyHolder::StaticClass(), n"TWeakObjProp_Target", true);
	if (Target == nullptr)
	{
		return false;
	}

	Holder.WeakRef = Target;
	return Holder.WeakRef.IsValid()
		&& Holder.WeakRef.Get() == Target
		&& !Holder.WeakRef.IsExplicitlyNull();
}
/** @end */
