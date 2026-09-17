/**
 * @version v1
 * @summary A const&in TArray<float> reports FindIndex first match or -1.
 * @topic Containers
 *
 * ReadFindIndexReturnsFirstOrMinusOneFloat
 */
/**
 * @begin ReadFindIndexReturnsFirstOrMinusOneFloat
 * @summary A const&in TArray<float> reports FindIndex first match or -1.
 * @topic Containers
 */
bool ReadFindIndexReturnsFirstOrMinusOneFloat(const TArray<float>&in Values)
{
	return Values.FindIndex(10.0f) == 0 && Values.FindIndex(20.0f) == 1 && Values.FindIndex(99.0f) == -1;
}
/** @end */
