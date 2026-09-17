/**
 * @version v1
 * @summary An &out TSet<FString> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachElementFString
 */
/**
 * @begin FillByForEachElementFString
 * @summary An &out TSet<FString> is filled by range-for from a local source.
 * @topic Containers
 */
void FillByForEachElementFString(TSet<FString>&out Result)
{
	TSet<FString> Source;
	Source.Add("alpha");
	Source.Add("beta");
	for (FString Value : Source)
	{
		Result.Add(Value);
	}
}
/** @end */
