/**
 * @version v1
 * @summary A const&in TSet<int32> reports Num of two unique members.
 * @topic Containers
 *
 * ReadNumCountsElements
 */
/**
 * @begin ReadNumCountsElements
 * @summary A const&in TSet<int32> reports Num of two unique members.
 * @topic Containers
 */
bool ReadNumCountsElements(const TSet<int32>&in Values)
{
	return Values.Num() == 2;
}
/** @end */
