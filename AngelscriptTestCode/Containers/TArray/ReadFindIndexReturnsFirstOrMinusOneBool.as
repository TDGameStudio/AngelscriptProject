/**
 * @version v1
 * @summary A const&in TArray<bool> reports FindIndex first match for each value.
 * @topic Containers
 *
 * ReadFindIndexReturnsFirstOrMinusOneBool
 */
/**
 * @begin ReadFindIndexReturnsFirstOrMinusOneBool
 * @summary A const&in TArray<bool> reports FindIndex first match for each value.
 * @topic Containers
 */
bool ReadFindIndexReturnsFirstOrMinusOneBool(const TArray<bool>&in Values)
{
	return Values.FindIndex(false) == 0 && Values.FindIndex(true) == 1;
}
/** @end */
