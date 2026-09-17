/**
 * @version v1
 * @summary RemoveAtSwap drops the indexed float and may reorder survivors.
 * @topic Containers
 *
 * RemoveAtSwapFloat
 */
/**
 * @begin RemoveAtSwapFloat
 * @summary RemoveAtSwap drops the indexed float and may reorder survivors.
 * @topic Containers
 */
bool RemoveAtSwapFloat()
{
	TArray<float> Values;
	Values.Add(1.0f);
	Values.Add(2.0f);
	Values.Add(3.0f);
	Values.RemoveAtSwap(0);
	return Values.Num() == 2 && !Values.Contains(1.0f);
}
/** @end */
