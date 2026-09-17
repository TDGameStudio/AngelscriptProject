/**
 * @version v1
 * @summary An &out TSet<int32> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachElement
 */
/**
 * @begin FillByForEachElement
 * @summary An &out TSet<int32> is filled by range-for from a local source.
 * @topic Containers
 */
void FillByForEachElement(TSet<int32>&out Result)
{
	TSet<int32> Source;
	Source.Add(1);
	Source.Add(2);
	for (int32 Value : Source)
	{
		Result.Add(Value);
	}
}
/** @end */
