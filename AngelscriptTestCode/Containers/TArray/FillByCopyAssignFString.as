/**
 * @version v1
 * @summary An &out TArray<FString> is filled by assigning a local source array.
 * @topic Containers
 *
 * FillByCopyAssignFString
 */
/**
 * @begin FillByCopyAssignFString
 * @summary An &out TArray<FString> is filled by assigning a local source array.
 * @topic Containers
 */
void FillByCopyAssignFString(TArray<FString>&out Result)
{
	TArray<FString> Source;
	Source.Add("alpha");
	Source.Add("beta");
	Result = Source;
}
/** @end */
