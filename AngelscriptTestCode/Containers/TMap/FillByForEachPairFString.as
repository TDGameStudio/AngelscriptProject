/**
 * @version v1
 * @summary An &out TMap<FString, int> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachPairFString
 */
/**
 * @begin FillByForEachPairFString
 * @summary An &out TMap<FString, int> is filled by range-for from a local source.
 * @topic Containers
 */
void FillByForEachPairFString(TMap<FString, int>&out Result)
{
	TMap<FString, int> Source;
	Source.Add("alpha", 100);
	Source.Add("beta", 200);
	Source.Add("gamma", 300);
	for (FString Key, int Value : Source)
	{
		Result.Add(Key, Value);
	}
}
/** @end */
