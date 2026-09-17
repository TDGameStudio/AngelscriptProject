/**
 * @version v1
 * @summary Range-for visits each FVector member exactly once.
 * @topic Containers
 *
 * ForEachElementFVector
 */
/**
 * @begin ForEachElementFVector
 * @summary Range-for visits each FVector member exactly once.
 * @topic Containers
 */
bool ForEachElementFVector()
{
	TSet<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	int32 VisitCount = 0;
	for (FVector Value : Values)
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
