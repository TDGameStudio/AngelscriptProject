/**
 * @version v1
 * @summary RemoveSwap deletes every matching bool and keeps a non-matching survivor.
 * @topic Containers
 *
 * RemoveSwapBool
 */
/**
 * @begin RemoveSwapBool
 * @summary RemoveSwap deletes every matching bool and keeps a non-matching survivor.
 * @topic Containers
 */
bool RemoveSwapBool()
{
	TArray<bool> Values;
	Values.Add(true);
	Values.Add(false);
	Values.Add(true);
	int Removed = Values.RemoveSwap(true);
	return Removed == 2 && Values.Num() == 1 && Values.Contains(false);
}
/** @end */
