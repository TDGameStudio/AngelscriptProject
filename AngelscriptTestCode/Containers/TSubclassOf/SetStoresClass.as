/**
 * @version v1
 * @summary Set stores the given UClass and Get returns it.
 * @topic Containers
 *
 * SetStoresClass
 */
/**
 * @begin SetStoresClass
 * @summary Set stores the given UClass and Get returns it.
 * @topic Containers
 */
UCLASS()
class USetStoresClassObject : UObject
{
}

bool SetStoresClass()
{
	TSubclassOf<UObject> Class;
	UClass Expected = USetStoresClassObject::StaticClass();
	Class.Set(Expected);
	return Class.IsValid() && Class.Get() == Expected;
}
/** @end */
