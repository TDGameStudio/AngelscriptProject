/**
 * @version v1
 * @summary Weak UPROPERTY members start null and explicitly null.
 * @topic Containers
 *
 * WeakPropertiesStartNull
 */
/**
 * @begin WeakPropertiesStartNull
 * @summary Weak UPROPERTY members start null and explicitly null.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrPropertyHolder : UObject
{
	UPROPERTY()
	TWeakObjectPtr<UObject> WeakRef;

	UPROPERTY()
	TWeakObjectPtr<AActor> WeakActor;
}

bool WeakPropertiesStartNull()
{
	UTWeakObjectPtrPropertyHolder Holder = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyHolder::StaticClass(), n"TWeakObjProp_Unset", true);
	if (Holder == nullptr)
	{
		return false;
	}

	return !Holder.WeakRef.IsValid()
		&& Holder.WeakRef.Get() == nullptr
		&& Holder.WeakRef.IsExplicitlyNull()
		&& !Holder.WeakActor.IsValid()
		&& Holder.WeakActor.IsExplicitlyNull();
}
/** @end */
