/**
 * @version v1
 * @summary An &out TArray<FString> is filled then Sort orders it ascending.
 * @topic Containers
 *
 * FillBySortAscendingFString
 */
/**
 * @begin FillBySortAscendingFString
 * @summary An &out TArray<FString> is filled then Sort orders it ascending.
 * @topic Containers
 */
void FillBySortAscendingFString(TArray<FString>&out Result)
{
	Result.Add("c");
	Result.Add("a");
	Result.Add("b");
	Result.Sort();
}
/** @end */
