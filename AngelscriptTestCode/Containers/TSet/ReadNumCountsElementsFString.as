/**
 * @version v1
 * @summary A const&in TSet<FString> reports Num of two unique members.
 * @topic Containers
 *
 * ReadNumCountsElementsFString
 */
/**
 * @begin ReadNumCountsElementsFString
 * @summary A const&in TSet<FString> reports Num of two unique members.
 * @topic Containers
 */
bool ReadNumCountsElementsFString(const TSet<FString>&in Values)
{
	return Values.Num() == 2;
}
/** @end */
