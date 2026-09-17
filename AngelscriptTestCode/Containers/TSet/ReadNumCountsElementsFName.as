/**
 * @version v1
 * @summary A const&in TSet<FName> reports Num of two unique members.
 * @topic Containers
 *
 * ReadNumCountsElementsFName
 */
/**
 * @begin ReadNumCountsElementsFName
 * @summary A const&in TSet<FName> reports Num of two unique members.
 * @topic Containers
 */
bool ReadNumCountsElementsFName(const TSet<FName>&in Values)
{
	return Values.Num() == 2;
}
/** @end */
