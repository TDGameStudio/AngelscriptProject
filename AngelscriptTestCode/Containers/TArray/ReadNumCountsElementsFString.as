/**
 * @version v1
 * @summary A const&in TArray<FString> reports Num of three elements.
 * @topic Containers
 *
 * ReadNumCountsElementsFString
 */
/**
 * @begin ReadNumCountsElementsFString
 * @summary A const&in TArray<FString> reports Num of three elements.
 * @topic Containers
 */
bool ReadNumCountsElementsFString(const TArray<FString>&in Values)
{
	return Values.Num() == 3;
}
/** @end */
