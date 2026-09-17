/**
 * @version v1
 * @summary Object pointer UPROPERTY state is per-instance.
 * @topic Containers
 *
 * ObjectPropertiesArePerInstance
 */
/**
 * @begin ObjectPropertiesArePerInstance
 * @summary Object pointer UPROPERTY state is per-instance.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrPerInstanceObject : UObject
{
}

UCLASS()
class UTObjectPtrPerInstanceHolder : UObject
{
	UPROPERTY()
	TObjectPtr<UTObjectPtrPerInstanceObject> TypedRef;
}

bool ObjectPropertiesArePerInstance()
{
	UTObjectPtrPerInstanceHolder First = NewObject(GetTransientPackage(), UTObjectPtrPerInstanceHolder::StaticClass(), n"TObjPtrProp_First", true);
	UTObjectPtrPerInstanceHolder Second = NewObject(GetTransientPackage(), UTObjectPtrPerInstanceHolder::StaticClass(), n"TObjPtrProp_Second", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}

	First.TypedRef = NewObject(GetTransientPackage(), UTObjectPtrPerInstanceObject::StaticClass(), n"TObjPtrProp_Shared", true);
	return First.TypedRef.Get() != nullptr && Second.TypedRef.Get() == nullptr;
}
/** @end */
