/**
 * @version v1
 * @summary A const&in TMap<FString, int> reports the existing FindOrAdd value.
 * @topic Containers
 *
 * ReadFindOrAddReturnsExistingFString
 */
/**
 * @begin ReadFindOrAddReturnsExistingFString
 * @summary A const&in TMap<FString, int> reports the existing FindOrAdd value.
 * @topic Containers
 */
bool ReadFindOrAddReturnsExistingFString(const TMap<FString, int>&in Values)
{
	return Values.Num() == 1 && Values.Contains("delta") && Values["delta"] == 9;
}
/** @end */
