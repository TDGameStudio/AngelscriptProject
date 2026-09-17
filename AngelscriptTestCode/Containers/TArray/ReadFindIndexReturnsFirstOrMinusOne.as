/**
 * @version v1
 * @summary A const&in TArray<int32> reports FindIndex first match or -1.
 * @topic Containers
 *
 * ReadFindIndexReturnsFirstOrMinusOne
 */
/**
 * @begin ReadFindIndexReturnsFirstOrMinusOne
 * @summary A const&in TArray<int32> reports FindIndex first match or -1.
 * @topic Containers
 */
bool ReadFindIndexReturnsFirstOrMinusOne(const TArray<int32>&in Values)
{
	return Values.FindIndex(10) == 0 && Values.FindIndex(20) == 1 && Values.FindIndex(99) == -1;
}
/** @end */
