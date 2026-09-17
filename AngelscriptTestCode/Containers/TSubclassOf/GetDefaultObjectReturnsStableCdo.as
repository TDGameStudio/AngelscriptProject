/**
 * @version v1
 * @summary GetDefaultObject returns a stable CDO for the held class.
 * @topic Containers
 *
 * GetDefaultObjectReturnsStableCdo
 */
/**
 * @begin GetDefaultObjectReturnsStableCdo
 * @summary GetDefaultObject returns a stable CDO for the held class.
 * @topic Containers
 */
UCLASS()
class UStableCdoObject : UObject
{
}

bool GetDefaultObjectReturnsStableCdo()
{
	TSubclassOf<UObject> Class;
	Class = UStableCdoObject::StaticClass();

	UObject First = Class.GetDefaultObject();
	UObject Second = Class.GetDefaultObject();
	return First != nullptr && First == Second;
}
/** @end */
