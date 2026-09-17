/**
 * @version v1
 * @summary A const&in TArray<int32> reports unique AddUnique order.
 * @topic Containers
 *
 * ReadAddUniqueRejectsDuplicate
 */
/**
 * @begin ReadAddUniqueRejectsDuplicate
 * @summary A const&in TArray<int32> reports unique AddUnique order.
 * @topic Containers
 */
bool ReadAddUniqueRejectsDuplicate(const TArray<int32>&in Values)
{
	return Values.Num() == 3 && Values[0] == 10 && Values[1] == 20 && Values[2] == 30;
}
/** @end */
