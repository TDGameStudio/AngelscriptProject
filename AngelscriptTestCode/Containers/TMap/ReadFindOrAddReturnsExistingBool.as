/**
 * @version v1
 * @summary A const&in TMap<int, bool> reports the existing FindOrAdd value.
 * @topic Containers
 *
 * ReadFindOrAddReturnsExistingBool
 */
/**
 * @begin ReadFindOrAddReturnsExistingBool
 * @summary A const&in TMap<int, bool> reports the existing FindOrAdd value.
 * @topic Containers
 */
bool ReadFindOrAddReturnsExistingBool(const TMap<int, bool>&in Values)
{
	return Values.Num() == 1 && Values.Contains(1) && Values[1] == true;
}
/** @end */
