/**
 * @version v1
 * @summary A const&in TSet<FVector> is visited by range-for.
 * @topic Containers
 *
 * ReadForEachElementFVector
 */
/**
 * @begin ReadForEachElementFVector
 * @summary A const&in TSet<FVector> is visited by range-for.
 * @topic Containers
 */
bool ReadForEachElementFVector(const TSet<FVector>&in Values)
{
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
