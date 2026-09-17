/**
 * @version v1
 * @summary An &out TArray<int32> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachElement
 */
/**
 * @begin FillByForEachElement
 * @summary An &out TArray<int32> is filled by range-for from a local source.
 * @topic Containers
 */
void FillByForEachElement(TArray<int32>&out Result)
{
	TArray<int32> Source;
	Source.Add(10);
	Source.Add(20);
	Source.Add(30);
	for (int32 Value : Source)
	{
		Result.Add(Value);
	}
}
/** @end */
