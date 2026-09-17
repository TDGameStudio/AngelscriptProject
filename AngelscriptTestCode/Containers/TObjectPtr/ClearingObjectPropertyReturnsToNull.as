/**
 * @version v1
 * @summary Clearing an object pointer UPROPERTY returns it to null.
 * @topic Containers
 *
 * ClearingObjectPropertyReturnsToNull
 */
/**
 * @begin ClearingObjectPropertyReturnsToNull
 * @summary Clearing an object pointer UPROPERTY returns it to null.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrClearPropertyObject : UObject
{
}

UCLASS()
class UTObjectPtrClearPropertyHolder : UObject
{
	UPROPERTY()
	TObjectPtr<UTObjectPtrClearPropertyObject> TypedRef;
}

bool ClearingObjectPropertyReturnsToNull()
{
	UTObjectPtrClearPropertyHolder Holder = NewObject(GetTransientPackage(), UTObjectPtrClearPropertyHolder::StaticClass(), n"TObjPtrProp_Clear", true);
	if (Holder == nullptr)
	{
		return false;
	}

	Holder.TypedRef = NewObject(GetTransientPackage(), UTObjectPtrClearPropertyObject::StaticClass(), n"TObjPtrProp_ClearTarget", true);
	if (Holder.TypedRef.Get() == nullptr)
	{
		return false;
	}

	Holder.TypedRef = nullptr;
	return Holder.TypedRef.Get() == nullptr;
}
/** @end */
