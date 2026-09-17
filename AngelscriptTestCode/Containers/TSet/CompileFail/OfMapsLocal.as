/**
 * @version v1
 * @summary Nested TSet<TMap<int, int>> as a local is rejected.
 * @topic Containers
 *
 * OfMapsLocal
 */
/**
 * @begin OfMapsLocal
 * @summary Nested TSet<TMap<int, int>> as a local is rejected.
 * @topic Containers
 */
void OfMapsLocal()
{
	TSet<TMap<int, int>> Groups;
}
/** @end */
