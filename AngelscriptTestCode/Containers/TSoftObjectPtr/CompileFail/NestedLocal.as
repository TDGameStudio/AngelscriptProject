/**
 * @version v1
 * @summary TSoftObjectPtr<TSoftObjectPtr<UObject>> is rejected as a nested container.
 * @topic Containers
 * NestedLocal
 */
/**
 * @begin NestedLocal
 * @summary TSoftObjectPtr<TSoftObjectPtr<UObject>> is rejected as a nested container.
 * @topic Containers
 */
void NestedLocal()
{
	TSoftObjectPtr<TSoftObjectPtr<UObject>> Soft;
}
/** @end */
