/**
 * @version v1
 * @summary An &out TArray<float> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachElementFloat
 */
/**
 * @begin FillByForEachElementFloat
 * @summary An &out TArray<float> is filled by range-for from a local source.
 * @topic Containers
 */
void FillByForEachElementFloat(TArray<float>&out Result)
{
	TArray<float> Source;
	Source.Add(10.0f);
	Source.Add(20.0f);
	Source.Add(30.0f);
	for (float Value : Source)
	{
		Result.Add(Value);
	}
}
/** @end */
