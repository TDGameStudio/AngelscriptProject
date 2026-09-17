/**
 * @version v1
 * @summary A const&in TArray<int32> reports membership after RemoveAtSwap dropped an index.
 * @topic Containers
 *
 * ReadRemoveAtSwap
 */
/**
 * @begin ReadRemoveAtSwap
 * @summary A const&in TArray<int32> reports membership after RemoveAtSwap dropped an index.
 * @topic Containers
 */
bool ReadRemoveAtSwap(const TArray<int32>&in Values)
{
	return Values.Num() == 3
		&& !Values.Contains(1)
		&& Values.Contains(2)
		&& Values.Contains(3)
		&& Values.Contains(4);
}
/** @end */
