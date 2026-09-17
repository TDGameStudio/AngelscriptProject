/**
 * @version v1
 * @summary TWeakObjectPtr of another TWeakObjectPtr is rejected as a nested container.
 * @topic Containers
 *
 * NestedLocal
 */
/**
 * @begin NestedLocal
 * @summary TWeakObjectPtr of another TWeakObjectPtr is rejected as a nested container.
 * @topic Containers
 */
void NestedLocal()
{
	TWeakObjectPtr<TWeakObjectPtr<UObject>> Weak;
}
/** @end */
