/**
 * @version v1
 * @summary A const&in TSet<int32> is visited by range-for.
 * @topic Containers
 *
 * ReadForEachElement
 */
/**
 * @begin ReadForEachElement
 * @summary A const&in TSet<int32> is visited by range-for.
 * @topic Containers
 */
bool ReadForEachElement(const TSet<int32>&in Values)
{
	int32 VisitCount = 0;
	int32 Sum = 0;
	for (int32 Value : Values)
	{
		if (!Values.Contains(Value))
		{
			return false;
		}
		VisitCount += 1;
		Sum += Value;
	}
	return VisitCount == 2 && Sum == 3;
}
/** @end */
