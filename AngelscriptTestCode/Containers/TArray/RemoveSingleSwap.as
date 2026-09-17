/**
 * @version v1
 * @summary RemoveSingleSwap removes one match and reports zero when the value is missing.
 * @topic Containers
 *
 * RemoveSingleSwap
 */
/**
 * @begin RemoveSingleSwap
 * @summary RemoveSingleSwap removes one match and reports zero when the value is missing.
 * @topic Containers
 */
bool RemoveSingleSwap()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(1);
	int Removed = Values.RemoveSingleSwap(1);
	int Missing = Values.RemoveSingleSwap(9);
	return Removed == 1 && Missing == 0 && Values.Num() == 2;
}
/** @end */
