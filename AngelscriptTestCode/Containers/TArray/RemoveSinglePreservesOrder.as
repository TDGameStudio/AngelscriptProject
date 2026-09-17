/**
 * @version v1
 * @summary RemoveSingle removes the first match and keeps later elements in order.
 * @topic Containers
 *
 * RemoveSinglePreservesOrder
 */
/**
 * @begin RemoveSinglePreservesOrder
 * @summary RemoveSingle removes the first match and keeps later elements in order.
 * @topic Containers
 */
bool RemoveSinglePreservesOrder()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(1);
	int Removed = Values.RemoveSingle(1);
	int Missing = Values.RemoveSingle(9);
	return Removed == 1 && Missing == 0 && Values.Num() == 2 && Values[0] == 2 && Values[1] == 1;
}
/** @end */
