/**
 * @version v1
 * @summary Range-for visits {1, 2} exactly once with sum 3.
 * @topic Containers
 *
 * ForEachElement
 */
/**
 * @begin ForEachElement
 * @summary Range-for visits {1, 2} exactly once with sum 3.
 * @topic Containers
 */
bool ForEachElement()
{
	TSet<int32> Values;
	Values.Add(1);
	Values.Add(2);
	int32 VisitCount = 0;
	int32 Sum = 0;
	for (int32 Value : Values)
	{
		VisitCount += 1;
		Sum += Value;
	}
	return VisitCount == 2 && Sum == 3;
}
/** @end */
