/**
 * @version v1
 * @summary A const&in TArray<bool> reports membership after RemoveAtSwap dropped an index.
 * @topic Containers
 *
 * ReadRemoveAtSwapBool
 */
/**
 * @begin ReadRemoveAtSwapBool
 * @summary A const&in TArray<bool> reports membership after RemoveAtSwap dropped an index.
 * @topic Containers
 */
bool ReadRemoveAtSwapBool(const TArray<bool>&in Values)
{
	return Values.Num() == 2 && !Values.Contains(true) && Values.Contains(false);
}
/** @end */
