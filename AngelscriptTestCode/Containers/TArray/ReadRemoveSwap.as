/**
 * @version v1
 * @summary A const&in TArray<int32> reports membership after RemoveSwap deleted every match.
 * @topic Containers
 *
 * ReadRemoveSwap
 */
/**
 * @begin ReadRemoveSwap
 * @summary A const&in TArray<int32> reports membership after RemoveSwap deleted every match.
 * @topic Containers
 */
bool ReadRemoveSwap(const TArray<int32>&in Values)
{
	return Values.Num() == 3
		&& !Values.Contains(2)
		&& Values.Contains(1)
		&& Values.Contains(3)
		&& Values.Contains(4);
}
/** @end */
