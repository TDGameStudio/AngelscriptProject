/**
 * @version v1
 * @summary A const&in TArray<UObject> reports Add insertion order by identity.
 * @topic Containers
 *
 * ReadAddOrderUObject
 */
/**
 * @begin ReadAddOrderUObject
 * @summary A const&in TArray<UObject> reports Add insertion order by identity.
 * @topic Containers
 */
bool ReadAddOrderUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 3
		&& Values[0] != nullptr && Values[1] != nullptr && Values[2] != nullptr
		&& Values[0] != Values[1] && Values[1] != Values[2] && Values[0] != Values[2];
}
/** @end */
