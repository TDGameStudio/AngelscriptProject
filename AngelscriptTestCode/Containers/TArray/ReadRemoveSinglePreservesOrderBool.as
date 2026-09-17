/**
 * @version v1
 * @summary A const&in TArray<bool> reports the array after RemoveSingle kept later order.
 * @topic Containers
 *
 * ReadRemoveSinglePreservesOrderBool
 */
/**
 * @begin ReadRemoveSinglePreservesOrderBool
 * @summary A const&in TArray<bool> reports the array after RemoveSingle kept later order.
 * @topic Containers
 */
bool ReadRemoveSinglePreservesOrderBool(const TArray<bool>&in Values)
{
	return Values.Num() == 3 && Values[0] == true && Values[1] == false && Values[2] == true;
}
/** @end */
