/**
 * @version v1
 * @summary A const&in TArray<bool> reports membership after RemoveSwap deleted every match.
 * @topic Containers
 *
 * ReadRemoveSwapBool
 */
/**
 * @begin ReadRemoveSwapBool
 * @summary A const&in TArray<bool> reports membership after RemoveSwap deleted every match.
 * @topic Containers
 */
bool ReadRemoveSwapBool(const TArray<bool>&in Values)
{
	return Values.Num() == 2 && !Values.Contains(true) && Values.Contains(false);
}
/** @end */
