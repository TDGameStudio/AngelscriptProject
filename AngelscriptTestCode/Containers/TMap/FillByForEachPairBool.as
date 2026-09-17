/**
 * @version v1
 * @summary An &out TMap<int, bool> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachPairBool
 */
/**
 * @begin FillByForEachPairBool
 * @summary An &out TMap<int, bool> is filled by range-for from a local source.
 * @topic Containers
 */
void FillByForEachPairBool(TMap<int, bool>&out Result)
{
	TMap<int, bool> Source;
	Source.Add(1, true);
	Source.Add(2, false);
	Source.Add(3, true);
	for (int Key, bool Value : Source)
	{
		Result.Add(Key, Value);
	}
}
/** @end */
