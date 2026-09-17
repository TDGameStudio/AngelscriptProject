/**
 * @version v1
 * @summary Assigning an AActor subclass into a TSubclassOf<AActor> property stores that class.
 * @topic Containers
 *
 * ActorClassPropertyAssign
 */
/**
 * @begin ActorClassPropertyAssign
 * @summary Assigning an AActor subclass into a TSubclassOf<AActor> property stores that class.
 * @topic Containers
 */
UCLASS()
class AActorClassPropertyAssignActor : AActor
{
}

UCLASS()
class UActorClassPropertyAssignHolder : UObject
{
	UPROPERTY()
	TSubclassOf<AActor> ActorClass;
}

bool ActorClassPropertyAssign()
{
	UActorClassPropertyAssignHolder Holder = NewObject(GetTransientPackage(), UActorClassPropertyAssignHolder::StaticClass(), n"ActorClassPropertyAssignHolder", true);
	if (Holder == nullptr)
	{
		return false;
	}

	UClass Expected = AActorClassPropertyAssignActor::StaticClass();
	Holder.ActorClass = Expected;
	return Holder.ActorClass.IsValid() && Holder.ActorClass.Get() == Expected;
}
/** @end */
