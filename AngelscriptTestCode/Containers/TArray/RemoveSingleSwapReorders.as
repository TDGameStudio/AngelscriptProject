/**
 * @version v1
 * @summary RemoveSingleSwap of the first element swaps the last survivor into that slot.
 * @topic Containers
 *
 * RemoveSingleSwapReorders
 */
/**
 * @begin RemoveSingleSwapReorders
 * @summary RemoveSingleSwap of the first element swaps the last survivor into that slot.
 * @topic Containers
 */
bool RemoveSingleSwapReorders()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Add(20);
	Values.Add(30);
	int Removed = Values.RemoveSingleSwap(10);
	return Removed == 1 && Values.Num() == 2 && Values[0] == 30 && Values[1] == 20;
}
/** @end */
