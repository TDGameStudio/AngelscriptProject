/**
 * @version v1
 * @summary A const&in TArray<UObject> reports membership after RemoveAtSwap dropped an index.
 * @topic Containers
 *
 * ReadRemoveAtSwapUObject
 */
/**
 * @begin ReadRemoveAtSwapUObject
 * @summary A const&in TArray<UObject> reports membership after RemoveAtSwap dropped an index.
 * @topic Containers
 */
bool ReadRemoveAtSwapUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 3
		&& Values[0] != nullptr && Values[1] != nullptr && Values[2] != nullptr;
}
/** @end */
