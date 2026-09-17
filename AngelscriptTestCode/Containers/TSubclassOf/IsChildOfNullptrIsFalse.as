/**
 * @version v1
 * @summary IsChildOf(nullptr) is false on a valid TSubclassOf.
 * @topic Containers
 *
 * IsChildOfNullptrIsFalse
 */
/**
 * @begin IsChildOfNullptrIsFalse
 * @summary IsChildOf(nullptr) is false on a valid TSubclassOf.
 * @topic Containers
 */
UCLASS()
class UIsChildOfNullptrObject : UObject
{
}

bool IsChildOfNullptrIsFalse()
{
	TSubclassOf<UObject> Class;
	Class = UIsChildOfNullptrObject::StaticClass();
	return !Class.IsChildOf(nullptr);
}
/** @end */
