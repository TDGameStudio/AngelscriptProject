/**
 * @version v1
 * @summary RemoveSwap deletes every matching FString and keeps a non-matching survivor.
 * @topic Containers
 *
 * RemoveSwapFString
 */
/**
 * @begin RemoveSwapFString
 * @summary RemoveSwap deletes every matching FString and keeps a non-matching survivor.
 * @topic Containers
 */
bool RemoveSwapFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Add("alpha");
	int Removed = Values.RemoveSwap("alpha");
	int Missing = Values.RemoveSwap("zeta");
	return Removed == 2 && Missing == 0 && Values.Num() == 1 && Values.Contains("beta");
}
/** @end */
