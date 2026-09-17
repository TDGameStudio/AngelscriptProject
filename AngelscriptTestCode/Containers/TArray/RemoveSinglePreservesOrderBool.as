/**
 * @version v1
 * @summary RemoveSingle removes the first matching bool and keeps later elements in order.
 * @topic Containers
 *
 * RemoveSinglePreservesOrderBool
 */
/**
 * @begin RemoveSinglePreservesOrderBool
 * @summary RemoveSingle removes the first matching bool and keeps later elements in order.
 * @topic Containers
 */
bool RemoveSinglePreservesOrderBool()
{
	TArray<bool> Values;
	Values.Add(true);
	Values.Add(false);
	Values.Add(true);
	int Removed = Values.RemoveSingle(true);
	return Removed == 1 && Values.Num() == 2 && Values[0] == false && Values[1] == true;
}
/** @end */
