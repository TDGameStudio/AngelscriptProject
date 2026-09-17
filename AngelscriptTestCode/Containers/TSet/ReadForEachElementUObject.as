/**
 * @version v1
 * @summary A const&in TSet<UObject> is visited by range-for.
 * @topic Containers
 *
 * ReadForEachElementUObject
 */
/**
 * @begin ReadForEachElementUObject
 * @summary A const&in TSet<UObject> is visited by range-for.
 * @topic Containers
 */
bool ReadForEachElementUObject(const TSet<UObject>&in Values)
{
	int32 VisitCount = 0;
	for (UObject Value : Values)
	{
		if (Value == nullptr || !Values.Contains(Value))
		{
			return false;
		}
		VisitCount += 1;
	}
	return VisitCount == 2 && Values.Num() == 2;
}
/** @end */
