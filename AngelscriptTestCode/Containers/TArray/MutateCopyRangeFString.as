/**
 * @version v1
 * @summary An &inout TArray<FString> is overwritten in place by Copy.
 * @topic Containers
 *
 * MutateCopyRangeFString
 */
/**
 * @begin MutateCopyRangeFString
 * @summary An &inout TArray<FString> is overwritten in place by Copy.
 * @topic Containers
 */
void MutateCopyRangeFString(TArray<FString>&inout Values)
{
	TArray<FString> Source;
	Source.Add("p");
	Source.Add("q");
	Values.Copy(Source, 0, 2, 0);
}
/** @end */
