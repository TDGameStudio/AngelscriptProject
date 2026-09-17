/**
 * @version v1
 * @summary Assigning nullptr clears a set TSubclassOf back to invalid.
 * @topic Containers
 *
 * AssignNullptrClearsHolder
 */
/**
 * @begin AssignNullptrClearsHolder
 * @summary Assigning nullptr clears a set TSubclassOf back to invalid.
 * @topic Containers
 */
UCLASS()
class UAssignNullptrClearsObject : UObject
{
}

bool AssignNullptrClearsHolder()
{
	TSubclassOf<UObject> Class;
	Class = UAssignNullptrClearsObject::StaticClass();
	if (!Class.IsValid())
	{
		return false;
	}

	Class = nullptr;
	return !Class.IsValid() && Class.Get() == nullptr;
}
/** @end */
