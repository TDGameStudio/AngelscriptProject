/**
 * @version v1
 * @summary Nested TObjectPtr<TObjectPtr<UObject>> is rejected.
 * @topic Containers
 *
 * NestedLocal
 */
/**
 * @begin NestedLocal
 * @summary Nested TObjectPtr<TObjectPtr<UObject>> is rejected.
 * @topic Containers
 */
void NestedLocal()
{
	TObjectPtr<TObjectPtr<UObject>> Ptr;
}
/** @end */
