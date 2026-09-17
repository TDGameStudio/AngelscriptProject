/**
 * @version v1
 * @summary RemoveSwap deletes every matching float and keeps a non-matching survivor.
 * @topic Containers
 *
 * RemoveSwapFloat
 */
/**
 * @begin RemoveSwapFloat
 * @summary RemoveSwap deletes every matching float and keeps a non-matching survivor.
 * @topic Containers
 */
bool RemoveSwapFloat()
{
	TArray<float> Values;
	Values.Add(1.0f);
	Values.Add(2.0f);
	Values.Add(1.0f);
	int Removed = Values.RemoveSwap(1.0f);
	int Missing = Values.RemoveSwap(9.0f);
	return Removed == 2 && Missing == 0 && Values.Num() == 1 && Values.Contains(2.0f);
}
/** @end */
