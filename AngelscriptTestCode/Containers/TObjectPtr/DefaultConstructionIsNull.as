/**
 * @version v1
 * @summary A default TObjectPtr<UObject> is null.
 * @topic Containers
 *
 * DefaultConstructionIsNull
 */
/**
 * @begin DefaultConstructionIsNull
 * @summary A default TObjectPtr<UObject> is null.
 * @topic Containers
 */
bool DefaultConstructionIsNull()
{
	TObjectPtr<UObject> Ptr;
	return Ptr.Get() == nullptr;
}
/** @end */
