/**
 * @version v1
 * @summary Assigning a UClass makes TSubclassOf valid and Get returns that class.
 * @topic Containers
 *
 * AssignClassMakesValid
 */
/**
 * @begin AssignClassMakesValid
 * @summary Assigning a UClass makes TSubclassOf valid and Get returns that class.
 * @topic Containers
 */
UCLASS()
class UAssignClassMakesValidObject : UObject
{
}

bool AssignClassMakesValid()
{
	TSubclassOf<UObject> Class;
	if (Class.IsValid())
	{
		return false;
	}

	UClass Expected = UAssignClassMakesValidObject::StaticClass();
	Class = Expected;
	return Class.IsValid() && Class.Get() == Expected;
}
/** @end */
