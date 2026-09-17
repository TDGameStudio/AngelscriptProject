/**
 * @version v1
 * @summary An &out TMap<int, int> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachPair
 */
/**
 * @begin FillByForEachPair
 * @summary An &out TMap<int, int> is filled by range-for from a local source.
 * @topic Containers
 */
void FillByForEachPair(TMap<int, int>&out Result)
{
	TMap<int, int> Source;
	Source.Add(10, 100);
	Source.Add(20, 200);
	Source.Add(30, 300);
	for (int Key, int Value : Source)
	{
		Result.Add(Key, Value);
	}
}
/** @end */
