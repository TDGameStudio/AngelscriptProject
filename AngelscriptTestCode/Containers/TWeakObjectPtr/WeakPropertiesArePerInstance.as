/**
 * @version v1
 * @summary Setting a weak property on one instance leaves another instance null.
 * @topic Containers
 *
 * WeakPropertiesArePerInstance
 */
/**
 * @begin WeakPropertiesArePerInstance
 * @summary Setting a weak property on one instance leaves another instance null.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrPropertyHolder : UObject
{
	UPROPERTY()
	TWeakObjectPtr<UObject> WeakRef;
}

bool WeakPropertiesArePerInstance()
{
	UTWeakObjectPtrPropertyHolder First = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyHolder::StaticClass(), n"TWeakObjProp_First", true);
	UTWeakObjectPtrPropertyHolder Second = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyHolder::StaticClass(), n"TWeakObjProp_Second", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}

	First.WeakRef = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyHolder::StaticClass(), n"TWeakObjProp_Shared", true);
	return First.WeakRef.IsValid() && !Second.WeakRef.IsValid();
}
/** @end */
