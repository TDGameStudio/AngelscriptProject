/**
 * @version v1
 * @summary A const&in TArray<UObject> reports membership after RemoveSwap deleted every match.
 * @topic Containers
 *
 * ReadRemoveSwapUObject
 */
/**
 * @begin ReadRemoveSwapUObject
 * @summary A const&in TArray<UObject> reports membership after RemoveSwap deleted every match.
 * @topic Containers
 */
bool ReadRemoveSwapUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 2
		&& Values[0] != nullptr && Values[1] != nullptr;
}
/** @end */
