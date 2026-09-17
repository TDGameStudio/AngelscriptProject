/**
 * @version v1
 * @summary An &out TMap<FName, int> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachPairFName
 */
/**
 * @begin FillByForEachPairFName
 * @summary An &out TMap<FName, int> is filled by range-for from a local source.
 * @topic Containers
 */
void FillByForEachPairFName(TMap<FName, int>&out Result)
{
	TMap<FName, int> Source;
	Source.Add(n"Red", 1);
	Source.Add(n"Green", 2);
	Source.Add(n"Blue", 3);
	for (FName Key, int Value : Source)
	{
		Result.Add(Key, Value);
	}
}
/** @end */
