/**
 * @version v1
 * @summary RemoveAtSwap drops the indexed element and may reorder survivors.
 * @topic Containers
 *
 * RemoveAtSwap
 */
/**
 * @begin RemoveAtSwap
 * @summary RemoveAtSwap drops the indexed element and may reorder survivors.
 * @topic Containers
 */
bool RemoveAtSwap()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(3);
	Values.RemoveAtSwap(0);
	return Values.Num() == 2 && !Values.Contains(1);
}
/** @end */
