/**
 * @version v1
 * @summary TSubclassOf<TSubclassOf<UObject>> is rejected as a nested container.
 * @topic Containers
 *
 * NestedLocal
 */
/**
 * @begin NestedLocal
 * @summary TSubclassOf<TSubclassOf<UObject>> is rejected as a nested container.
 * @topic Containers
 */
void NestedLocal()
{
	TSubclassOf<TSubclassOf<UObject>> Class;
}
/** @end */
