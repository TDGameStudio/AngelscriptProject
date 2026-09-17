/**
 * @version v1
 * @summary TSubclassOf<UObject> accepts a class derived from UObject.
 * @topic Containers
 *
 * AssignDerivedClassIntoBaseHolder
 */
/**
 * @begin AssignDerivedClassIntoBaseHolder
 * @summary TSubclassOf<UObject> accepts a class derived from UObject.
 * @topic Containers
 */
UCLASS()
class UDerivedIntoBaseObject : UObject
{
}

UCLASS()
class UDerivedIntoBaseChild : UDerivedIntoBaseObject
{
}

bool AssignDerivedClassIntoBaseHolder()
{
	TSubclassOf<UObject> Class;
	UClass Derived = UDerivedIntoBaseChild::StaticClass();
	Class = Derived;
	return Class.IsValid() && Class.Get() == Derived;
}
/** @end */
