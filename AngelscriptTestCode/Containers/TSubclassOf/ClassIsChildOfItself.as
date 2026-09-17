/**
 * @version v1
 * @summary A class held in TSubclassOf is a child of itself.
 * @topic Containers
 *
 * ClassIsChildOfItself
 */
/**
 * @begin ClassIsChildOfItself
 * @summary A class held in TSubclassOf is a child of itself.
 * @topic Containers
 */
UCLASS()
class UClassIsChildOfItselfObject : UObject
{
}

bool ClassIsChildOfItself()
{
	TSubclassOf<UObject> Class;
	Class = UClassIsChildOfItselfObject::StaticClass();
	return Class.IsChildOf(UClassIsChildOfItselfObject::StaticClass());
}
/** @end */
