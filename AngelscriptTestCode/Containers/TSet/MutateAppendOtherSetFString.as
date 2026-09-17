/**
 * @version v1
 * @summary An &inout TSet<FString> receives Append of another set.
 * @topic Containers
 *
 * MutateAppendOtherSetFString
 */
/**
 * @begin MutateAppendOtherSetFString
 * @summary An &inout TSet<FString> receives Append of another set.
 * @topic Containers
 */
void MutateAppendOtherSetFString(TSet<FString>&inout Values)
{
	TSet<FString> Other;
	Other.Add("gamma");
	Other.Add("delta");
	Values.Append(Other);
}
/** @end */
