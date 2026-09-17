/**
 * @version v1
 * @summary A const&in TSet<bool> is visited by range-for.
 * @topic Containers
 *
 * ReadForEachElementBool
 */
/**
 * @begin ReadForEachElementBool
 * @summary A const&in TSet<bool> is visited by range-for.
 * @topic Containers
 */
bool ReadForEachElementBool(const TSet<bool>&in Values)
{
	int32 VisitCount = 0;
	for (bool Value : Values)
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
