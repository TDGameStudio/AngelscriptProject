/**
 * @version v1
 * @summary RemoveSwap deletes every match and keeps a non-matching survivor.
 * @topic Containers
 *
 * RemoveSwap
 */
/**
 * @begin RemoveSwap
 * @summary RemoveSwap deletes every match and keeps a non-matching survivor.
 * @topic Containers
 */
bool RemoveSwap()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(1);
	int Removed = Values.RemoveSwap(1);
	int Missing = Values.RemoveSwap(9);
	return Removed == 2 && Missing == 0 && Values.Num() == 1 && Values.Contains(2);
}
/** @end */
