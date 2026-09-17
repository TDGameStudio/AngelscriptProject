/**
 * @version v1
 * @summary GetDefaultObject on a null TSubclassOf returns nullptr.
 * @topic Containers
 *
 * NullGetDefaultObjectIsNull
 */
/**
 * @begin NullGetDefaultObjectIsNull
 * @summary GetDefaultObject on a null TSubclassOf returns nullptr.
 * @topic Containers
 */
bool NullGetDefaultObjectIsNull()
{
	TSubclassOf<UObject> Class;
	return Class.GetDefaultObject() == nullptr;
}
/** @end */
