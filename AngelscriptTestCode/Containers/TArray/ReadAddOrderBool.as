/**
 * @version v1
 * @summary A const&in TArray<bool> reports Add insertion order.
 * @topic Containers
 *
 * ReadAddOrderBool
 */
/**
 * @begin ReadAddOrderBool
 * @summary A const&in TArray<bool> reports Add insertion order.
 * @topic Containers
 */
bool ReadAddOrderBool(const TArray<bool>&in Values)
{
	return Values.Num() == 3 && Values[0] == false && Values[1] == true && Values[2] == false;
}
/** @end */
