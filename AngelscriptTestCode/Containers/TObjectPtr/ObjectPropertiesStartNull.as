/**
 * @version v1
 * @summary Object pointer UPROPERTYs start null on a fresh instance.
 * @topic Containers
 *
 * ObjectPropertiesStartNull
 */
/**
 * @begin ObjectPropertiesStartNull
 * @summary Object pointer UPROPERTYs start null on a fresh instance.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrStartNullObject : UObject
{
}

UCLASS()
class UTObjectPtrStartNullHolder : UObject
{
	UPROPERTY()
	TObjectPtr<UObject> ObjectRef;

	UPROPERTY()
	TObjectPtr<UTObjectPtrStartNullObject> TypedRef;

	UPROPERTY()
	TObjectPtr<AActor> ActorRef;
}

bool ObjectPropertiesStartNull()
{
	UTObjectPtrStartNullHolder Holder = NewObject(GetTransientPackage(), UTObjectPtrStartNullHolder::StaticClass(), n"TObjPtrProp_Unset", true);
	if (Holder == nullptr)
	{
		return false;
	}

	return Holder.ObjectRef.Get() == nullptr
		&& Holder.TypedRef.Get() == nullptr
		&& Holder.ActorRef.Get() == nullptr;
}
/** @end */
