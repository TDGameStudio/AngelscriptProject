/**
 * @version v1
 * @summary A const&in TMap<int, int> reports the existing FindOrAdd value.
 * @topic Containers
 *
 * ReadFindOrAddReturnsExisting
 */
/**
 * @begin ReadFindOrAddReturnsExisting
 * @summary A const&in TMap<int, int> reports the existing FindOrAdd value.
 * @topic Containers
 */
bool ReadFindOrAddReturnsExisting(const TMap<int, int>&in Values)
{
	return Values.Num() == 1 && Values.Contains(10) && Values[10] == 9;
}
/** @end */
