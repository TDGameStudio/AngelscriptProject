/**
 * @version v1
 * @summary An &out TArray<bool> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachElementBool
 */
/**
 * @begin FillByForEachElementBool
 * @summary An &out TArray<bool> is filled by range-for from a local source.
 * @topic Containers
 */
void FillByForEachElementBool(TArray<bool>&out Result)
{
	TArray<bool> Source;
	Source.Add(false);
	Source.Add(true);
	Source.Add(false);
	for (bool Value : Source)
	{
		Result.Add(Value);
	}
}
/** @end */
