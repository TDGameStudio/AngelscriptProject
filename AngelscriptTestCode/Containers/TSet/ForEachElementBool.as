/**
 * @version v1
 * @summary Range-for visits each bool member exactly once.
 * @topic Containers
 *
 * ForEachElementBool
 */
/**
 * @begin ForEachElementBool
 * @summary Range-for visits each bool member exactly once.
 * @topic Containers
 */
bool ForEachElementBool()
{
	TSet<bool> Values;
	Values.Add(true);
	Values.Add(false);
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
