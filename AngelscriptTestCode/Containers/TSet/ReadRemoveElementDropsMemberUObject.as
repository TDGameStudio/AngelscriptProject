/**
 * @version v1
 * @summary A const&in TSet<UObject> reports membership after Remove.
 * @topic Containers
 *
 * ReadRemoveElementDropsMemberUObject
 */
/**
 * @begin ReadRemoveElementDropsMemberUObject
 * @summary A const&in TSet<UObject> reports membership after Remove.
 * @topic Containers
 */
bool ReadRemoveElementDropsMemberUObject(const TSet<UObject>&in Values)
{
	int32 Count = 0;
	for (UObject Item : Values)
	{
		if (Item == nullptr || !Values.Contains(Item))
		{
			return false;
		}
		Count += 1;
	}
	return Values.Num() == 1 && Count == 1;
}
/** @end */
