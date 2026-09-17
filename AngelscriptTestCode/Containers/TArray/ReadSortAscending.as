/**
 * @version v1
 * @summary A const&in TArray<int32> reports sorted ascending order.
 * @topic Containers
 *
 * ReadSortAscending
 */
/**
 * @begin ReadSortAscending
 * @summary A const&in TArray<int32> reports sorted ascending order.
 * @topic Containers
 */
bool ReadSortAscending(const TArray<int32>&in Values)
{
	return Values.Num() == 3 && Values[0] == 10 && Values[1] == 20 && Values[2] == 30;
}
/** @end */
