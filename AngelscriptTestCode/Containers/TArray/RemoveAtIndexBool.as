/**
 * @version v1
 * @summary RemoveAt drops the indexed bool and shifts later elements down.
 * @topic Containers
 *
 * RemoveAtIndexBool
 */
/**
 * @begin RemoveAtIndexBool
 * @summary RemoveAt drops the indexed bool and shifts later elements down.
 * @topic Containers
 */
bool RemoveAtIndexBool()
{
	TArray<bool> Values;
	Values.Add(true);
	Values.Add(false);
	Values.Add(true);
	Values.RemoveAt(1);
	return Values.Num() == 2 && Values[0] == true && Values[1] == true;
}
/** @end */
