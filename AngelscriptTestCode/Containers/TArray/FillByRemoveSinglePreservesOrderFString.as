/**
 * @version v1
 * @summary An &out TArray<FString> is filled then RemoveSingle drops one duplicate.
 * @topic Containers
 *
 * FillByRemoveSinglePreservesOrderFString
 */
/**
 * @begin FillByRemoveSinglePreservesOrderFString
 * @summary An &out TArray<FString> is filled then RemoveSingle drops one duplicate.
 * @topic Containers
 */
void FillByRemoveSinglePreservesOrderFString(TArray<FString>&out Result)
{
	Result.Add("a");
	Result.Add("b");
	Result.Add("b");
	Result.Add("c");
	Result.RemoveSingle("b");
}
/** @end */
