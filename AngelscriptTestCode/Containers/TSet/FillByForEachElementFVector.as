/**
 * @version v1
 * @summary An &out TSet<FVector> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachElementFVector
 */
/**
 * @begin FillByForEachElementFVector
 * @summary An &out TSet<FVector> is filled by range-for from a local source.
 * @topic Containers
 */
void FillByForEachElementFVector(TSet<FVector>&out Result)
{
	TSet<FVector> Source;
	Source.Add(FVector(1.0f, 0.0f, 0.0f));
	Source.Add(FVector(0.0f, 1.0f, 0.0f));
	for (FVector Value : Source)
	{
		Result.Add(Value);
	}
}
/** @end */
