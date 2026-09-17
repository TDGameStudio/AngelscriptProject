/**
 * @version v1
 * @summary A TSoftObjectPtr UPROPERTY starts null and not pending on a fresh instance.
 * @topic Containers
 * ObjectProperty
 */
/**
 * @begin ObjectProperty
 * @summary A TSoftObjectPtr UPROPERTY starts null and not pending on a fresh instance.
 * @topic Containers
 */
UCLASS()
class UTSSoftObjectPtrObjectPropertyHolder : UObject
{
	UPROPERTY()
	TSoftObjectPtr<UObject> ObjectRef;
}

bool ObjectProperty()
{
	UTSSoftObjectPtrObjectPropertyHolder Holder = Cast<UTSSoftObjectPtrObjectPropertyHolder>(
		NewObject(GetTransientPackage(), UTSSoftObjectPtrObjectPropertyHolder::StaticClass(), n"TSSoftObjectPtrProperty_Unset", true));
	if (Holder is null)
	{
		return false;
	}

	return Holder.ObjectRef.IsNull() && !Holder.ObjectRef.IsPending();
}
/** @end */
