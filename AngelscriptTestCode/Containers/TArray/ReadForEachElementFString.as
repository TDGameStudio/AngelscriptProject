/**
 * @version v1
 * @summary A const&in TArray<FString> is counted by range-for.
 * @topic Containers
 *
 * ReadForEachElementFString
 */
/**
 * @begin ReadForEachElementFString
 * @summary A const&in TArray<FString> is counted by range-for.
 * @topic Containers
 */
bool ReadForEachElementFString(const TArray<FString>&in Values)
{
	int32 Count = 0;
	for (const FString& Value : Values)
	{
		Count += 1;
	}
	return Count == 3;
}
/** @end */
