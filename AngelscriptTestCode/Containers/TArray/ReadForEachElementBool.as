/**
 * @version v1
 * @summary A const&in TArray<bool> is counted by range-for.
 * @topic Containers
 *
 * ReadForEachElementBool
 */
/**
 * @begin ReadForEachElementBool
 * @summary A const&in TArray<bool> is counted by range-for.
 * @topic Containers
 */
bool ReadForEachElementBool(const TArray<bool>&in Values)
{
	int32 Count = 0;
	for (const bool& Value : Values)
	{
		Count += 1;
	}
	return Count == 3;
}
/** @end */
