/**
 * @version v1
 * @summary A const&in TSet<FName> is visited by range-for.
 * @topic Containers
 *
 * ReadForEachElementFName
 */
/**
 * @begin ReadForEachElementFName
 * @summary A const&in TSet<FName> is visited by range-for.
 * @topic Containers
 */
bool ReadForEachElementFName(const TSet<FName>&in Values)
{
	int32 VisitCount = 0;
	for (FName Value : Values)
	{
		if (!Values.Contains(Value))
		{
			return false;
		}
		VisitCount += 1;
	}
	return VisitCount == 2;
}
/** @end */
