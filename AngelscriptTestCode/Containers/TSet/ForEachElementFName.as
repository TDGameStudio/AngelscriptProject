/**
 * @version v1
 * @summary Range-for visits each FName member exactly once.
 * @topic Containers
 *
 * ForEachElementFName
 */
/**
 * @begin ForEachElementFName
 * @summary Range-for visits each FName member exactly once.
 * @topic Containers
 */
bool ForEachElementFName()
{
	TSet<FName> Values;
	Values.Add(n"Red");
	Values.Add(n"Green");
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
