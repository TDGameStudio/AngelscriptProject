/**
 * @version v1
 * @summary A const&in TArray<bool> reports unique AddUnique order.
 * @topic Containers
 *
 * ReadAddUniqueRejectsDuplicateBool
 */
/**
 * @begin ReadAddUniqueRejectsDuplicateBool
 * @summary A const&in TArray<bool> reports unique AddUnique order.
 * @topic Containers
 */
bool ReadAddUniqueRejectsDuplicateBool(const TArray<bool>&in Values)
{
	return Values.Num() == 2 && Values[0] == true && Values[1] == false;
}
/** @end */
