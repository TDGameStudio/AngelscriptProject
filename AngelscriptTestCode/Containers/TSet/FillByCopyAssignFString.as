/**
 * @version v1
 * @summary An &out TSet<FString> is filled by assigning a local source set.
 * @topic Containers
 *
 * FillByCopyAssignFString
 */
/**
 * @begin FillByCopyAssignFString
 * @summary An &out TSet<FString> is filled by assigning a local source set.
 * @topic Containers
 */
void FillByCopyAssignFString(TSet<FString>&out Result)
{
	TSet<FString> Source;
	Source.Add("alpha");
	Source.Add("beta");
	Result = Source;
}
/** @end */
