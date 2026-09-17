/**
 * @version v1
 * @summary RemoveAtSwap drops the indexed bool and may reorder survivors.
 * @topic Containers
 *
 * RemoveAtSwapBool
 */
/**
 * @begin RemoveAtSwapBool
 * @summary RemoveAtSwap drops the indexed bool and may reorder survivors.
 * @topic Containers
 */
bool RemoveAtSwapBool()
{
	TArray<bool> Values;
	Values.Add(true);
	Values.Add(false);
	Values.Add(false);
	Values.RemoveAtSwap(0);
	return Values.Num() == 2 && !Values.Contains(true);
}
/** @end */
