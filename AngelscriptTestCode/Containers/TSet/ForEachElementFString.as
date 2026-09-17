/**
 * @version v1
 * @summary Range-for visits each FString member exactly once.
 * @topic Containers
 *
 * ForEachElementFString
 */
/**
 * @begin ForEachElementFString
 * @summary Range-for visits each FString member exactly once.
 * @topic Containers
 */
bool ForEachElementFString()
{
	TSet<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
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
