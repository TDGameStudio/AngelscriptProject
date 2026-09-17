/**
 * @version v1
 * @summary A const&in TSet<FVector> reports Num of two unique members.
 * @topic Containers
 *
 * ReadNumCountsElementsFVector
 */
/**
 * @begin ReadNumCountsElementsFVector
 * @summary A const&in TSet<FVector> reports Num of two unique members.
 * @topic Containers
 */
bool ReadNumCountsElementsFVector(const TSet<FVector>&in Values)
{
	return Values.Num() == 2;
}
/** @end */
