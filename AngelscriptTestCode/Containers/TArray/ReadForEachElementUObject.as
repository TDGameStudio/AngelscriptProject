/**
 * @version v1
 * @summary A const&in TArray<UObject> is counted by range-for.
 * @topic Containers
 *
 * ReadForEachElementUObject
 */
/**
 * @begin ReadForEachElementUObject
 * @summary A const&in TArray<UObject> is counted by range-for.
 * @topic Containers
 */
bool ReadForEachElementUObject(const TArray<UObject>&in Values)
{
	int32 Count = 0;
	for (const UObject& Value : Values)
	{
		Count += 1;
	}
	return Count == 3;
}
/** @end */
