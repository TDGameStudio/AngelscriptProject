/**
 * @version v1
 * @summary A const&in TArray<bool> reports Last() and Last(1) from the end.
 * @topic Containers
 *
 * ReadLastValidIndexBool
 */
/**
 * @begin ReadLastValidIndexBool
 * @summary A const&in TArray<bool> reports Last() and Last(1) from the end.
 * @topic Containers
 */
bool ReadLastValidIndexBool(const TArray<bool>&in Values)
{
	return Values.Last() == false && Values.Last(1) == true && Values.Last(2) == false;
}
/** @end */
