/**
 * @version v1
 * @summary A const&in TSet<FString> is visited by range-for.
 * @topic Containers
 *
 * ReadForEachElementFString
 */
/**
 * @begin ReadForEachElementFString
 * @summary A const&in TSet<FString> is visited by range-for.
 * @topic Containers
 */
bool ReadForEachElementFString(const TSet<FString>&in Values)
{
	int32 VisitCount = 0;
	for (FString Value : Values)
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
