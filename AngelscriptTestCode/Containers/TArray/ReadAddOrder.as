/**
 * @version v1
 * @summary A const&in TArray<int32> reports Add insertion order.
 * @topic Containers
 *
 * ReadAddOrder
 */
/**
 * @begin ReadAddOrder
 * @summary A const&in TArray<int32> reports Add insertion order.
 * @topic Containers
 */
bool ReadAddOrder(const TArray<int32>&in Values)
{
	return Values.Num() == 3 && Values[0] == 10 && Values[1] == 20 && Values[2] == 30;
}
/** @end */
