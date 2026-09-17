/**
 * @version v1
 * @summary TSubclassOf UPROPERTY state is per-instance.
 * @topic Containers
 *
 * SubclassPropertiesArePerInstance
 */
/**
 * @begin SubclassPropertiesArePerInstance
 * @summary TSubclassOf UPROPERTY state is per-instance.
 * @topic Containers
 */
UCLASS()
class UPerInstancePropertyObject : UObject
{
}

UCLASS()
class UPerInstancePropertyHolder : UObject
{
	UPROPERTY()
	TSubclassOf<UObject> ObjectClass;
}

bool SubclassPropertiesArePerInstance()
{
	UPerInstancePropertyHolder First = NewObject(GetTransientPackage(), UPerInstancePropertyHolder::StaticClass(), n"PerInstancePropertyFirst", true);
	UPerInstancePropertyHolder Second = NewObject(GetTransientPackage(), UPerInstancePropertyHolder::StaticClass(), n"PerInstancePropertySecond", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}

	First.ObjectClass = UPerInstancePropertyObject::StaticClass();
	return First.ObjectClass.IsValid() && !Second.ObjectClass.IsValid();
}
/** @end */
