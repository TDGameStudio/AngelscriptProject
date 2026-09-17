/**
 * @version v1
 * @summary A const&in TSet<UObject> reports assigned membership by identity.
 * @topic Containers
 *
 * ReadCopyAssignUObject
 */
/**
 * @begin ReadCopyAssignUObject
 * @summary A const&in TSet<UObject> reports assigned membership by identity.
 * @topic Containers
 */
bool ReadCopyAssignUObject(const TSet<UObject>&in Values)
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
	return Values.Num() == 2 && Count == 2;
}
/** @end */
