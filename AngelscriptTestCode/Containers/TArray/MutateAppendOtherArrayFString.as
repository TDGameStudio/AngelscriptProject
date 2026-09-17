/**
 * @version v1
 * @summary An &inout TArray<FString> receives Append of another array.
 * @topic Containers
 *
 * MutateAppendOtherArrayFString
 */
/**
 * @begin MutateAppendOtherArrayFString
 * @summary An &inout TArray<FString> receives Append of another array.
 * @topic Containers
 */
void MutateAppendOtherArrayFString(TArray<FString>&inout Values)
{
	TArray<FString> Other;
	Other.Add("beta");
	Other.Add("gamma");
	Values.Append(Other);
}
/** @end */
