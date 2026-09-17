/**
 * @version v1
 * @summary A const&in TArray<int32> is summed by range-for.
 * @topic Containers
 *
 * ReadForEachElement
 */
/**
 * @begin ReadForEachElement
 * @summary A const&in TArray<int32> is summed by range-for.
 * @topic Containers
 */
bool ReadForEachElement(const TArray<int32>&in Values)
{
	int32 Sum = 0;
	for (const int32& Value : Values)
	{
		Sum += Value;
	}
	return Sum == 60;
}
/** @end */
