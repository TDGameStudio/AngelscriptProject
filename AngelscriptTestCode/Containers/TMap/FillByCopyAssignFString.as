/**
 * @version v1
 * @summary An &out TMap<FString, int> is filled by assigning a local source map.
 * @topic Containers
 *
 * FillByCopyAssignFString
 */
/**
 * @begin FillByCopyAssignFString
 * @summary An &out TMap<FString, int> is filled by assigning a local source map.
 * @topic Containers
 */
void FillByCopyAssignFString(TMap<FString, int>&out Result)
{
	TMap<FString, int> Source;
	Source.Add("alpha", 100);
	Source.Add("beta", 200);
	Source.Add("gamma", 300);
	Result = Source;
}
/** @end */
