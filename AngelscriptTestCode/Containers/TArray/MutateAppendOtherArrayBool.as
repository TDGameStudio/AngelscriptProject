/**
 * @version v1
 * @summary An &inout TArray<bool> receives Append of another array.
 * @topic Containers
 *
 * MutateAppendOtherArrayBool
 */
/**
 * @begin MutateAppendOtherArrayBool
 * @summary An &inout TArray<bool> receives Append of another array.
 * @topic Containers
 */
void MutateAppendOtherArrayBool(TArray<bool>&inout Values)
{
	TArray<bool> Other;
	Other.Add(true);
	Other.Add(false);
	Values.Append(Other);
}
/** @end */
