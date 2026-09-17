/**
 * @version v1
 * @summary A const&in TArray<bool> reports Swap order.
 * @topic Containers
 *
 * ReadSwapElementsBool
 */
/**
 * @begin ReadSwapElementsBool
 * @summary A const&in TArray<bool> reports Swap order.
 * @topic Containers
 */
bool ReadSwapElementsBool(const TArray<bool>&in Values)
{
	return Values.Num() == 3 && Values[0] == true && Values[1] == true && Values[2] == false;
}
/** @end */
