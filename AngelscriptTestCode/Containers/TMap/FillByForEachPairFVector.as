/**
 * @version v1
 * @summary An &out TMap<int, FVector> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachPairFVector
 */
/**
 * @begin FillByForEachPairFVector
 * @summary An &out TMap<int, FVector> is filled by range-for from a local source.
 * @topic Containers
 */
void FillByForEachPairFVector(TMap<int, FVector>&out Result)
{
	TMap<int, FVector> Source;
	Source.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Source.Add(2, FVector(0.0f, 1.0f, 0.0f));
	Source.Add(3, FVector(0.0f, 0.0f, 1.0f));
	for (int Key, FVector Value : Source)
	{
		Result.Add(Key, Value);
	}
}
/** @end */
