/**
 * @version v1
 * @summary Assigning an AActor stores that target on a TObjectPtr<AActor> property.
 * @topic Containers
 *
 * PropertyActorAssign
 */
/**
 * @begin PropertyActorAssign
 * @summary Assigning an AActor stores that target on a TObjectPtr<AActor> property.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrActorHolder : UObject
{
	UPROPERTY()
	TObjectPtr<AActor> ActorRef;
}

bool PropertyActorAssign()
{
	UTObjectPtrActorHolder Holder = NewObject(GetTransientPackage(), UTObjectPtrActorHolder::StaticClass(), n"TObjPtrActor_Holder", true);
	if (Holder == nullptr)
	{
		return false;
	}

	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo == nullptr)
	{
		return false;
	}

	Holder.ActorRef = LiveCdo;
	return Holder.ActorRef.Get() == LiveCdo;
}
/** @end */
