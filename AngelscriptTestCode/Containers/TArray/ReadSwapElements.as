/**
 * @version v1
 * @summary A const&in TArray<int32> reports Swap order.
 * @topic Containers
 *
 * ReadSwapElements
 */
/**
 * @begin ReadSwapElements
 * @summary A const&in TArray<int32> reports Swap order.
 * @topic Containers
 */
bool ReadSwapElements(const TArray<int32>&in Values)
{
	return Values.Num() == 3 && Values[0] == 30 && Values[1] == 20 && Values[2] == 10;
}
/** @end */
