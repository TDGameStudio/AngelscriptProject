/**
 * @version v1
 * @summary A const&in TSet<UObject> reports Add membership by identity.
 * @topic Containers
 *
 * ReadAddElementIsContainedUObject
 */
/**
 * @begin ReadAddElementIsContainedUObject
 * @summary A const&in TSet<UObject> reports Add membership by identity.
 * @topic Containers
 */
bool ReadAddElementIsContainedUObject(const TSet<UObject>&in Values)
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
	return Values.Num() == 3 && Count == 3;
}
/** @end */
