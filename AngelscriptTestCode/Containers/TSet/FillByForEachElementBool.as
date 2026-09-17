/**
 * @version v1
 * @summary An &out TSet<bool> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachElementBool
 */
/**
 * @begin FillByForEachElementBool
 * @summary An &out TSet<bool> is filled by range-for from a local source.
 * @topic Containers
 */
void FillByForEachElementBool(TSet<bool>&out Result)
{
	TSet<bool> Source;
	Source.Add(true);
	Source.Add(false);
	for (bool Value : Source)
	{
		Result.Add(Value);
	}
}
/** @end */
