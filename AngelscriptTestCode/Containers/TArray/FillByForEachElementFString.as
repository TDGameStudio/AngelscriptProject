/**
 * @version v1
 * @summary An &out TArray<FString> is filled by range-for from a local source.
 * @topic Containers
 *
 * FillByForEachElementFString
 */
/**
 * @begin FillByForEachElementFString
 * @summary An &out TArray<FString> is filled by range-for from a local source.
 * @topic Containers
 */
void FillByForEachElementFString(TArray<FString>&out Result)
{
	TArray<FString> Source;
	Source.Add("alpha");
	Source.Add("beta");
	Source.Add("gamma");
	for (FString Value : Source)
	{
		Result.Add(Value);
	}
}
/** @end */
