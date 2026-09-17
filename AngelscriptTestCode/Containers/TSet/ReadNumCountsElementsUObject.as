/**
 * @version v1
 * @summary A const&in TSet<UObject> reports Num of two unique members.
 * @topic Containers
 *
 * ReadNumCountsElementsUObject
 */
/**
 * @begin ReadNumCountsElementsUObject
 * @summary A const&in TSet<UObject> reports Num of two unique members.
 * @topic Containers
 */
bool ReadNumCountsElementsUObject(const TSet<UObject>&in Values)
{
	return Values.Num() == 2;
}
/** @end */
