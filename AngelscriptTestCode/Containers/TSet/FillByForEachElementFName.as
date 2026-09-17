/**
 * @version v1
 * @summary An &out TSet<FName> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachElementFName
 */
/**
 * @begin FillByForEachElementFName
 * @summary An &out TSet<FName> is filled by range-for from a local source.
 * @topic Containers
 */
void FillByForEachElementFName(TSet<FName>&out Result)
{
	TSet<FName> Source;
	Source.Add(n"Red");
	Source.Add(n"Green");
	for (FName Value : Source)
	{
		Result.Add(Value);
	}
}
/** @end */
