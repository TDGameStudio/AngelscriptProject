/**
 * @version v1
 * @summary TSubclassOf UPROPERTY fields start null on a fresh instance.
 * @topic Containers
 *
 * SubclassPropertiesStartNull
 */
/**
 * @begin SubclassPropertiesStartNull
 * @summary TSubclassOf UPROPERTY fields start null on a fresh instance.
 * @topic Containers
 */
UCLASS()
class USubclassPropsStartNullBase : UObject
{
}

UCLASS()
class USubclassPropsStartNullHolder : UObject
{
	UPROPERTY()
	TSubclassOf<UObject> ObjectClass;

	UPROPERTY()
	TSubclassOf<USubclassPropsStartNullBase> BaseClass;

	UPROPERTY()
	TSubclassOf<AActor> ActorClass;
}

bool SubclassPropertiesStartNull()
{
	USubclassPropsStartNullHolder Holder = NewObject(GetTransientPackage(), USubclassPropsStartNullHolder::StaticClass(), n"SubclassPropsStartNull", true);
	if (Holder == nullptr)
	{
		return false;
	}

	return !Holder.ObjectClass.IsValid() && Holder.ObjectClass.Get() == nullptr
		&& !Holder.BaseClass.IsValid() && Holder.BaseClass.Get() == nullptr
		&& !Holder.ActorClass.IsValid() && Holder.ActorClass.Get() == nullptr;
}
/** @end */
