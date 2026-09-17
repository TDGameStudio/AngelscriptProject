/**
 * @version v1
 * @summary A const&in TSet<UObject> reports a single unique member after duplicate Add.
 * @topic Containers
 *
 * ReadAddDuplicateIgnoredUObject
 */
/**
 * @begin ReadAddDuplicateIgnoredUObject
 * @summary A const&in TSet<UObject> reports a single unique member after duplicate Add.
 * @topic Containers
 */
bool ReadAddDuplicateIgnoredUObject(const TSet<UObject>&in Values)
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
