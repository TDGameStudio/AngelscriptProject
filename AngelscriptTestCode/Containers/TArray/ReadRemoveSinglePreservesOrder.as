/**
 * @version v1
 * @summary A const&in TArray<int32> reports the array after RemoveSingle kept later order.
 * @topic Containers
 *
 * ReadRemoveSinglePreservesOrder
 */
/**
 * @begin ReadRemoveSinglePreservesOrder
 * @summary A const&in TArray<int32> reports the array after RemoveSingle kept later order.
 * @topic Containers
 */
bool ReadRemoveSinglePreservesOrder(const TArray<int32>&in Values)
{
	return Values.Num() == 3 && Values[0] == 1 && Values[1] == 2 && Values[2] == 3;
}
/** @end */
