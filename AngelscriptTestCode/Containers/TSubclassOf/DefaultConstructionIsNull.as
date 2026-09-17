/**
 * @version v1
 * @summary Default TSubclassOf<UObject> is null and invalid.
 * @topic Containers
 *
 * DefaultConstructionIsNull
 */
/**
 * @begin DefaultConstructionIsNull
 * @summary Default TSubclassOf<UObject> is null and invalid.
 * @topic Containers
 */
bool DefaultConstructionIsNull()
{
	TSubclassOf<UObject> Class;
	return Class.Get() == nullptr && !Class.IsValid();
}
/** @end */
