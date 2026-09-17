/**
 * @version v1
 * @summary A const&in TMap<FName, int> reports the existing FindOrAdd value.
 * @topic Containers
 *
 * ReadFindOrAddReturnsExistingFName
 */
/**
 * @begin ReadFindOrAddReturnsExistingFName
 * @summary A const&in TMap<FName, int> reports the existing FindOrAdd value.
 * @topic Containers
 */
bool ReadFindOrAddReturnsExistingFName(const TMap<FName, int>&in Values)
{
	return Values.Num() == 1 && Values.Contains(n"Delta") && Values[n"Delta"] == 9;
}
/** @end */
