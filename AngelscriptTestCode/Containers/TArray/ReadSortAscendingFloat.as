/**
 * @version v1
 * @summary A const&in TArray<float> reports sorted ascending order.
 * @topic Containers
 *
 * ReadSortAscendingFloat
 */
/**
 * @begin ReadSortAscendingFloat
 * @summary A const&in TArray<float> reports sorted ascending order.
 * @topic Containers
 */
bool ReadSortAscendingFloat(const TArray<float>&in Values)
{
	return Values.Num() == 3 && Values[0] == 10.0f && Values[1] == 20.0f && Values[2] == 30.0f;
}
/** @end */
