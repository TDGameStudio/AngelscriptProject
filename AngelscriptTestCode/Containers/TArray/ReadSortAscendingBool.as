/**
 * @version v1
 * @summary A const&in TArray<bool> reports sorted ascending order.
 * @topic Containers
 *
 * ReadSortAscendingBool
 */
/**
 * @begin ReadSortAscendingBool
 * @summary A const&in TArray<bool> reports sorted ascending order.
 * @topic Containers
 */
bool ReadSortAscendingBool(const TArray<bool>&in Values)
{
	return Values.Num() == 3 && Values[0] == false && Values[1] == true && Values[2] == true;
}
/** @end */
