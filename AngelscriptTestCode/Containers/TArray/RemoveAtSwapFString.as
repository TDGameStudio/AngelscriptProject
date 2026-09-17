/**
 * @version v1
 * @summary RemoveAtSwap drops the indexed FString and may reorder survivors.
 * @topic Containers
 *
 * RemoveAtSwapFString
 */
/**
 * @begin RemoveAtSwapFString
 * @summary RemoveAtSwap drops the indexed FString and may reorder survivors.
 * @topic Containers
 */
bool RemoveAtSwapFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Add("gamma");
	Values.RemoveAtSwap(0);
	return Values.Num() == 2 && !Values.Contains("alpha");
}
/** @end */
