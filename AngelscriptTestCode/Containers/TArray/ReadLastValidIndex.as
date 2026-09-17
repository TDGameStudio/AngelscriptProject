/**
 * @version v1
 * @summary A const&in TArray<int32> reports Last() and Last(1) from the end.
 * @topic Containers
 *
 * ReadLastValidIndex
 */
/**
 * @begin ReadLastValidIndex
 * @summary A const&in TArray<int32> reports Last() and Last(1) from the end.
 * @topic Containers
 */
bool ReadLastValidIndex(const TArray<int32>&in Values)
{
	return Values.Last() == 30 && Values.Last(1) == 20 && Values.Last(2) == 10;
}
/** @end */
