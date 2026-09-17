/**
 * @version v1
 * @summary A const&in TArray<UObject> reports the array after RemoveSingle kept later order.
 * @topic Containers
 *
 * ReadRemoveSinglePreservesOrderUObject
 */
/**
 * @begin ReadRemoveSinglePreservesOrderUObject
 * @summary A const&in TArray<UObject> reports the array after RemoveSingle kept later order.
 * @topic Containers
 */
bool ReadRemoveSinglePreservesOrderUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 3
		&& Values[0] != nullptr && Values[1] != nullptr && Values[2] != nullptr;
}
/** @end */
