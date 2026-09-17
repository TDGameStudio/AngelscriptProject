/**
 * @version v1
 * @summary A null TSubclassOf is not a child of UObject.
 * @topic Containers
 *
 * NullIsChildOfNothing
 */
/**
 * @begin NullIsChildOfNothing
 * @summary A null TSubclassOf is not a child of UObject.
 * @topic Containers
 */
bool NullIsChildOfNothing()
{
	TSubclassOf<UObject> Class;
	return !Class.IsChildOf(UObject::StaticClass());
}
/** @end */
