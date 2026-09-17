/**
 * @version v1
 * @summary Get reads back the class assigned into TSubclassOf.
 * @topic Containers
 *
 * ReadAssignedClass
 */
/**
 * @begin ReadAssignedClass
 * @summary Get reads back the class assigned into TSubclassOf.
 * @topic Containers
 */
UCLASS()
class UReadAssignedClassObject : UObject
{
}

bool ReadAssignedClass()
{
	TSubclassOf<UObject> Class;
	UClass Expected = UReadAssignedClassObject::StaticClass();
	Class = Expected;
	return Class.IsValid() && Class.Get() == Expected;
}
/** @end */
